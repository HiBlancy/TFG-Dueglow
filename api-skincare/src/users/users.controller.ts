// src/users/users.controller.ts
import {
  Controller,
  Get,
  Post,
  Patch,
  Delete,
  Body,
  Param,
  BadRequestException,
  NotFoundException,
  ConflictException,
  UnauthorizedException,
  Req,
  UseGuards,
  UseInterceptors,
  UploadedFile,
} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { UsersService } from './users.service';
import { CreateUserDto } from './dto/create-user.dto';
import { UpdateUserDto } from './dto/update-user.dto';
import { JwtService } from '@nestjs/jwt';
import { AuthGuard } from './guards/auth.guard';
import { CloudinaryService } from '../cloudinary/cloudinary.service';

@Controller('users')
export class UsersController {
  constructor(
    private readonly usersService: UsersService,
    private readonly jwtService: JwtService,
    private readonly cloudinaryService: CloudinaryService,
  ) {}

  // Helper para respuestas consistentes
  private successResponse(message: string, data: any = null) {
    return { status: true, message, data };
  }

  @Post('register')
  async register(@Body() createUserDto: CreateUserDto) {
    try {
      const user = await this.usersService.create({
        ...createUserDto,
        email: createUserDto.email.toLowerCase(),
      });

      const token = await this.jwtService.signAsync({
        _id: user._id,
        email: user.email,
        name: user.name,
      });

      return this.successResponse('Usuario registrado exitosamente', {
        user,
        token,
      });
    } catch (error) {
      if (error instanceof ConflictException) throw error;
      throw new BadRequestException(error.message || 'Error al crear usuario');
    }
  }

  @Post('login')
  async login(@Body() body: { email: string; password: string }) {
    try {
      const user = await this.usersService.findOne({
        email: body.email.toLowerCase(),
      });
      if (!user || !(await user.comparePassword(body.password))) {
        throw new UnauthorizedException('Credenciales incorrectas');
      }

      const token = await this.jwtService.signAsync({
        _id: user._id,
        email: user.email,
        name: user.name,
      });

      return this.successResponse('Login exitoso', { user, token });
    } catch (error) {
      if (error instanceof UnauthorizedException) throw error;
      throw new BadRequestException(error.message || 'Error en login');
    }
  }

  @UseGuards(AuthGuard)
  @Get('me')
  async getProfile(@Req() req) {
    return this.successResponse('Perfil obtenido', req.user);
  }

  @UseGuards(AuthGuard)
  @Patch('me')
  async updateProfile(@Body() updateUserDto: UpdateUserDto, @Req() req) {
    const updatedUser = await this.usersService.update(
      req.user._id,
      updateUserDto,
    );
    return this.successResponse('Perfil actualizado', updatedUser);
  }

  /**
   * 🆕 ENDPOINT PARA SUBIR IMAGEN DE PERFIL
   * POST /users/me/upload-image
   * Recibe multipart/form-data con archivo
   */
  @UseGuards(AuthGuard)
  @Patch('me/upload-image')
  @UseInterceptors(
    FileInterceptor('profileImage', {
      limits: {
        fileSize: 5 * 1024 * 1024, // 5MB
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
  async uploadProfileImage(
    @UploadedFile() file: Express.Multer.File,
    @Req() req,
  ) {
    try {
      // ✅ Validación: verificar que hay archivo
      if (!file) {
        throw new BadRequestException('No se proporcionó ningún archivo');
      }

      // ✅ Validación: verificar MIME type (double check)
      const allowedMimeTypes = ['image/jpeg', 'image/png', 'image/webp'];
      if (!allowedMimeTypes.includes(file.mimetype)) {
        throw new BadRequestException(
          `Tipo de archivo no permitido. Permitidos: ${allowedMimeTypes.join(', ')}`,
        );
      }

      // ✅ Validación: verificar tamaño (máx 5MB)
      const maxSizeBytes = 5 * 1024 * 1024; // 5MB
      if (file.size > maxSizeBytes) {
        throw new BadRequestException(
          `El archivo es demasiado grande. Máximo: 5MB, Recibido: ${(file.size / 1024 / 1024).toFixed(2)}MB`,
        );
      }

      console.log(`📤 Subiendo imagen de usuario ${req.user._id}`);
      console.log(`   - Nombre original: ${file.originalname}`);
      console.log(`   - MIME type: ${file.mimetype}`);
      console.log(`   - Tamaño: ${(file.size / 1024).toFixed(2)}KB`);

      // Subir a Cloudinary
      const imageUrl = await this.cloudinaryService.uploadImage(
        file.buffer,
        `${req.user._id}_${file.originalname}`,
        'user-profiles', // Carpeta en Cloudinary
      );

      // Obtener la imagen anterior para eliminarla de Cloudinary (opcional)
      const currentUser = await this.usersService.findById(req.user._id);
      if (currentUser?.profileImage) {
        const publicId = this.cloudinaryService.extractPublicIdFromUrl(
          currentUser.profileImage,
        );
        if (publicId) {
          await this.cloudinaryService.deleteImage(publicId);
          console.log(`🗑️  Imagen anterior eliminada: ${publicId}`);
        }
      }

      // Actualizar usuario con la nueva URL
      const updateDto: UpdateUserDto = {
        profileImage: imageUrl,
      };

      const updatedUser = await this.usersService.update(
        req.user._id,
        updateDto,
      );

      console.log(
        `✅ Imagen de perfil actualizada para usuario ${req.user._id}`,
      );
      console.log(`   - URL: ${imageUrl}`);

      return this.successResponse(
        'Imagen de perfil actualizada exitosamente',
        updatedUser,
      );
    } catch (error) {
      console.error('❌ Error al subir imagen:', error);
      if (error instanceof BadRequestException) throw error;
      throw new BadRequestException(
        error.message || 'Error al subir la imagen',
      );
    }
  }

  @Get()
  async findAllUsers() {
    const users = await this.usersService.getAllUsers();
    return this.successResponse('Usuarios obtenidos', users);
  }

  @Delete('delete/:id')
  async deleteWithoutAuth(@Param('id') id: string): Promise<any> {
    try {
      const deletedUser = await this.usersService.delete(id);

      if (!deletedUser) {
        throw new NotFoundException({
          status: false,
          message: `Usuario con ID ${id} no encontrado`,
        });
      }

      return {
        status: true,
        message: 'Usuario eliminado exitosamente',
        data: deletedUser,
      };
    } catch (error) {
      if (error instanceof NotFoundException) {
        throw error;
      }
      throw new BadRequestException({
        status: false,
        message: error.message || 'Error al eliminar el usuario',
      });
    }
  }
}
