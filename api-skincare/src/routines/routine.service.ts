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

@Injectable()
export class RoutineService {
  constructor(
    @InjectModel('Routine') private readonly routineModel: Model<Routine>,
    @InjectModel('Product') private readonly productModel: any,
  ) {}

  async create(
    userId: string,
    createRoutineDto: CreateRoutineDto,
  ): Promise<Routine> {
    if (createRoutineDto.products && createRoutineDto.products.length > 0) {
      const productIds = createRoutineDto.products.map((p) => p.productId);
      await this.validateProducts(userId, productIds);
    }

    const newRoutine = new this.routineModel({
      ...createRoutineDto,
      userId,
      products: createRoutineDto.products || [],
    });

    return newRoutine.save();
  }

  async findAllByUser(userId: string): Promise<Routine[]> {
    return this.routineModel
      .find({ userId })
      .populate('products.productId')
      .sort({ createdAt: -1 })
      .exec();
  }

  async findById(id: string, userId: string): Promise<Routine | null> {
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
  }

  async update(
    id: string,
    userId: string,
    updateRoutineDto: UpdateRoutineDto,
  ): Promise<any> {
    console.log('1. Iniciando update');
    const routine = await this.routineModel.findById(id).exec();
    console.log('2. Routine encontrada?', !!routine);
    if (!routine) throw new NotFoundException(`Rutina ${id} no encontrada`);
    if (routine.userId.toString() !== userId.toString())
      throw new ForbiddenException();

    const updateData: any = {};
    if (updateRoutineDto.name !== undefined)
      updateData.name = updateRoutineDto.name;
    if (updateRoutineDto.time !== undefined)
      updateData.time = updateRoutineDto.time;
    if (updateRoutineDto.daysOfWeek !== undefined)
      updateData.daysOfWeek = updateRoutineDto.daysOfWeek;
    if (updateRoutineDto.products !== undefined)
      updateData.products = updateRoutineDto.products;

    console.log('3. updateData:', updateData);
    const result = await this.routineModel
      .findByIdAndUpdate(id, updateData, { new: true })
      .exec();
    console.log('4. Resultado de findByIdAndUpdate:', result);

    if (!result)
      throw new NotFoundException(
        `Rutina ${id} no encontrada después de actualizar`,
      );
    console.log('5. Retornando resultado');
    return result;
  }

  async delete(id: string, userId: string): Promise<Routine> {
    const routine = await this.routineModel.findById(id).exec();

    if (!routine) {
      throw new NotFoundException(`Rutina ${id} no encontrada`);
    }

    if (routine.userId.toString() !== userId.toString()) {
      throw new ForbiddenException(
        'No tienes permiso para eliminar esta rutina',
      );
    }

    const deleted = await this.routineModel.findByIdAndDelete(id).exec();

    if (!deleted) {
      throw new NotFoundException(`Rutina ${id} no encontrada al eliminar`);
    }

    return deleted;
  }

  async reorderProducts(
    id: string,
    userId: string,
    reorderDto: ReorderProductsDto,
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

    const productIds = reorderDto.products.map((p) => p.productId);
    await this.validateProducts(userId, productIds);

    // Validar que los órdenes son secuenciales comenzando desde 0
    const orders = reorderDto.products
      .map((p) => p.order)
      .sort((a, b) => a - b);
    for (let i = 0; i < orders.length; i++) {
      if (orders[i] !== i) {
        throw new BadRequestException(
          'Los órdenes deben ser secuenciales comenzando desde 0',
        );
      }
    }

    const updated = await this.routineModel
      .findByIdAndUpdate(
        id,
        { products: reorderDto.products },
        { returnDocument: 'after' },
      )
      .populate('products.productId')
      .exec();

    if (!updated) {
      throw new NotFoundException(
        `Rutina ${id} no encontrada después de reordenar`,
      );
    }

    return updated;
  }

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

  async removeProduct(
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

  private async validateProducts(
    userId: string,
    productIds: string[],
  ): Promise<void> {
    if (productIds.length === 0) return;

    const products = await this.productModel
      .find({ _id: { $in: productIds }, userId })
      .exec();

    if (products.length !== productIds.length) {
      throw new BadRequestException(
        'Uno o más productos no existen o no te pertenecen',
      );
    }
  }
}
