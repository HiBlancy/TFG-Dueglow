export declare const multerOptions: {
    limits: {
        fileSize: number;
    };
    fileFilter: (req: any, file: Express.Multer.File, callback: (error: Error | null, acceptFile?: boolean) => void) => void;
    storage: undefined;
};
