import { Get, Injectable, Post } from '@nestjs/common';
import { DbService, InjectDb } from './db/db.service';
import { Product, ProductAvailability } from './db/tables';

@Injectable()
export class AppService {
  constructor(@InjectDb() private readonly db: DbService) {}
  getHello(): string {
    return 'Hello World!';
  }

  async createProductAvailability(pa: ProductAvailability) {
    return await this.db.table('product_availability').insert(pa);
  }

  async getProducts() {
    return (await this.db.table('product').select('*')) as Product[];
  }
}
