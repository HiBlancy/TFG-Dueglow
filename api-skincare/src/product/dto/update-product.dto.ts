// update-product.dto.ts - ACTUALIZADO para aceptar nulls
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
} from 'class-validator';
import { Type } from 'class-transformer';

export class UpdateProductDto {
  @IsOptional()
  @IsString()
  @IsNotEmpty()
  name?: string;

  @IsOptional()
  @IsString()
  @IsNotEmpty()
  brand?: string | null; // ✅ Permitir null

  @IsOptional()
  @IsUrl()
  imageUrl?: string | null; // ✅ Permitir null

  @IsOptional()
  @IsString()
  barcode?: string | null; // ✅ Permitir null

  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  categories?: string[] | null; // ✅ Permitir null

  @IsOptional()
  @IsString()
  notes?: string | null; // ✅ Permitir null (para limpiar)

  @IsOptional()
  @IsNumber()
  @Min(1)
  @Max(5)
  rating?: number | null; // ✅ Permitir null (para limpiar)

  @IsOptional()
  @IsIn(['wishlist', 'have', 'used'])
  listType?: string;

  @IsOptional()
  @Type(() => Date)
  @IsDate()
  expirationDate?: Date | string | null; // ✅ Permitir null (para limpiar)

  @IsOptional()
  @IsString()
  periodAfterOpening?: string | null; // ✅ Permitir null (para limpiar)

  @IsOptional()
  @Type(() => Date)
  @IsDate()
  openedDate?: Date | string | null; // ✅ Permitir null (para limpiar)

  @IsOptional()
  @IsBoolean()
  isOpened?: boolean | null; // ✅ Permitir null
}