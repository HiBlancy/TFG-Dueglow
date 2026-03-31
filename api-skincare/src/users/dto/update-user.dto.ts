// update-user.dto.ts
import { IsEmail, IsNotEmpty, IsOptional, IsString, MinLength, IsDateString, IsPhoneNumber } from 'class-validator';

export class UpdateUserDto {
  @IsOptional()
  @IsString()
  @IsNotEmpty()
  name?: string;

  @IsOptional()
  @IsEmail()
  email?: string;

  @IsOptional()
  @IsString()
  @MinLength(6)
  password?: string;

  @IsOptional()
  @IsString()
  phone?: string;

  @IsOptional()
  @IsDateString() // Valida que sea una fecha en formato ISO
  birthDate?: string;

  @IsOptional()
  @IsString()
  profileImage?: string;
}