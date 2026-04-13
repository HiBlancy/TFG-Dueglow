import { UsersService } from './users.service';
import { CreateUserDto } from './dto/create-user.dto';
import { UpdateUserDto } from './dto/update-user.dto';
import { JwtService } from '@nestjs/jwt';
import { CloudinaryService } from '../cloudinary/cloudinary.service';
export declare class UsersController {
    private readonly usersService;
    private readonly jwtService;
    private readonly cloudinaryService;
    constructor(usersService: UsersService, jwtService: JwtService, cloudinaryService: CloudinaryService);
    private successResponse;
    register(createUserDto: CreateUserDto): Promise<{
        status: boolean;
        message: string;
        data: any;
    }>;
    login(body: {
        email: string;
        password: string;
    }): Promise<{
        status: boolean;
        message: string;
        data: any;
    }>;
    getProfile(req: any): Promise<{
        status: boolean;
        message: string;
        data: any;
    }>;
    updateProfile(updateUserDto: UpdateUserDto, req: any): Promise<{
        status: boolean;
        message: string;
        data: any;
    }>;
    uploadProfileImage(file: Express.Multer.File, req: any): Promise<{
        status: boolean;
        message: string;
        data: any;
    }>;
    findAllUsers(): Promise<{
        status: boolean;
        message: string;
        data: any;
    }>;
    deleteWithoutAuth(id: string): Promise<any>;
}
