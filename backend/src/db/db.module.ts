import { Module } from '@nestjs/common';
import { connectionFactory } from './db.service';

@Module({
  providers: [connectionFactory],
  exports: [connectionFactory],
})
export class DbModule {}
