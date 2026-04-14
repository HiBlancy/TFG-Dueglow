// products/products.controller.ts
import {
  Controller,
  Get,
  Post,
  Patch,
  Delete,
  Body,
  Param,
  Query,
  UseGuards,
  Req,
  BadRequestException,
  NotFoundException,
  UseInterceptors,
  UploadedFile,
} from '@nestjs/common';
import { ProductService } from './product.service';
import { CreateProductDto } from './dto/create-product.dto';
import { UpdateProductDto } from './dto/update-product.dto';
import { MoveProductDto } from './dto/move-product.dto';
import { AuthGuard } from '../users/guards/auth.guard';
import { PaginationDto } from '../pagination/pagination.dto';
import { CloudinaryService } from '../cloudinary/cloudinary.service';
import { ImageCompressionService } from '../services/image-compression.service';
import { FileInterceptor } from '@nestjs/platform-express';

@Controller('products')
@UseGuards(AuthGuard)
export class ProductController {
  constructor(
    private readonly productService: ProductService,
    private readonly cloudinaryService: CloudinaryService,
    private readonly imageCompressionService: ImageCompressionService,
  ) { }

  private successResponse(message: string, data: any = null) {
    return { status: true, message, data };
  }

  // crear producto
  @Post()
  async create(@Req() req, @Body() createProductDto: CreateProductDto) {
    const product = await this.productService.create(req.user._id, createProductDto);
    return this.successResponse('Producto añadido exitosamente', product);
  }

  // obtener todos los productos paginados
  @Get()
  async findAll(
    @Req() req,
    @Query() paginationDto: PaginationDto,
    @Query('listType') listType?: string
  ) {
    // Pasamos el DTO al servicio
    const result = await this.productService.findAllByUserPaginated(
      req.user._id,
      paginationDto,
      listType
    );

    return this.successResponse('Productos obtenidos con paginación', result);
  }

  // obtener la cantidad de productos segun la lista que están
  @Get('stats/summary')
  async getStats(@Req() req) {
    const stats = await this.productService.getStats(req.user._id);
    return this.successResponse('Estadísticas obtenidas', stats);
  }

  // obtener todos los productos caducados
  @Get('expired/all')
  async getExpired(@Req() req) {
    const products = await this.productService.getExpiredProducts(req.user._id);
    return this.successResponse('Productos caducados', products);
  }

  // obtener productos que caducan pronto
  @Get('expiring/soon')
  async getExpiringSoon(@Req() req, @Query('days') days?: string) {
    const daysNum = days ? parseInt(days) : 30;
    const products = await this.productService.getExpiringSoon(req.user._id, daysNum);
    return this.successResponse(`Productos que caducan en ${daysNum} días`, products);
  }

  // obtener producto segun su id
  @Get(':id')
  async findOne(@Req() req, @Param('id') id: string) {
    const product = await this.productService.findById(id, req.user._id);
    if (!product) {
      throw new NotFoundException(`Producto ${id} no encontrado`);
    }
    return this.successResponse('Producto obtenido', product);
  }

  // actualizar parcial un producto
  @Patch(':id')
  async update(
    @Req() req,
    @Param('id') id: string,
    @Body() updateProductDto: UpdateProductDto,
  ) {
    const product = await this.productService.update(id, req.user._id, updateProductDto);
    return this.successResponse('Producto actualizado', product);
  }

  // mover el producto en otra lista
  @Patch(':id/move')
  async moveToList(
    @Req() req,
    @Param('id') id: string,
    @Body() moveProductDto: MoveProductDto,
  ) {
    const product = await this.productService.moveToList(
      id,
      req.user._id,
      moveProductDto.targetList,
    );
    return this.successResponse('Producto movido de lista', product);
  }

  // eliminar producto
  @Delete(':id')
  async delete(@Req() req, @Param('id') id: string) {
    const product = await this.productService.delete(id, req.user._id);
    return this.successResponse('Producto eliminado', product);
  }

  // marcar el producto como abierto
  @Patch(':id/open')
  async markAsOpened(
    @Req() req,
    @Param('id') id: string,
    @Body('openedDate') openedDateStr?: string
  ) {
    const customDate = openedDateStr ? new Date(openedDateStr) : undefined;
    const product = await this.productService.markAsOpened(id, req.user._id, customDate);
    return this.successResponse('Producto marcado como abierto', product);
  }

  // cerrar el producto
  @Patch(':id/close')
  async markAsClosed(@Req() req, @Param('id') id: string) {
    const product = await this.productService.markAsClosed(id, req.user._id);
    return this.successResponse('Producto marcado como cerrado', product);
  }

  // calcular la fecha de vencimiento de producto una vez abierto
  @Post(':id/calculate-expiration')
  async calculateExpiration(@Req() req, @Param('id') id: string) {
    const product = await this.productService.calculateExpirationFromOpening(id, req.user._id);
    return this.successResponse('Fecha de caducidad calculada', product);
  }

  // subir imagen al producto
  @Post(':id/upload-image')
  @UseInterceptors(
    FileInterceptor('productImage', {
      limits: {
        fileSize: 10 * 1024 * 1024, // 10MB
      },
      fileFilter: (req: any, file: Express.Multer.File, cb: any) => {
        const allowedMimes = ['image/jpeg', 'image/png', 'image/webp'];
        
        if (!allowedMimes.includes(file.mimetype)) {
          cb(
            new BadRequestException(
              `Tipo de archivo no permitido. Permitidos: ${allowedMimes.join(', ')}`,
            ),
            false,
          );
        } else {
          cb(null, true);
        }
      },
    }),
  )
  async uploadProductImage(
    @Param('id') productId: string,
    @UploadedFile() file: Express.Multer.File,
    @Req() req,
  ) {
    try {
      if (!file) {
        throw new BadRequestException('No se proporcionó ningún archivo');
      }

      // Verificar que el producto existe y pertenece al usuario
      const product = await this.productService.findById(productId, req.user._id);
      if (!product) {
        throw new NotFoundException(`Producto ${productId} no encontrado`);
      }

      console.log(`📸 Subiendo imagen para producto: ${product.name}`);
      console.log(`   - Tamaño original: ${(file.size / 1024).toFixed(2)}KB`);

      // Comprimir imagen para producto
      const compressedBuffer = await this.imageCompressionService.compressProductImage(
        file.buffer,
        file.mimetype,
      );

      // Subir a Cloudinary en carpeta 'products'
      const imageUrl = await this.cloudinaryService.uploadImage(
        compressedBuffer,
        `product_${productId}_${Date.now()}`,
        'products',
      );

      // Eliminar imagen anterior si existe
      if (product.imageUrl) {
        const publicId = this.cloudinaryService.extractPublicIdFromUrl(product.imageUrl);
        if (publicId) {
          await this.cloudinaryService.deleteImage(publicId);
          console.log(`🗑️ Imagen anterior eliminada: ${publicId}`);
        }
      }

      // Actualizar solo el campo imageUrl
      const updatedProduct = await this.productService.update(
        productId,
        req.user._id,
        { imageUrl },
      );

      console.log(`✅ Imagen actualizada para: ${product.name}`);

      return this.successResponse('Imagen de producto actualizada exitosamente', updatedProduct);
    } catch (error) {
      console.error('❌ Error al subir imagen:', error);
      if (error instanceof BadRequestException) throw error;
      if (error instanceof NotFoundException) throw error;
      throw new BadRequestException(error.message || 'Error al subir la imagen');
    }
  }

  // eliminar foto del producto
  @Delete(':id/image')
  async deleteProductImage(@Param('id') productId: string, @Req() req) {
    try {
      const product = await this.productService.findById(productId, req.user._id);
      if (!product) {
        throw new NotFoundException(`Producto ${productId} no encontrado`);
      }

      if (!product.imageUrl) {
        throw new BadRequestException('El producto no tiene imagen');
      }

      // Eliminar de Cloudinary
      const publicId = this.cloudinaryService.extractPublicIdFromUrl(product.imageUrl);
      if (publicId) {
        await this.cloudinaryService.deleteImage(publicId);
        console.log(`🗑️ Imagen eliminada de Cloudinary: ${publicId}`);
      }

      // Actualizar producto: imageUrl = null
      const updatedProduct = await this.productService.update(
        productId,
        req.user._id,
        { imageUrl: null },
      );

      return this.successResponse('Imagen de producto eliminada', updatedProduct);
    } catch (error) {
      console.error('❌ Error al eliminar imagen:', error);
      throw new BadRequestException(error.message || 'Error al eliminar la imagen');
    }
  }
}