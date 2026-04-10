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

@Injectable()
export class ProductService {
  constructor(
    @InjectModel('Product') private readonly productModel: Model<Product>,
  ) {}

  // ==================== MÉTODOS PRINCIPALES ====================

  async create(userId: string, createProductDto: CreateProductDto): Promise<Product> {
    const newProduct = new this.productModel({
      ...createProductDto,
      userId,
      listType: createProductDto.listType || 'have',
    });
    return newProduct.save();
  }

  async findAllByUser(userId: string, listType?: string): Promise<Product[]> {
    const filter: any = { userId };
    if (listType) filter.listType = listType;
    return this.productModel.find(filter).sort({ createdAt: -1 }).exec();
  }

  async findById(id: string, userId: string): Promise<Product | null> {
    const product = await this.productModel.findById(id).exec();
    if (!product) return null;
    if (product.userId.toString() !== userId) {
      throw new ForbiddenException('No tienes permiso para ver este producto');
    }
    return product;
  }

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

  async delete(id: string, userId: string): Promise<Product | null> {
    const product = await this.productModel.findById(id).exec();
    if (!product) throw new NotFoundException(`Producto ${id} no encontrado`);
    if (product.userId.toString() !== userId.toString()) {
      throw new ForbiddenException('No puedes eliminar este producto');
    }
    return this.productModel.findByIdAndDelete(id).exec();
  }

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

  // ==================== MÉTODOS DE CADUCIDAD ====================

  async markAsOpened(id: string, userId: string, customOpenedDate?: Date): Promise<Product | null> {
    const product = await this.productModel.findById(id).exec();
    if (!product) throw new NotFoundException(`Producto ${id} no encontrado`);
    if (product.userId.toString() !== userId.toString()) {
      throw new ForbiddenException('No puedes modificar este producto');
    }
    if (product.isOpened) {
      throw new BadRequestException('El producto ya está abierto');
    }

    // 2. AQUÍ ESTÁ LA MAGIA: Usamos la fecha enviada, o la de hoy si no viene nada
    const openedDate = customOpenedDate || new Date();
    
    let finalExpiration = product.expirationDate;

    // Si tiene periodo después de abrir, calcular nueva fecha
    if (product.periodAfterOpening) {
      const calculatedExpiration = this.calculateExpirationFromPeriod(openedDate, product.periodAfterOpening);
      
      // Si tiene fecha fija, tomar la que ocurra PRIMERO
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

  // ==================== MÉTODOS DE ESTADÍSTICAS ====================

  async getStats(userId: string) {
    const products = await this.productModel.find({ userId }).exec();
    const stats = { wishlist: 0, favorites: 0, have: 0, used: 0, deleted: 0, total: products.length };
    products.forEach((product) => {
      if (stats[product.listType] !== undefined) stats[product.listType]++;
    });
    return stats;
  }

  async getExpiredProducts(userId: string): Promise<Product[]> {
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    return this.productModel
      .find({ userId, expirationDate: { $lt: today }, listType: { $ne: 'deleted' } })
      .sort({ expirationDate: 1 })
      .exec();
  }

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

  // ==================== MÉTODOS PRIVADOS DE AYUDA ====================

  private calculateExpirationDate(
    baseDate: Date | null | undefined,
    period: string | null | undefined,
    fixedExpiration: Date | null | undefined
  ): Date | null {
    if (!baseDate || !period) return fixedExpiration || null;

    const calculated = this.calculateExpirationFromPeriod(baseDate, period);
    if (!calculated) return fixedExpiration || null;

    // Si tiene fecha fija, tomar la que ocurra PRIMERO
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

  private parsePeriodToMonths(period: string): number | null {
    if (!period) return null;
    
    const cleaned = period.trim().toUpperCase();
    
    // Formato "12M"
    const mMatch = cleaned.match(/^(\d+)\s*M$/);
    if (mMatch) return parseInt(mMatch[1]);
    
    // Formato "6 meses" o "12 MESES"
    const monthMatch = cleaned.match(/^(\d+)\s*MES(?:ES)?$/);
    if (monthMatch) return parseInt(monthMatch[1]);
    
    // Solo número "12"
    const numberMatch = cleaned.match(/^(\d+)$/);
    if (numberMatch) return parseInt(numberMatch[1]);
    
    return null;
  }

  // En product.service.ts

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
}