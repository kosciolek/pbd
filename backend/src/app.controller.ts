import { Body, Controller, Get, Inject, Post } from '@nestjs/common';
import { AppService } from './app.service';
import { DB_CONNECTION, DbService, InjectDb } from './db/db.service';
import { Knex } from 'knex';
import { Order, ProductAvailability } from './db/tables';

@Controller()
export class AppController {
  constructor(
    private readonly appService: AppService,
  ) {}

  @Post('product_availability')
  async createProductAvailability(@Body() pa: ProductAvailability) {
    this.appService.createProductAvailability(pa);
  }

  @Get('/product')
  async getProducts() {
    return await this.appService.getProducts();
  }
}
