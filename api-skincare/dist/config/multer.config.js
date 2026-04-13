"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.multerOptions = void 0;
const common_1 = require("@nestjs/common");
exports.multerOptions = {
    limits: {
        fileSize: 5 * 1024 * 1024,
    },
    fileFilter: (req, file, callback) => {
        const allowedMimes = ['image/jpeg', 'image/png', 'image/webp'];
        if (!allowedMimes.includes(file.mimetype)) {
            return callback(new common_1.BadRequestException(`Tipo de archivo no permitido: ${file.mimetype}. Permitidos: ${allowedMimes.join(', ')}`), false);
        }
        if (file.fieldname !== 'profileImage') {
            return callback(new common_1.BadRequestException(`Campo de archivo esperado: 'profileImage', recibido: '${file.fieldname}'`), false);
        }
        callback(null, true);
    },
    storage: undefined,
};
//# sourceMappingURL=multer.config.js.map