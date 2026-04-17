"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
var __param = (this && this.__param) || function (paramIndex, decorator) {
    return function (target, key) { decorator(target, key, paramIndex); }
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.RoutineService = void 0;
const common_1 = require("@nestjs/common");
const mongoose_1 = require("@nestjs/mongoose");
const mongoose_2 = require("mongoose");
let RoutineService = class RoutineService {
    routineModel;
    productModel;
    constructor(routineModel, productModel) {
        this.routineModel = routineModel;
        this.productModel = productModel;
    }
    async create(userId, createRoutineDto) {
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
    async findAllByUser(userId) {
        return this.routineModel
            .find({ userId })
            .populate('products.productId')
            .sort({ createdAt: -1 })
            .exec();
    }
    async findById(id, userId) {
        const routine = await this.routineModel
            .findById(id)
            .populate('products.productId')
            .exec();
        if (!routine)
            return null;
        if (routine.userId.toString() !== userId.toString()) {
            throw new common_1.ForbiddenException('No tienes permiso para acceder a esta rutina');
        }
        return routine;
    }
    async update(id, userId, updateRoutineDto) {
        console.log('1. Iniciando update');
        const routine = await this.routineModel.findById(id).exec();
        console.log('2. Routine encontrada?', !!routine);
        if (!routine)
            throw new common_1.NotFoundException(`Rutina ${id} no encontrada`);
        if (routine.userId.toString() !== userId.toString())
            throw new common_1.ForbiddenException();
        const updateData = {};
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
            throw new common_1.NotFoundException(`Rutina ${id} no encontrada después de actualizar`);
        console.log('5. Retornando resultado');
        return result;
    }
    async delete(id, userId) {
        const routine = await this.routineModel.findById(id).exec();
        if (!routine) {
            throw new common_1.NotFoundException(`Rutina ${id} no encontrada`);
        }
        if (routine.userId.toString() !== userId.toString()) {
            throw new common_1.ForbiddenException('No tienes permiso para eliminar esta rutina');
        }
        const deleted = await this.routineModel.findByIdAndDelete(id).exec();
        if (!deleted) {
            throw new common_1.NotFoundException(`Rutina ${id} no encontrada al eliminar`);
        }
        return deleted;
    }
    async reorderProducts(id, userId, reorderDto) {
        const routine = await this.routineModel.findById(id).exec();
        if (!routine) {
            throw new common_1.NotFoundException(`Rutina ${id} no encontrada`);
        }
        if (routine.userId.toString() !== userId.toString()) {
            throw new common_1.ForbiddenException('No tienes permiso para actualizar esta rutina');
        }
        const productIds = reorderDto.products.map((p) => p.productId);
        await this.validateProducts(userId, productIds);
        const orders = reorderDto.products
            .map((p) => p.order)
            .sort((a, b) => a - b);
        for (let i = 0; i < orders.length; i++) {
            if (orders[i] !== i) {
                throw new common_1.BadRequestException('Los órdenes deben ser secuenciales comenzando desde 0');
            }
        }
        const updated = await this.routineModel
            .findByIdAndUpdate(id, { products: reorderDto.products }, { returnDocument: 'after' })
            .populate('products.productId')
            .exec();
        if (!updated) {
            throw new common_1.NotFoundException(`Rutina ${id} no encontrada después de reordenar`);
        }
        return updated;
    }
    async addProduct(id, userId, productId) {
        const routine = await this.routineModel.findById(id).exec();
        if (!routine) {
            throw new common_1.NotFoundException(`Rutina ${id} no encontrada`);
        }
        if (routine.userId.toString() !== userId.toString()) {
            throw new common_1.ForbiddenException('No tienes permiso para actualizar esta rutina');
        }
        await this.validateProducts(userId, [productId]);
        const alreadyExists = routine.products.some((p) => p.productId.toString() === productId);
        if (alreadyExists) {
            throw new common_1.BadRequestException('Este producto ya está en la rutina');
        }
        const nextOrder = routine.products.length > 0
            ? Math.max(...routine.products.map((p) => p.order)) + 1
            : 0;
        routine.products.push({
            productId: productId,
            order: nextOrder,
        });
        await routine.save();
        const populatedRoutine = await this.routineModel
            .findById(id)
            .populate('products.productId')
            .exec();
        if (!populatedRoutine) {
            throw new common_1.NotFoundException(`Rutina ${id} no encontrada después de agregar producto`);
        }
        return populatedRoutine;
    }
    async removeProduct(id, userId, productId) {
        const routine = await this.routineModel.findById(id).exec();
        if (!routine) {
            throw new common_1.NotFoundException(`Rutina ${id} no encontrada`);
        }
        if (routine.userId.toString() !== userId.toString()) {
            throw new common_1.ForbiddenException('No tienes permiso para actualizar esta rutina');
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
            throw new common_1.NotFoundException(`Rutina ${id} no encontrada después de eliminar producto`);
        }
        return populatedRoutine;
    }
    async validateProducts(userId, productIds) {
        if (productIds.length === 0)
            return;
        const products = await this.productModel
            .find({ _id: { $in: productIds }, userId })
            .exec();
        if (products.length !== productIds.length) {
            throw new common_1.BadRequestException('Uno o más productos no existen o no te pertenecen');
        }
    }
};
exports.RoutineService = RoutineService;
exports.RoutineService = RoutineService = __decorate([
    (0, common_1.Injectable)(),
    __param(0, (0, mongoose_1.InjectModel)('Routine')),
    __param(1, (0, mongoose_1.InjectModel)('Product')),
    __metadata("design:paramtypes", [mongoose_2.Model, Object])
], RoutineService);
//# sourceMappingURL=routine.service.js.map