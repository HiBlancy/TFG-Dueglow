import { Injectable, BadRequestException } from '@nestjs/common';
import sharp from 'sharp';

@Injectable()
export class ImageCompressionService {
  async compressProfileImage(buffer: Buffer, originalMime: string): Promise<Buffer> {
    try {
      const metadata = await sharp(buffer).metadata();
      
      console.log(`📐 Imagen original: ${metadata.width}x${metadata.height}, ${(buffer.length / 1024).toFixed(2)}KB`);
      
      // Configuracion para foto de perfil
      const MAX_WIDTH = 500;
      const MAX_HEIGHT = 500;
      const QUALITY = 80; // Calidad 80% es suficiente para perfil
      
      let pipeline = sharp(buffer)
        .resize(MAX_WIDTH, MAX_HEIGHT, {
          fit: 'cover',        // Recorta para llenar el cuadrado
          position: 'centre'    // Centra la imagen
        });
      
      // Elegir formato de salida
      if (originalMime === 'image/webp') {
        pipeline = pipeline.webp({ quality: QUALITY });
      } else if (originalMime === 'image/png') {
        pipeline = pipeline.png({ quality: QUALITY, compressionLevel: 9 });
      } else {
        // JPEG por defecto (incluyendo HEIC, etc)
        pipeline = pipeline.jpeg({ quality: QUALITY, progressive: true });
      }
      
      const compressedBuffer = await pipeline.toBuffer();
      
      console.log(`✨ Imagen comprimida: ${(compressedBuffer.length / 1024).toFixed(2)}KB`);
      console.log(`💾 Ahorro: ${((1 - compressedBuffer.length / buffer.length) * 100).toFixed(1)}%`);
      
      // Validar que no exceda 1MB despues de comprimir
      if (compressedBuffer.length > 1024 * 1024) {
        throw new BadRequestException('La imagen después de comprimir es mayor a 1MB');
      }
      
      return compressedBuffer;
      
    } catch (error) {
      console.error('Error comprimiendo imagen:', error);
      throw new BadRequestException('Error al procesar la imagen');
    }
  }
  
  async compressProductImage(buffer: Buffer, originalMime: string): Promise<Buffer> {
    const metadata = await sharp(buffer).metadata();
    
    // Configuracion para productos (mas grande)
    const MAX_WIDTH = 1200;
    const MAX_HEIGHT = 1200;
    const QUALITY = 85; // Calidad ligeramente mejor para productos
    
    let pipeline = sharp(buffer)
      .resize(MAX_WIDTH, MAX_HEIGHT, {
        fit: 'inside',      // Mantiene proporcion
        withoutEnlargement: true
      });
    
    if (originalMime === 'image/webp') {
      pipeline = pipeline.webp({ quality: QUALITY });
    } else {
      pipeline = pipeline.jpeg({ quality: QUALITY, progressive: true });
    }
    
    return await pipeline.toBuffer();
  }
}