import {
  Injectable,
  NotFoundException,
  ForbiddenException,
  BadRequestException,
} from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { Routine } from './interfaces/routine.interface';
import { CreateRoutineDto } from './dto/create-routine.dto';
import { UpdateRoutineDto } from './dto/update-routine.dto';
import { ReorderProductsDto } from './dto/reorder-products.dto';
import { Product } from '../product/interfaces/product.interface';

@Injectable()
export class RoutineService {
  constructor(
    @InjectModel('Routine') private readonly routineModel: Model<Routine>,
    @InjectModel('Product') private readonly productModel: Model<Product>,
  ) {}

  private toOrderedProducts(productIds: string[]) {
    // Convierte ["id1","id2"] => [{productId:"id1", order:0}, ...]
    return (productIds || []).map((productId, index) => ({
      productId,
      order: index,
    }));
  }

  // Crea una rutina y guarda los productos con orden (0..n)
  async create(
    userId: string,
    createRoutineDto: CreateRoutineDto,
  ): Promise<Routine> {
    if (createRoutineDto.products && createRoutineDto.products.length > 0) {
      await this.validateProducts(userId, createRoutineDto.products);
    }

    const productsWithOrder = this.toOrderedProducts(
      createRoutineDto.products || [],
    );

    const newRoutine = new this.routineModel({
      ...createRoutineDto,
      userId,
      products: productsWithOrder,
    });

    return newRoutine.save();
  }

  // obtiene las rutinas del usuario
  async findAllByUser(userId: string): Promise<Routine[]> {
    return this.routineModel
      .find({ userId })
      .populate('products.productId')
      .sort({ createdAt: -1 })
      .exec();
  }

  // encontrar rutina por id, validando antes que pertenezca al usuario
  async findById(id: string, userId: string): Promise<Routine | null> {
    try {
      const routine = await this.routineModel
        .findById(id)
        .populate('products.productId')
        .exec();
      if (!routine) return null;
      if (routine.userId.toString() !== userId.toString()) {
        throw new ForbiddenException(
          'No tienes permiso para acceder a esta rutina',
        );
      }
      return routine;
    } catch (error) {
      throw new NotFoundException(`Rutina ${id} no encontrada`);
    }
  }

  // actualizar rutina
  async update(
    id: string,
    userId: string,
    updateRoutineDto: UpdateRoutineDto,
  ): Promise<Routine> {
    try {
      const routine = await this.routineModel.findById(id).exec();
      if (!routine) throw new NotFoundException(`Rutina ${id} no encontrada`);
      if (routine.userId.toString() !== userId.toString())
        throw new ForbiddenException();

      const updateData = Object.fromEntries(
        Object.entries(updateRoutineDto).filter(([_, v]) => v !== undefined),
      );

      if (updateData.products && Array.isArray(updateData.products)) {
        const productIds = updateData.products;
        updateData.products = this.toOrderedProducts(productIds);
        await this.validateProducts(userId, productIds);
      }

      const updated = await this.routineModel
        .findByIdAndUpdate(id, updateData, { returnDocument: 'after' })
        .populate('products.productId')
        .exec();
      if (!updated)
        throw new NotFoundException(
          `Rutina ${id} no encontrada después de actualizar`,
        );
      return updated;
    } catch (error) {
      throw new NotFoundException(`Rutina ${id} no encontrada`);
    }
  }

  // eliminar rutina
  async delete(id: string, userId: string): Promise<Routine> {
    const routine = await this.routineModel.findById(id).exec();
    if (!routine) throw new NotFoundException(`Rutina ${id} no encontrada`);
    if (routine.userId.toString() !== userId.toString())
      throw new ForbiddenException(
        'No tienes permiso para eliminar esta rutina',
      );

    const deleted = await this.routineModel.findByIdAndDelete(id).exec();
    if (!deleted)
      throw new NotFoundException(`Rutina ${id} no encontrada al eliminar`);

    return deleted;
  }

  //reorganizar los productos de una rutina
  async reorderProducts(
    id: string,
    userId: string,
    reorderDto: ReorderProductsDto,
  ): Promise<Routine> {
    try {
      const routine = await this.routineModel.findById(id).exec();
      if (!routine) throw new NotFoundException(`Rutina ${id} no encontrada`);
      if (routine.userId.toString() !== userId.toString())
        throw new ForbiddenException();

      const productIds = reorderDto.products.map((p) => p.productId);
      await this.validateProducts(userId, productIds);

      const updated = await this.routineModel
        .findByIdAndUpdate(
          id,
          { products: reorderDto.products },
          { returnDocument: 'after' },
        )
        .populate('products.productId')
        .exec();
      if (!updated) throw new NotFoundException();
      return updated;
    } catch (error) {
      throw new NotFoundException(`Rutina ${id} no encontrada`);
    }
  }

  // anadir producto a la rutina
  async addProduct(
    id: string,
    userId: string,
    productId: string,
  ): Promise<Routine> {
    const routine = await this.routineModel.findById(id).exec();
    if (!routine) {
      throw new NotFoundException(`Rutina ${id} no encontrada`);
    }

    if (routine.userId.toString() !== userId.toString()) {
      throw new ForbiddenException(
        'No tienes permiso para actualizar esta rutina',
      );
    }

    await this.validateProducts(userId, [productId]);

    const alreadyExists = routine.products.some(
      (p) => p.productId.toString() === productId,
    );
    if (alreadyExists) {
      throw new BadRequestException('Este producto ya está en la rutina');
    }

    const nextOrder =
      routine.products.length > 0
        ? Math.max(...routine.products.map((p) => p.order)) + 1
        : 0;

    routine.products.push({
      productId: productId as any,
      order: nextOrder,
    });
    await routine.save();

    const populatedRoutine = await this.routineModel
      .findById(id)
      .populate('products.productId')
      .exec();

    if (!populatedRoutine) {
      throw new NotFoundException(
        `Rutina ${id} no encontrada después de agregar producto`,
      );
    }

    return populatedRoutine;
  }

  // quitar un producto de la rutina y reordenar los restantes
  async removeProduct(
    id: string,
    userId: string,
    productId: string,
  ): Promise<Routine> {
    let routine;
    try {
      routine = await this.routineModel.findById(id).exec();
    } catch (error) {
      throw new NotFoundException(`Rutina ${id} no encontrada`);
    }

    if (!routine) {
      throw new NotFoundException(`Rutina ${id} no encontrada`);
    }

    if (routine.userId.toString() !== userId.toString()) {
      throw new ForbiddenException(
        'No tienes permiso para modificar esta rutina',
      );
    }

    const productExists = routine.products.some(
      (p) => p.productId.toString() === productId,
    );
    if (!productExists) {
      throw new BadRequestException(
        `El producto ${productId} no pertenece a esta rutina`,
      );
    }

    routine.products = routine.products
      .filter((p) => p.productId.toString() !== productId)
      .map((p, index) => ({
        productId: p.productId,
        order: index,
      }));

    await routine.save();

    const populatedRoutine = await this.routineModel
      .findById(id)
      .populate('products.productId')
      .exec();

    if (!populatedRoutine) {
      throw new NotFoundException(
        `Rutina ${id} no encontrada después de eliminar producto`,
      );
    }

    return populatedRoutine;
  }

  // valida que los productos son del usuario
  private async validateProducts(
    userId: string,
    productIds: string[],
  ): Promise<void> {
    if (productIds.length === 0) return;

    const products = await this.productModel
      .find({ _id: { $in: productIds }, userId })
      .exec();

    if (products.length !== productIds.length) {
      throw new NotFoundException('Uno o más productos no existen');
    }
  }
}
