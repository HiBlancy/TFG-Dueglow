// src/config/multer.config.ts
import { BadRequestException } from '@nestjs/common';

/**
 * Configuración global de Multer para manejar uploads
 * Límites de tamaño y validaciones
 */
export const multerOptions = {
  // Límite de tamaño: 5MB
  limits: {
    fileSize: 5 * 1024 * 1024, // 5MB
  },

  // Validar archivo
  fileFilter: (
    req: any,
    file: Express.Multer.File,
    callback: (error: Error | null, acceptFile?: boolean) => void,
  ) => {
    // Tipos MIME permitidos
    const allowedMimes = ['image/jpeg', 'image/png', 'image/webp'];

    if (!allowedMimes.includes(file.mimetype)) {
      return callback(
        new BadRequestException(
          `Tipo de archivo no permitido: ${file.mimetype}. Permitidos: ${allowedMimes.join(', ')}`,
        ),
        false,
      );
    }

    // Validar que el nombre del campo sea correcto
    if (file.fieldname !== 'profileImage') {
      return callback(
        new BadRequestException(
          `Campo de archivo esperado: 'profileImage', recibido: '${file.fieldname}'`,
        ),
        false,
      );
    }

    callback(null, true);
  },

  // Nombre del archivo temporal
  storage: undefined, // Usar buffer en memoria (recomendado para Cloudinary)
};
