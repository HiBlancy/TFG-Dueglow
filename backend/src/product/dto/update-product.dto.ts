import {
  IsOptional,
  IsString,
  IsNotEmpty,
  IsUrl,
  IsArray,
  IsNumber,
  Min,
  Max,
  IsIn,
  IsBoolean,
  IsDate,
  Matches,
} from 'class-validator';
import { Transform, Type } from 'class-transformer';
import { ApiPropertyOptional } from '@nestjs/swagger';

export class UpdateProductDto {
  @ApiPropertyOptional({ example: 'Serum Vitamina C', description: 'Nombre del producto' })
  @IsOptional()
  @IsString()
  @IsNotEmpty()
  name?: string;

  @ApiPropertyOptional({ example: 'La Roche-Posay', description: 'Marca del producto', nullable: true })
  @IsOptional()
  @IsString()
  @IsNotEmpty()
  brand?: string | null;

  @ApiPropertyOptional({
    example: 'https://example.com/product.jpg',
    description: 'URL de la imagen del producto',
    nullable: true,
  })
  @IsOptional()
  @IsUrl()
  imageUrl?: string | null;

  @ApiPropertyOptional({ example: '1234567890123', description: 'Codigo de barras', nullable: true })
  @IsOptional()
  @IsString()
  barcode?: string | null;

  @ApiPropertyOptional({
    example: ['serum', 'vitamina-c'],
    description: 'Categorias del producto',
    nullable: true,
  })
  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  categories?: string[] | null;

  @ApiPropertyOptional({ example: 'Ideal para piel sensible', description: 'Notas', nullable: true })
  @IsOptional()
  @IsString()
  notes?: string | null;

  @ApiPropertyOptional({ example: 4, description: 'Valoracion de 1 a 5', nullable: true })
  @IsOptional()
  @IsNumber()
  @Min(1)
  @Max(5)
  rating?: number | null;

  @ApiPropertyOptional({ example: 'have', enum: ['wishlist', 'have', 'used'], description: 'Lista destino' })
  @IsOptional()
  @IsIn(['wishlist', 'have', 'used'])
  listType?: string;

  @ApiPropertyOptional({
    example: '2026-12-31',
    description: 'Fecha de caducidad (YYYY-MM-DD)',
    nullable: true,
  })
  @IsOptional()
  @Transform(({ value }) => {
    if (value === null) return null;
    // Permite limpiar la fecha enviando string vacio
    if (value === '') return null;
    if (value === undefined) return undefined;
    const date = new Date(value);
    // Normalizar a UTC medianoche
    return new Date(
      Date.UTC(date.getFullYear(), date.getMonth(), date.getDate()),
    );
  })
  expirationDate?: Date | string | null;

  @ApiPropertyOptional({
    example: '12M',
    description: 'Periodo tras apertura en formato nM (ej: 12M)',
    nullable: true,
  })
  @IsOptional()
  @Transform(({ value }) => {
    // Permitir limpiar PAO enviando null
    if (value === null || value === '') return null;
    if (value === undefined) return undefined;

    // Convertir a num
    const num = typeof value === 'number' ? value : parseInt(value, 10);

    if (isNaN(num)) return value;

    // Anadimos la 'M' auto
    return `${num}M`;
  })
  @IsString()
  @Matches(/^\d+M$/, {
    message: 'El período debe ser un número positivo seguido de M (ej: 12M)',
  })
  periodAfterOpening?: string | null;

  @ApiPropertyOptional({
    example: '2026-05-01T00:00:00.000Z',
    description: 'Fecha de apertura',
    nullable: true,
  })
  @IsOptional()
  @Type(() => Date)
  @IsDate()
  openedDate?: Date | string | null;

  @ApiPropertyOptional({ example: true, description: 'Indica si el producto esta abierto', nullable: true })
  @IsOptional()
  @IsBoolean()
  isOpened?: boolean | null;
}