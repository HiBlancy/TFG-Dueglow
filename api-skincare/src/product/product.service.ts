// product.service.ts - VERSIÓN SIMPLIFICADA Y CORREGIDA
import { 
  Injectable, 
  NotFoundException, 
  ForbiddenException,
  ConflictException,
  BadRequestException 
} from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { Product } from './interfaces/product.interface';
import { CreateProductDto } from './dto/create-product.dto';
import { UpdateProductDto } from './dto/update-product.dto';

@Injectable()
export class ProductService {
  constructor(
    @InjectModel('Product') private readonly productModel: Model<Product>,
  ) {}

  // CREAR PRODUCTO
  async create( userId: string,  createProductDto: CreateProductDto ): Promise<Product> {
    const newProduct = new this.productModel({
      ...createProductDto,
      userId,
      listType: createProductDto.listType || 'have',
    });

    return newProduct.save();
  }

  // OBTENER TODOS LOS PRODUCTOS DEL USUARIO
  //anadir paginacion
  async findAllByUser(userId: string, listType?: string): Promise<Product[]> {
    const filter: any = { userId };
    if (listType) {
      filter.listType = listType;
    }

    return this.productModel.find(filter).sort({ createdAt: -1 }).exec();
  }

  // OBTENER UN PRODUCTO POR ID
  async findById(id: string, userId: string): Promise<Product | null> {
    const product = await this.productModel.findById(id).exec();

    if (!product) {
      return null;
    }

    if (product.userId.toString() !== userId) {
      throw new ForbiddenException('No tienes permiso para ver este producto');
    }

    return product;
  }

  // ACTUALIZAR PRODUCTO
  async update(
    id: string,
    userId: string,
    updateProductDto: UpdateProductDto,
  ): Promise<Product | null> {
    // Primero verificamos que el producto existe y pertenece al usuario
    const product = await this.productModel.findById(id).exec();

    if (!product) {
      throw new NotFoundException(`Producto ${id} no encontrado`);
    }

    if (product.userId.toString() !== userId.toString()) {
      throw new ForbiddenException('No puedes modificar este producto');
    }
    //no se puede actualizar codigo de barras, solo lo pilla de la api

    const updated = await this.productModel
      .findByIdAndUpdate(id, updateProductDto, { returnDocument: 'after' })
      .exec();

    return updated;
  }

  // ELIMINAR PRODUCTO
  async delete(id: string, userId: string): Promise<Product | null> {
    const product = await this.productModel.findById(id).exec();

    if (!product) {
      throw new NotFoundException(`Producto ${id} no encontrado`);
    }

    if (product.userId.toString() !== userId.toString()) {
      throw new ForbiddenException('No puedes eliminar este producto');
    }

    const deleted = await this.productModel.findByIdAndDelete(id).exec();
    return deleted;
  }

  // MOVER PRODUCTO ENTRE LISTAS
  async moveToList(
    id: string,
    userId: string,
    targetList: string,
  ): Promise<Product | null> {
    const product = await this.productModel.findById(id).exec();

    if (!product) {
      throw new NotFoundException(`Producto ${id} no encontrado`);
    }

    if (product.userId.toString() !== userId.toString()) {
      throw new ForbiddenException('No puedes mover este producto');
    }

    const updated = await this.productModel
      .findByIdAndUpdate(
        id,
        { listType: targetList },
        { returnDocument: 'after' },
      )
      .exec();

    return updated;
  }

  // OBTENER ESTADÍSTICAS DE LISTAS
  async getStats(userId: string) {
    const products = await this.productModel.find({ userId }).exec();

    const stats = {
      wishlist: 0,
      favorites: 0,
      have: 0,
      used: 0,
      deleted: 0,
      total: products.length,
    };

    products.forEach((product) => {
      if (stats[product.listType] !== undefined) {
        stats[product.listType]++;
      }
    });

    return stats;
  }

  // OBTENER PRODUCTOS CADUCADOS
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

  // OBTENER PRODUCTOS QUE CADUCAN PRONTO
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

  // MARCAR PRODUCTO COMO ABIERTO
  async markAsOpened(id: string, userId: string): Promise<Product | null> {
    const product = await this.productModel.findById(id).exec();

    if (!product) {
      throw new NotFoundException(`Producto ${id} no encontrado`);
    }

    // LOGS PARA DEPURACIÓN
    console.log('Product userId:', product.userId.toString());
    console.log('Request userId:', userId.toString());
    console.log(
      'Are they equal?',
      product.userId.toString() === userId.toString(),
    );

    if (product.userId.toString() !== userId.toString()) {
      throw new ForbiddenException('No puedes modificar este producto');
    }

    if (product.isOpened) {
      // CAMBIO: verificar el booleano en lugar de openedDate
      throw new BadRequestException('El producto ya está abierto');
    }

    const updated = await this.productModel
      .findByIdAndUpdate(
        id,
        {
          openedDate: new Date(),
          isOpened: true, // NUEVO: establecer booleano a true
        },
        { returnDocument: 'after' },
      )
      .exec();

    return updated;
  }

  // NUEVO MÉTODO: MARCAR PRODUCTO COMO CERRADO
  async markAsClosed(id: string, userId: string): Promise<Product | null> {
    const product = await this.productModel.findById(id).exec();

    if (!product) {
      throw new NotFoundException(`Producto ${id} no encontrado`);
    }

    if (product.userId.toString() !== userId.toString()) {
      throw new ForbiddenException('No puedes modificar este producto');
    }

    if (!product.isOpened) {
      throw new BadRequestException('El producto no está abierto');
    }

    const updated = await this.productModel
      .findByIdAndUpdate(
        id,
        {
          isOpened: false, // Solo resetear el booleano, mantener openedDate para historial
        },
        { returnDocument: 'after' },
      )
      .exec();

    return updated;
  }

  // CALCULAR CADUCIDAD DESDE APERTURA
  async calculateExpirationFromOpening(
    id: string,
    userId: string,
  ): Promise<Product | null> {
    const product = await this.productModel.findById(id).exec();

    if (!product) {
      throw new NotFoundException(`Producto ${id} no encontrado`);
    }

    if (product.userId.toString() !== userId.toString()) {
      throw new ForbiddenException('No puedes modificar este producto');
    }

    if (!product.isOpened) {
      throw new BadRequestException('El producto no ha sido abierto aún');
    }

    // Verificar explícitamente que openedDate existe
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

    const months = parseInt(product.periodAfterOpening);
    if (isNaN(months)) {
      throw new BadRequestException('Período después de abierto inválido');
    }

    const expirationDate = new Date(product.openedDate);
    expirationDate.setMonth(expirationDate.getMonth() + months);

    const updated = await this.productModel
      .findByIdAndUpdate(id, { expirationDate }, { returnDocument: 'after' })
      .exec();

    return updated;
  }
}