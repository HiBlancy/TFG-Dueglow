import { Model } from 'mongoose';
import { Product } from './interfaces/product.interface';
import { CreateProductDto } from './dto/create-product.dto';
import { UpdateProductDto } from './dto/update-product.dto';
import { PaginationDto } from '../pagination/pagination.dto';
import { CloudinaryService } from 'src/cloudinary/cloudinary.service';
import { ImageCompressionService } from 'src/services/image-compression.service';
export declare class ProductService {
    private readonly productModel;
    private readonly cloudinaryService;
    private readonly imageCompressionService;
    constructor(productModel: Model<Product>, cloudinaryService: CloudinaryService, imageCompressionService: ImageCompressionService);
    create(userId: string, createProductDto: CreateProductDto): Promise<Product>;
    findAllByUserPaginated(userId: string, paginationDto: PaginationDto, listType?: string): Promise<{
        data: (import("mongoose").Document<unknown, {}, Product, {}, import("mongoose").DefaultSchemaOptions> & Product & Required<{
            _id: string;
        }> & {
            __v: number;
        } & {
            id: string;
        })[];
        info: {
            totalProducts: number;
            totalPages: number;
            page: number;
            limit: number;
        };
    }>;
    findById(id: string, userId: string): Promise<Product | null>;
    update(id: string, userId: string, updateProductDto: UpdateProductDto): Promise<Product | null>;
    delete(id: string, userId: string): Promise<Product | null>;
    moveToList(id: string, userId: string, targetList: string): Promise<Product | null>;
    markAsOpened(id: string, userId: string, customOpenedDate?: Date): Promise<Product | null>;
    markAsClosed(id: string, userId: string): Promise<Product | null>;
    calculateExpirationFromOpening(id: string, userId: string): Promise<Product | null>;
    getStats(userId: string): Promise<{
        wishlist: number;
        favorites: number;
        have: number;
        used: number;
        deleted: number;
        total: number;
    }>;
    getExpiredProducts(userId: string): Promise<Product[]>;
    getExpiringSoon(userId: string, days?: number): Promise<Product[]>;
    private calculateExpirationDate;
    private calculateExpirationFromPeriod;
    private parsePeriodToMonths;
}
