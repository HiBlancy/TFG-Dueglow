import { Injectable, NotFoundException, ConflictException } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, Document } from 'mongoose';
import { User } from './interfaces/user.interface';
import { CreateUserDto } from './dto/create-user.dto';
import { UpdateUserDto } from './dto/update-user.dto';
import * as bcrypt from 'bcrypt';

@Injectable()
export class UsersService {

    constructor(
        @InjectModel('Users') private readonly userModel: Model<User>,
    ) { }

    // REGISTER
    async create(createUserDto: CreateUserDto): Promise<User> {
        const emailExists = await this.userModel.findOne({
            email: createUserDto.email.toLowerCase(),
        });
        if (emailExists) throw new ConflictException('El email ya está registrado');

        const hashedPassword = await bcrypt.hash(createUserDto.password, 10);

        const newUser = new this.userModel({
            ...createUserDto,
            password: hashedPassword,
        });

        return newUser.save();
    }

    // LOGIN — igual que tu findOne anterior
    async findOne(condition: any): Promise<User | null> {
        return this.userModel.findOne(condition).exec();
    }

    // VER PERFIL
    async findById(id: string): Promise<User | null> {
        return this.userModel.findById(id);
    }

    // VER TODOS PERFILES
    async getAllUsers() {
        return this.userModel.find().exec();
    }

    // EDITAR
    async update(id: string, updateUserDto: UpdateUserDto): Promise<User | null> {
        if (updateUserDto.password) {
            updateUserDto.password = await bcrypt.hash(updateUserDto.password, 10);
        }
        return this.userModel
            .findByIdAndUpdate(id, updateUserDto, { new: true })
            .select('-password');
    }
}