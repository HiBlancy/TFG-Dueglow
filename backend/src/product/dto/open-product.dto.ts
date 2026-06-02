import { IsOptional, IsString } from 'class-validator';

export class OpenProductDto {
  @IsOptional()
  @IsString()
  periodAfterOpening?: string;
}