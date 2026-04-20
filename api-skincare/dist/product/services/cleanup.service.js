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
var CleanupService_1;
Object.defineProperty(exports, "__esModule", { value: true });
exports.CleanupService = void 0;
const common_1 = require("@nestjs/common");
const mongoose_1 = require("@nestjs/mongoose");
const mongoose_2 = require("mongoose");
const schedule_1 = require("@nestjs/schedule");
const cloudinary_service_1 = require("../../cloudinary/cloudinary.service");
let CleanupService = CleanupService_1 = class CleanupService {
    productModel;
    monthlyStatsModel;
    cloudinaryService;
    logger = new common_1.Logger(CleanupService_1.name);
    constructor(productModel, monthlyStatsModel, cloudinaryService) {
        this.productModel = productModel;
        this.monthlyStatsModel = monthlyStatsModel;
        this.cloudinaryService = cloudinaryService;
    }
    async cleanupUsedProducts() {
        this.logger.log('🧹 Iniciando limpieza mensual de productos usados');
        const now = new Date();
        const prevMonth = now.getMonth() === 0 ? 12 : now.getMonth();
        const prevYear = now.getMonth() === 0 ? now.getFullYear() - 1 : now.getFullYear();
        try {
            const usersWithUsed = await this.productModel.aggregate([
                { $match: { listType: 'used' } },
                {
                    $group: {
                        _id: '$userId',
                        productIds: { $push: '$_id' },
                        imageUrls: { $push: '$imageUrl' },
                    },
                },
            ]);
            if (usersWithUsed.length === 0) {
                this.logger.log('No hay productos usados para limpiar este mes');
                return;
            }
            for (const userData of usersWithUsed) {
                const userId = userData._id;
                const count = userData.productIds.length;
                const imageUrls = userData.imageUrls.filter((url) => url != null);
                await this.monthlyStatsModel.findOneAndUpdate({
                    userId,
                    year: prevYear,
                    month: prevMonth,
                }, {
                    $inc: { productsUsedCount: count },
                    $set: { archivedAt: new Date() },
                }, { upsert: true });
                for (const url of imageUrls) {
                    const publicId = this.cloudinaryService.extractPublicIdFromUrl(url);
                    if (publicId) {
                        try {
                            await this.cloudinaryService.deleteImage(publicId);
                            this.logger.debug(`Imagen eliminada: ${publicId}`);
                        }
                        catch (err) {
                            this.logger.warn(`No se pudo eliminar imagen ${publicId}: ${err.message}`);
                        }
                    }
                }
                await this.productModel.deleteMany({
                    _id: { $in: userData.productIds },
                });
                this.logger.log(`Usuario ${userId}: ${count} productos usados del mes ${prevMonth}/${prevYear} eliminados`);
            }
            this.logger.log('✅ Limpieza mensual completada');
        }
        catch (error) {
            this.logger.error(`❌ Error en limpieza mensual: ${error.message}`, error.stack);
        }
    }
    async forceCleanup() {
        await this.cleanupUsedProducts();
        return { success: true };
    }
};
exports.CleanupService = CleanupService;
__decorate([
    (0, schedule_1.Cron)(schedule_1.CronExpression.FIRST_DAY_OF_MONTH_MIDNIGHT),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", Promise)
], CleanupService.prototype, "cleanupUsedProducts", null);
exports.CleanupService = CleanupService = CleanupService_1 = __decorate([
    (0, common_1.Injectable)(),
    __param(0, (0, mongoose_1.InjectModel)('Product')),
    __param(1, (0, mongoose_1.InjectModel)('MonthlyStats')),
    __metadata("design:paramtypes", [mongoose_2.Model,
        mongoose_2.Model,
        cloudinary_service_1.CloudinaryService])
], CleanupService);
//# sourceMappingURL=cleanup.service.js.map