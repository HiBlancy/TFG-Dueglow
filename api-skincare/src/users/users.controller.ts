import {
  Controller,
  Get,
  Post,
  Patch,
  Body,
  Param,
  BadRequestException,
} from '@nestjs/common';
import { UsersService } from './users.service';
import { CreateUserDto } from './dto/create-user.dto';
import { UpdateUserDto } from './dto/update-user.dto';
import { User } from './interfaces/user.interface';

@Controller('users')
export class UsersController {

  constructor(private readonly usersService: UsersService) {}

  // POST /users
  @Post()
  async create(@Body() createUserDto: CreateUserDto): Promise<User> {
    return this.usersService.create(createUserDto);
  }

  // GET /users/:id
  @Get(':id')
  async findById(@Param('id') id: string): Promise<User | null> {
    return this.usersService.findById(id);
  }

  // GET /users
  @Get("")
  async findAllUsers() {
    try {
      const data = await this.usersService.getAllUsers();
      return {
        status: true,
        news: data,
      };
    } catch (error) {
      throw new BadRequestException({
        status: false,
        message: error.message,
      });
    }
  }

  // PATCH /users/:id
  @Patch(':id')
  async update(
    @Param('id') id: string,
    @Body() updateUserDto: UpdateUserDto,
  ): Promise<User | null> {
    return this.usersService.update(id, updateUserDto);
  }

}