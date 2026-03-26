import { UsersService } from './users.service';
import { CreateUserDto } from './dto/create-user.dto';
import { UpdateUserDto } from './dto/update-user.dto';
import { User } from './interfaces/user.interface';
export declare class UsersController {
    private readonly usersService;
    constructor(usersService: UsersService);
    create(createUserDto: CreateUserDto): Promise<User>;
    findById(id: string): Promise<User | null>;
    findAllUsers(): Promise<{
        status: boolean;
        news: (import("mongoose").Document<unknown, {}, User, {}, import("mongoose").DefaultSchemaOptions> & User & Required<{
            _id: string;
        }> & {
            __v: number;
        } & {
            id: string;
        })[];
    }>;
    update(id: string, updateUserDto: UpdateUserDto): Promise<User | null>;
}
