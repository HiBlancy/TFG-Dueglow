import { Module } from '@nestjs/common';
import { SkincareController } from './skincare.controller';
import { SkincareService } from './skincare.service';

@Module({
  controllers: [SkincareController],
  providers: [SkincareService]
})
export class SkincareModule {}
