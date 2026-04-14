// product.service.ts - Versión simplificada con lógica completa de caducidad

import { 
  Injectable, 
  NotFoundException, 
  ForbiddenException,
  BadRequestException 
} from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { Product } from './interfaces/product.interface';
import { CreateProductDto } from './dto/create-product.dto';
import { UpdateProductDto } from './dto/update-product.dto';
import { PaginationDto } from '../pagination/pagination.dto';
import { CloudinaryService } from 'src/cloudinary/cloudinary.service';
import { ImageCompressionService } from 'src/services/image-compression.service';

@Injectable()
export class ProductService {
  constructor(
    @InjectModel('Product') private readonly productModel: Model<Product>,
    private readonly cloudinaryService: CloudinaryService,
    private readonly imageCompressionService: ImageCompressionService,
  ) {}

  // crear producto
  async create(userId: string, createProductDto: CreateProductDto): Promise<Product> {
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
    listType?: string
  ) {
    const { page, limit } = paginationDto;
    const skip = (page - 1) * limit;

    // Filtro base
    const filter: any = { userId };
    if (listType) filter.listType = listType;

    // Ejecutamos ambas consultas en paralelo para mejor performance
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
  async update(id: string, userId: string, updateProductDto: UpdateProductDto): Promise<Product | null> {
    const product = await this.productModel.findById(id).exec();
    if (!product) throw new NotFoundException(`Producto ${id} no encontrado`);
    if (product.userId.toString() !== userId.toString()) {
      throw new ForbiddenException('No puedes modificar este producto');
    }

    // Construir objeto de actualización (solo campos enviados)
    const updateData: any = {};
    const fields = ['name', 'brand', 'imageUrl', 'barcode', 'categories', 'notes', 'rating', 'listType', 'isOpened'];
    
    for (const field of fields) {
      if (updateProductDto[field] !== undefined) {
        updateData[field] = updateProductDto[field];
      }
    }

    // Manejar fechas
    if (updateProductDto.expirationDate !== undefined) {
      updateData.expirationDate = updateProductDto.expirationDate;
    }
    if (updateProductDto.periodAfterOpening !== undefined) {
      updateData.periodAfterOpening = updateProductDto.periodAfterOpening;
    }
    if (updateProductDto.openedDate !== undefined) {
      updateData.openedDate = updateProductDto.openedDate;
    }

    // Recalcular caducidad si es necesario
    if (product.isOpened && updateData.periodAfterOpening !== undefined) {
      const newExpiration = this.calculateExpirationDate(
        updateData.openedDate || product.openedDate,
        updateData.periodAfterOpening || product.periodAfterOpening,
        updateData.expirationDate !== undefined ? updateData.expirationDate : product.expirationDate
      );
      if (newExpiration) updateData.expirationDate = newExpiration;
    }

    const updated = await this.productModel
      .findByIdAndUpdate(id, updateData, { returnDocument: 'after', runValidators: false })
      .exec();

    return updated;
  }

  // eliminar producto
  async delete(id: string, userId: string): Promise<Product | null> {
    const product = await this.productModel.findById(id).exec();
    if (!product) throw new NotFoundException(`Producto ${id} no encontrado`);
    if (product.userId.toString() !== userId.toString()) {
      throw new ForbiddenException('No puedes eliminar este producto');
    }
     if (product.imageUrl) {
      const publicId = this.cloudinaryService.extractPublicIdFromUrl(product.imageUrl);
      if (publicId) {
        await this.cloudinaryService.deleteImage(publicId);
        console.log(`🗑️ Imagen eliminada de Cloudinary al borrar producto: ${publicId}`);
      }
    }
    return this.productModel.findByIdAndDelete(id).exec();
  }

  // cambiar el producto de lista
  async moveToList(id: string, userId: string, targetList: string): Promise<Product | null> {
    const product = await this.productModel.findById(id).exec();
    if (!product) throw new NotFoundException(`Producto ${id} no encontrado`);
    if (product.userId.toString() !== userId.toString()) {
      throw new ForbiddenException('No puedes mover este producto');
    }
    return this.productModel
      .findByIdAndUpdate(id, { listType: targetList }, { returnDocument: 'after' })
      .exec();
  }

  // marcar el producto como abierto y mandar a hacer el calculo de caducidad
  async markAsOpened(id: string, userId: string, customOpenedDate?: Date): Promise<Product | null> {
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
      const calculatedExpiration = this.calculateExpirationFromPeriod(openedDate, product.periodAfterOpening);     
      if (finalExpiration && calculatedExpiration) {
        finalExpiration = calculatedExpiration < finalExpiration ? calculatedExpiration : finalExpiration;
      } else if (calculatedExpiration) {
        finalExpiration = calculatedExpiration;
      }
    }
    const updated = await this.productModel
      .findByIdAndUpdate(
        id,
        { openedDate, isOpened: true, expirationDate: finalExpiration },
        { returnDocument: 'after' }
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
  async calculateExpirationFromOpening(id: string, userId: string): Promise<Product | null> {
    const product = await this.productModel.findById(id).exec();
    if (!product) throw new NotFoundException(`Producto ${id} no encontrado`);
    if (product.userId.toString() !== userId.toString()) {
      throw new ForbiddenException('No puedes modificar este producto');
    }
    if (!product.isOpened) {
      throw new BadRequestException('El producto no ha sido abierto aún');
    }
    if (!product.openedDate) {
      throw new BadRequestException('El producto no tiene fecha de apertura registrada');
    }
    if (!product.periodAfterOpening) {
      throw new BadRequestException('El producto no tiene período después de abierto definido');
    }
    const newExpiration = this.calculateExpirationDate(
      product.openedDate,
      product.periodAfterOpening,
      product.expirationDate
    );
    return this.productModel
      .findByIdAndUpdate(id, { expirationDate: newExpiration }, { returnDocument: 'after' })
      .exec();
  }

  // ver la cantidad de productos segun la lista en la que estan
  async getStats(userId: string) {
    const products = await this.productModel.find({ userId }).exec();
    const stats = { wishlist: 0, favorites: 0, have: 0, used: 0, total: products.length };
    products.forEach((product) => {
      if (stats[product.listType] !== undefined) stats[product.listType]++;
    });
    return stats;
  }

  // obtener productos caducados
  async getExpiredProducts(userId: string): Promise<Product[]> {
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    return this.productModel
      .find({ userId, expirationDate: { $lt: today }, listType: { $ne: 'deleted' } })
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
      .find({ userId, expirationDate: { $gte: today, $lte: futureDate }, listType: { $ne: 'deleted' } })
      .sort({ expirationDate: 1 })
      .exec();
  }

  // metodo para calcular la fecha de caducidad
  private calculateExpirationDate(
    baseDate: Date | null | undefined,
    period: string | null | undefined,
    fixedExpiration: Date | null | undefined
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

  private calculateExpirationFromPeriod(baseDate: Date, period: string): Date | null {
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
}