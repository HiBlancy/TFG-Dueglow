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
exports.ProductService = void 0;
const common_1 = require("@nestjs/common");
const mongoose_1 = require("@nestjs/mongoose");
const mongoose_2 = require("mongoose");
let ProductService = class ProductService {
    productModel;
    constructor(productModel) {
        this.productModel = productModel;
    }
    async create(userId, createProductDto) {
        const newProduct = new this.productModel({
            ...createProductDto,
            userId,
            listType: createProductDto.listType || 'have',
        });
        return newProduct.save();
    }
    async findAllByUser(userId, listType) {
        const filter = { userId };
        if (listType)
            filter.listType = listType;
        return this.productModel.find(filter).sort({ createdAt: -1 }).exec();
    }
    async findById(id, userId) {
        const product = await this.productModel.findById(id).exec();
        if (!product)
            return null;
        if (product.userId.toString() !== userId) {
            throw new common_1.ForbiddenException('No tienes permiso para ver este producto');
        }
        return product;
    }
    async update(id, userId, updateProductDto) {
        const product = await this.productModel.findById(id).exec();
        if (!product)
            throw new common_1.NotFoundException(`Producto ${id} no encontrado`);
        if (product.userId.toString() !== userId.toString()) {
            throw new common_1.ForbiddenException('No puedes modificar este producto');
        }
        const updateData = {};
        const fields = ['name', 'brand', 'imageUrl', 'barcode', 'categories', 'notes', 'rating', 'listType', 'isOpened'];
        for (const field of fields) {
            if (updateProductDto[field] !== undefined) {
                updateData[field] = updateProductDto[field];
            }
        }
        if (updateProductDto.expirationDate !== undefined) {
            updateData.expirationDate = updateProductDto.expirationDate;
        }
        if (updateProductDto.periodAfterOpening !== undefined) {
            updateData.periodAfterOpening = updateProductDto.periodAfterOpening;
        }
        if (updateProductDto.openedDate !== undefined) {
            updateData.openedDate = updateProductDto.openedDate;
        }
        if (product.isOpened && updateData.periodAfterOpening !== undefined) {
            const newExpiration = this.calculateExpirationDate(updateData.openedDate || product.openedDate, updateData.periodAfterOpening || product.periodAfterOpening, updateData.expirationDate !== undefined ? updateData.expirationDate : product.expirationDate);
            if (newExpiration)
                updateData.expirationDate = newExpiration;
        }
        const updated = await this.productModel
            .findByIdAndUpdate(id, updateData, { returnDocument: 'after', runValidators: false })
            .exec();
        return updated;
    }
    async delete(id, userId) {
        const product = await this.productModel.findById(id).exec();
        if (!product)
            throw new common_1.NotFoundException(`Producto ${id} no encontrado`);
        if (product.userId.toString() !== userId.toString()) {
            throw new common_1.ForbiddenException('No puedes eliminar este producto');
        }
        return this.productModel.findByIdAndDelete(id).exec();
    }
    async moveToList(id, userId, targetList) {
        const product = await this.productModel.findById(id).exec();
        if (!product)
            throw new common_1.NotFoundException(`Producto ${id} no encontrado`);
        if (product.userId.toString() !== userId.toString()) {
            throw new common_1.ForbiddenException('No puedes mover este producto');
        }
        return this.productModel
            .findByIdAndUpdate(id, { listType: targetList }, { returnDocument: 'after' })
            .exec();
    }
    async markAsOpened(id, userId, customOpenedDate) {
        const product = await this.productModel.findById(id).exec();
        if (!product)
            throw new common_1.NotFoundException(`Producto ${id} no encontrado`);
        if (product.userId.toString() !== userId.toString()) {
            throw new common_1.ForbiddenException('No puedes modificar este producto');
        }
        if (product.isOpened) {
            throw new common_1.BadRequestException('El producto ya está abierto');
        }
        const openedDate = customOpenedDate || new Date();
        let finalExpiration = product.expirationDate;
        if (product.periodAfterOpening) {
            const calculatedExpiration = this.calculateExpirationFromPeriod(openedDate, product.periodAfterOpening);
            if (finalExpiration && calculatedExpiration) {
                finalExpiration = calculatedExpiration < finalExpiration ? calculatedExpiration : finalExpiration;
            }
            else if (calculatedExpiration) {
                finalExpiration = calculatedExpiration;
            }
        }
        const updated = await this.productModel
            .findByIdAndUpdate(id, { openedDate, isOpened: true, expirationDate: finalExpiration }, { returnDocument: 'after' })
            .exec();
        return updated;
    }
    async markAsClosed(id, userId) {
        const product = await this.productModel.findById(id).exec();
        if (!product)
            throw new common_1.NotFoundException(`Producto ${id} no encontrado`);
        if (product.userId.toString() !== userId.toString()) {
            throw new common_1.ForbiddenException('No puedes modificar este producto');
        }
        if (!product.isOpened) {
            throw new common_1.BadRequestException('El producto no está abierto');
        }
        return this.productModel
            .findByIdAndUpdate(id, { isOpened: false }, { returnDocument: 'after' })
            .exec();
    }
    async calculateExpirationFromOpening(id, userId) {
        const product = await this.productModel.findById(id).exec();
        if (!product)
            throw new common_1.NotFoundException(`Producto ${id} no encontrado`);
        if (product.userId.toString() !== userId.toString()) {
            throw new common_1.ForbiddenException('No puedes modificar este producto');
        }
        if (!product.isOpened) {
            throw new common_1.BadRequestException('El producto no ha sido abierto aún');
        }
        if (!product.openedDate) {
            throw new common_1.BadRequestException('El producto no tiene fecha de apertura registrada');
        }
        if (!product.periodAfterOpening) {
            throw new common_1.BadRequestException('El producto no tiene período después de abierto definido');
        }
        const newExpiration = this.calculateExpirationDate(product.openedDate, product.periodAfterOpening, product.expirationDate);
        return this.productModel
            .findByIdAndUpdate(id, { expirationDate: newExpiration }, { returnDocument: 'after' })
            .exec();
    }
    async getStats(userId) {
        const products = await this.productModel.find({ userId }).exec();
        const stats = { wishlist: 0, favorites: 0, have: 0, used: 0, deleted: 0, total: products.length };
        products.forEach((product) => {
            if (stats[product.listType] !== undefined)
                stats[product.listType]++;
        });
        return stats;
    }
    async getExpiredProducts(userId) {
        const today = new Date();
        today.setHours(0, 0, 0, 0);
        return this.productModel
            .find({ userId, expirationDate: { $lt: today }, listType: { $ne: 'deleted' } })
            .sort({ expirationDate: 1 })
            .exec();
    }
    async getExpiringSoon(userId, days = 30) {
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
    calculateExpirationDate(baseDate, period, fixedExpiration) {
        if (!baseDate || !period)
            return fixedExpiration || null;
        const calculated = this.calculateExpirationFromPeriod(baseDate, period);
        if (!calculated)
            return fixedExpiration || null;
        if (fixedExpiration) {
            const fixed = new Date(fixedExpiration);
            return calculated < fixed ? calculated : fixed;
        }
        return calculated;
    }
    calculateExpirationFromPeriod(baseDate, period) {
        const months = this.parsePeriodToMonths(period);
        if (!months)
            return null;
        const expiration = new Date(baseDate);
        expiration.setMonth(expiration.getMonth() + months);
        return expiration;
    }
    parsePeriodToMonths(period) {
        if (!period)
            return null;
        const cleaned = period.trim().toUpperCase();
        const mMatch = cleaned.match(/^(\d+)\s*M$/);
        if (mMatch)
            return parseInt(mMatch[1]);
        const monthMatch = cleaned.match(/^(\d+)\s*MES(?:ES)?$/);
        if (monthMatch)
            return parseInt(monthMatch[1]);
        const numberMatch = cleaned.match(/^(\d+)$/);
        if (numberMatch)
            return parseInt(numberMatch[1]);
        return null;
    }
    async findAllByUserPaginated(userId, paginationDto, listType) {
        const { page, limit } = paginationDto;
        const skip = (page - 1) * limit;
        const filter = { userId };
        if (listType)
            filter.listType = listType;
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
};
exports.ProductService = ProductService;
exports.ProductService = ProductService = __decorate([
    (0, common_1.Injectable)(),
    __param(0, (0, mongoose_1.InjectModel)('Product')),
    __metadata("design:paramtypes", [mongoose_2.Model])
], ProductService);
//# sourceMappingURL=product.service.js.map