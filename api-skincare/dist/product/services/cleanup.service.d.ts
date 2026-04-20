import { Model } from 'mongoose';
import { CloudinaryService } from '../../cloudinary/cloudinary.service';
export declare class CleanupService {
    private readonly productModel;
    private readonly monthlyStatsModel;
    private readonly cloudinaryService;
    private readonly logger;
    constructor(productModel: Model<any>, monthlyStatsModel: Model<any>, cloudinaryService: CloudinaryService);
    cleanupUsedProducts(): Promise<void>;
    forceCleanup(): Promise<{
        success: boolean;
    }>;
}
