import {
  Injectable, 
  NotFoundException, 
  ForbiddenException,
  BadRequestException 
} from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import mongoose, { Model } from 'mongoose';
import { Product } from './interfaces/product.interface';
import { CreateProductDto } from './dto/create-product.dto';
import { UpdateProductDto } from './dto/update-product.dto';
import { PaginationDto } from '../pagination/pagination.dto';
import { CloudinaryService } from 'src/cloudinary/cloudinary.service';
import { ImageCompressionService } from 'src/services/image-compression.service';
import { MonthlyStats } from '../monthly-stats/interfaces/monthly-stats.interface';

@Injectable()
export class ProductService {
  constructor(
    @InjectModel('Product') private readonly productModel: Model<Product>,
    @InjectModel('MonthlyStats')
    private readonly monthlyStatsModel: Model<MonthlyStats>,
    private readonly cloudinaryService: CloudinaryService,
    private readonly imageCompressionService: ImageCompressionService,
  ) {}

  // crear producto
  async create(
    userId: string,
    createProductDto: CreateProductDto,
  ): Promise<Product> {
    const newProduct = new this.productModel({
      ...createProductDto,
      userId,
      listType: createProductDto.listType || 'have',
    });
    return newProduct.save();
  }

  // obtener todos los productos paginados
  async findAllByUserPaginated(
    userId: string,
    paginationDto: PaginationDto,
    listType?: string,
  ) {
    const { page, limit } = paginationDto;
    const skip = (page - 1) * limit;

    const filter: any = { userId };
    if (listType) filter.listType = listType;

    const [data, total] = await Promise.all([
      this.productModel
        .find(filter)
        .sort({ createdAt: -1 })
        .skip(skip)
        .limit(limit)
        .exec(),
      this.productModel.countDocuments(filter),
    ]);

    return {
      data,
      info: {
        totalProducts: total,
        totalPages: Math.ceil(total / limit),
        page,
        limit,
      },
    };
  }

  // obtener producto segun su id
  async findById(id: string, userId: string): Promise<Product | null> {
    const product = await this.productModel.findById(id).exec();
    if (!product) return null;
    if (product.userId.toString() !== userId.toString()) {
      throw new ForbiddenException('No tienes permiso para ver este producto');
    }
    return product;
  }

  // actualizar producto
  async update(
    id: string,
    userId: string,
    updateProductDto: UpdateProductDto,
  ): Promise<Product | null> {
    const product = await this.productModel.findById(id).exec();
    if (!product) throw new NotFoundException(`Producto ${id} no encontrado`);
    if (product.userId.toString() !== userId.toString()) {
      throw new ForbiddenException('No puedes modificar este producto');
    }

    // !!!!!!!!!!!!!!!!!!!!!
    const updateData = Object.fromEntries(
      Object.entries(updateProductDto).filter(([_, v]) => v !== undefined),
    );

    // Aplicar lógica de negocio específica (caducidad, etc.)
    this.applyBusinessRules(product, updateData);

    const updated = await this.productModel
      .findByIdAndUpdate(id, updateData, {
        returnDocument: 'after',
        runValidators: false,
      })
      .exec();

    return updated;
  }

  private applyBusinessRules(product: Product, updateData: any): void {
    // Regla 1: Si el producto está abierto y se cambia el período después de apertura
    if (product.isOpened && updateData.periodAfterOpening !== undefined) {
      const newExpiration = this.calculateExpirationDate(
        updateData.openedDate || product.openedDate,
        updateData.periodAfterOpening || product.periodAfterOpening,
        updateData.expirationDate !== undefined
          ? updateData.expirationDate
          : product.expirationDate,
      );
      if (newExpiration) updateData.expirationDate = newExpiration;
    }

    // Regla 2: (futura) Si se marca como abierto y tiene período, calcular caducidad
    if (
      updateData.isOpened === true &&
      product.periodAfterOpening &&
      !updateData.expirationDate
    ) {
      const openedDate = updateData.openedDate || new Date();
      updateData.openedDate = openedDate;
      const calculated = this.calculateExpirationFromPeriod(
        openedDate,
        product.periodAfterOpening,
      );
      if (calculated) updateData.expirationDate = calculated;
    }
  }

  // eliminar producto y su imagen de cloudinary
  async delete(id: string, userId: string): Promise<Product | null> {
    const product = await this.productModel.findById(id).exec();
    if (!product) throw new NotFoundException(`Producto ${id} no encontrado`);
    if (product.userId.toString() !== userId.toString()) {
      throw new ForbiddenException('No puedes eliminar este producto');
    }
    if (product.imageUrl) {
      const publicId = this.cloudinaryService.extractPublicIdFromUrl(
        product.imageUrl,
      );
      if (publicId) {
        await this.cloudinaryService.deleteImage(publicId);
        console.log(
          `🗑️ Imagen eliminada de Cloudinary al borrar producto: ${publicId}`,
        );
      }
    }
    return this.productModel.findByIdAndDelete(id).exec();
  }

  // cambiar el producto de lista
  async moveToList(
    id: string,
    userId: string,
    targetList: string,
  ): Promise<Product | null> {
    const product = await this.productModel.findById(id).exec();
    if (!product) throw new NotFoundException(`Producto ${id} no encontrado`);
    if (product.userId.toString() !== userId.toString()) {
      throw new ForbiddenException('No puedes mover este producto');
    }
    return this.productModel
      .findByIdAndUpdate(
        id,
        { listType: targetList },
        { returnDocument: 'after' },
      )
      .exec();
  }

  // marcar el producto como abierto y mandar a hacer el calculo de caducidad
  async markAsOpened(
    id: string,
    userId: string,
    customOpenedDate?: Date,
  ): Promise<Product | null> {
    const product = await this.productModel.findById(id).exec();
    if (!product) throw new NotFoundException(`Producto ${id} no encontrado`);
    if (product.userId.toString() !== userId.toString()) {
      throw new ForbiddenException('No puedes modificar este producto');
    }
    if (product.isOpened) {
      throw new BadRequestException('El producto ya está abierto');
    }
    const openedDate = customOpenedDate || new Date();
    let finalExpiration = product.expirationDate;
    if (product.periodAfterOpening) {
      const calculatedExpiration = this.calculateExpirationFromPeriod(
        openedDate,
        product.periodAfterOpening,
      );
      if (finalExpiration && calculatedExpiration) {
        finalExpiration =
          calculatedExpiration < finalExpiration
            ? calculatedExpiration
            : finalExpiration;
      } else if (calculatedExpiration) {
        finalExpiration = calculatedExpiration;
      }
    }
    const updated = await this.productModel
      .findByIdAndUpdate(
        id,
        { openedDate, isOpened: true, expirationDate: finalExpiration },
        { returnDocument: 'after' },
      )
      .exec();
    return updated;
  }

  // cerrar producto y limpiar el campo de caducidad
  async markAsClosed(id: string, userId: string): Promise<Product | null> {
    const product = await this.productModel.findById(id).exec();
    if (!product) throw new NotFoundException(`Producto ${id} no encontrado`);
    if (product.userId.toString() !== userId.toString()) {
      throw new ForbiddenException('No puedes modificar este producto');
    }
    if (!product.isOpened) {
      throw new BadRequestException('El producto no está abierto');
    }
    return this.productModel
      .findByIdAndUpdate(id, { isOpened: false }, { returnDocument: 'after' })
      .exec();
  }

  // calcular fecha de caducidad
  async calculateExpirationFromOpening(
    id: string,
    userId: string,
  ): Promise<Product | null> {
    const product = await this.productModel.findById(id).exec();
    if (!product) throw new NotFoundException(`Producto ${id} no encontrado`);
    if (product.userId.toString() !== userId.toString()) {
      throw new ForbiddenException('No puedes modificar este producto');
    }
    if (!product.isOpened) {
      throw new BadRequestException('El producto no ha sido abierto aún');
    }
    if (!product.openedDate) {
      throw new BadRequestException(
        'El producto no tiene fecha de apertura registrada',
      );
    }
    if (!product.periodAfterOpening) {
      throw new BadRequestException(
        'El producto no tiene período después de abierto definido',
      );
    }
    const newExpiration = this.calculateExpirationDate(
      product.openedDate,
      product.periodAfterOpening,
      product.expirationDate,
    );
    return this.productModel
      .findByIdAndUpdate(
        id,
        { expirationDate: newExpiration },
        { returnDocument: 'after' },
      )
      .exec();
  }

  // ver la cantidad de productos segun la lista en la que estan
  async getStats(userId: string) {
    const stats = await this.productModel.aggregate([
      { $match: { userId: new mongoose.Types.ObjectId(userId) } },
      { $group: { _id: '$listType', count: { $sum: 1 } } },
    ]);
    const result = { wishlist: 0, have: 0, used: 0, total: 0 };
    stats.forEach(({ _id, count }) => {
      if (result[_id] !== undefined) result[_id] = count;
    });
    result.total = stats.reduce((acc, s) => acc + s.count, 0);
    return result;
  }

  // obtener productos caducados
  async getExpiredProducts(userId: string): Promise<Product[]> {
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    return this.productModel
      .find({
        userId,
        expirationDate: { $lt: today },
        listType: { $ne: 'deleted' },
      })
      .sort({ expirationDate: 1 })
      .exec();
  }

  // obtener productos que van a caducar pronto
  async getExpiringSoon(userId: string, days: number = 30): Promise<Product[]> {
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    const futureDate = new Date();
    futureDate.setDate(today.getDate() + days);
    futureDate.setHours(23, 59, 59, 999);
    return this.productModel
      .find({
        userId,
        expirationDate: { $gte: today, $lte: futureDate },
        listType: { $ne: 'deleted' },
      })
      .sort({ expirationDate: 1 })
      .exec();
  }

  // metodo para calcular la fecha de caducidad
  private calculateExpirationDate(
    baseDate: Date | null | undefined,
    period: string | null | undefined,
    fixedExpiration: Date | null | undefined,
  ): Date | null {
    if (!baseDate || !period) return fixedExpiration || null;
    const calculated = this.calculateExpirationFromPeriod(baseDate, period);
    if (!calculated) return fixedExpiration || null;
    if (fixedExpiration) {
      const fixed = new Date(fixedExpiration);
      return calculated < fixed ? calculated : fixed;
    }
    return calculated;
  }

  private calculateExpirationFromPeriod(
    baseDate: Date,
    period: string,
  ): Date | null {
    const months = this.parsePeriodToMonths(period);
    if (!months) return null;

    const expiration = new Date(baseDate);
    expiration.setMonth(expiration.getMonth() + months);
    return expiration;
  }

  // caluclar fecha segun el PAO
  private parsePeriodToMonths(period: string): number | null {
    if (!period) return null;

    const cleaned = period.trim().toUpperCase();

    // Formato "12M"
    const mMatch = cleaned.match(/^(\d+)\s*M$/);
    if (mMatch) return parseInt(mMatch[1]);

    // Solo número "12"
    const numberMatch = cleaned.match(/^(\d+)$/);
    if (numberMatch) return parseInt(numberMatch[1]);

    return null;
  }

  // subir imagen para el producto
  async uploadProductImage(
    productId: string,
    userId: string,
    fileBuffer: Buffer,
    mimeType: string,
  ): Promise<Product> {
    const product = await this.findById(productId, userId);
    if (!product) {
      throw new NotFoundException(`Producto ${productId} no encontrado`);
    }

    console.log(`📸 Subiendo imagen para producto: ${product.name}`);

    const compressedBuffer =
      await this.imageCompressionService.compressProductImage(
        fileBuffer,
        mimeType,
      );

    const imageUrl = await this.cloudinaryService.uploadImage(
      compressedBuffer,
      `product_${productId}_${Date.now()}`,
      'products',
    );

    // Eliminar imagen anterior si existe
    if (product.imageUrl) {
      const publicId = this.cloudinaryService.extractPublicIdFromUrl(
        product.imageUrl,
      );
      if (publicId) {
        await this.cloudinaryService.deleteImage(publicId);
        console.log(`🗑️ Imagen anterior eliminada: ${publicId}`);
      }
    }

    // Actualizar el producto con la nueva URL
    const updatedProduct = await this.update(productId, userId, { imageUrl });
    if (!updatedProduct) {
      throw new BadRequestException(
        'No se pudo actualizar el producto con la nueva imagen',
      );
    }

    console.log(`✅ Imagen actualizada para: ${product.name}`);
    return updatedProduct;
  }

  // eliminar la imagen del producto
  async deleteProductImage(
    productId: string,
    userId: string,
  ): Promise<Product> {
    const product = await this.findById(productId, userId);
    if (!product)
      throw new NotFoundException(`Producto ${productId} no encontrado`);
    if (!product.imageUrl)
      throw new BadRequestException('El producto no tiene imagen');

    const publicId = this.cloudinaryService.extractPublicIdFromUrl(
      product.imageUrl,
    );
    if (publicId) {
      await this.cloudinaryService.deleteImage(publicId);
      console.log(`🗑️ Imagen eliminada de Cloudinary: ${publicId}`);
    }

    const updatedProduct = await this.update(productId, userId, {
      imageUrl: null,
    });
    if (!updatedProduct)
      throw new BadRequestException(
        'No se pudo eliminar la imagen del producto',
      );
    return updatedProduct;
  }

  // obtener historial completo de estadisticas mensuales
  async getMonthlyHistory(userId: string): Promise<any> {
    const stats = await this.monthlyStatsModel
      .find({ userId })
      .sort({ year: -1, month: -1 })
      .exec();

    return {
      total: stats.length,
      data: stats.map((stat) => ({
        year: stat.year,
        month: stat.month,
        monthName: this.getMonthName(stat.month),
        productsUsedCount: stat.productsUsedCount,
        archivedAt: stat.archivedAt,
      })),
    };
  }

  //
  async updateOrCreateMonthlyStats(
    userId: string,
    year: number,
    month: number,
    incrementCount: number,
  ) {
    const filter: any = {
      userId: new mongoose.Types.ObjectId(userId),
      year,
      month,
    };
    const update = {
      $inc: { productsUsedCount: incrementCount },
      $set: { archivedAt: new Date() },
    };
    const options = { upsert: true, returnDocument: 'after' as const };
    return this.monthlyStatsModel
      .findOneAndUpdate(filter, update, options)
      .exec();
  }

  // estadisticas del mes actual y los anteriores ??????
  async getYearlyOverview(userId: string): Promise<any> {
    const now = new Date();
    const startDate = new Date(now.getFullYear(), now.getMonth() - 11, 1);
    const endDate = new Date(now.getFullYear(), now.getMonth() + 1, 0);

    // Obtener estadísticas de los últimos 12 meses
    const stats = await this.monthlyStatsModel.aggregate([
      {
        $match: {
          userId: new mongoose.Types.ObjectId(userId),
          $expr: {
            $and: [
              {
                $or: [
                  { $gt: ['$year', startDate.getFullYear()] },
                  {
                    $and: [
                      { $eq: ['$year', startDate.getFullYear()] },
                      { $gte: ['$month', startDate.getMonth() + 1] },
                    ],
                  },
                ],
              },
              {
                $or: [
                  { $lt: ['$year', endDate.getFullYear()] },
                  {
                    $and: [
                      { $eq: ['$year', endDate.getFullYear()] },
                      { $lte: ['$month', endDate.getMonth() + 1] },
                    ],
                  },
                ],
              },
            ],
          },
        },
      },
      { $sort: { year: 1, month: 1 } },
    ]);

    // Rellenar meses sin datos con 0
    const data: Array<{
      year: number;
      month: number;
      monthName: string;
      productsUsedCount: number;
      date: string;
    }> = []; // 👈 tipo explícito

    for (let i = 11; i >= 0; i--) {
      const date = new Date(now.getFullYear(), now.getMonth() - i, 1);
      const year = date.getFullYear();
      const month = date.getMonth() + 1;
      const found = stats.find(
        (s: any) => s.year === year && s.month === month,
      );
      data.push({
        year,
        month,
        monthName: this.getMonthName(month),
        productsUsedCount: found ? found.productsUsedCount : 0,
        date: date.toISOString(),
      });
    }

    return {
      period: '12_months',
      data,
      total: data.reduce((sum, m) => sum + m.productsUsedCount, 0),
    };
  }

  // usados del mes actual
  async getCurrentMonthStats(userId: string): Promise<any> {
    const now = new Date();
    const year = now.getFullYear();
    const month = now.getMonth() + 1;

    const currentUsedCount = await this.productModel.countDocuments({
      userId,
      listType: 'used',
    });

    return {
      year,
      month,
      monthName: this.getMonthName(month),
      productsUsedCount: currentUsedCount,
      status: 'current',
    };
  }

  // helper para nombres de mes
  private getMonthName(month: number): string {
    const months = [
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre',
    ];
    return months[month - 1] || '';
  }
}