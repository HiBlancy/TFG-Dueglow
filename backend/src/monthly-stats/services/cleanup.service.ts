import { Injectable, Logger } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { Cron } from '@nestjs/schedule';
import { CloudinaryService } from '../../cloudinary/cloudinary.service';
import { Product } from '../../product/interfaces/product.interface';
import { ProductService } from '../../product/product.service';

@Injectable()
export class CleanupService {
  private readonly logger = new Logger(CleanupService.name);

  constructor(
    @InjectModel('Product') private readonly productModel: Model<Product>,
    private readonly productService: ProductService,
    private readonly cloudinaryService: CloudinaryService,
  ) {}

  // CRON: se ejecuta el primer dia del mes a las 00:00
  // Guarda los productos usados del MES ANTERIOR y los elimina
  @Cron('0 0 1 * *')
  async cleanupUsedProducts(): Promise<void> {
    await this.executeCleanup(false); // false = mes anterior
  }

  // logica comun para la limpieza
  private async executeCleanup(useCurrentMonth: boolean): Promise<void> {
    try {
      const now = new Date();
      let year: number;
      let month: number; // 1-12

      if (useCurrentMonth) {
        year = now.getFullYear();
        month = now.getMonth() + 1;
      } else {
        // Mes anterior
        if (now.getMonth() === 0) {
          year = now.getFullYear() - 1;
          month = 12;
        } else {
          year = now.getFullYear();
          month = now.getMonth();
        }
      }

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
        return;
      }

      for (const userData of usersWithUsed) {
        const userId = userData._id.toString();
        const count = userData.productIds.length;
        const imageUrls = userData.imageUrls.filter(
          (url: string | null) => url != null,
        );

        await this.productService.updateOrCreateMonthlyStats(
          userId,
          year,
          month,
          count,
        );

        for (const url of imageUrls) {
          const publicId = this.cloudinaryService.extractPublicIdFromUrl(url);
          if (publicId) {
            try {
              await this.cloudinaryService.deleteImage(publicId);
            } catch (err: any) {
              this.logger.warn(
                `Error eliminando imagen ${publicId}: ${err.message}`,
              );
            }
          }
        }

        await this.productModel.deleteMany({
          _id: { $in: userData.productIds },
        });
      }

    } catch (error) {
      throw error; // Para que el método de pruebas pueda capturarlo
    }
  }
}
