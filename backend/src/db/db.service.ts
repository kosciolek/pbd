import knex from 'knex';
import { Inject } from '@nestjs/common';

export const DB_CONNECTION = 'DB_CONNECTION';

export const connectionFactory = {
  provide: DB_CONNECTION,
  useFactory: () => {
    const host = process.env.DB_HOST;
    const user = process.env.DB_USER;
    const password = process.env.DB_PASSWORD;
    const port = parseInt(process.env.DB_PORT);
    const database = process.env.DB_DATABASE;
    return knex({
      client: 'mssql',
      connection: {
        host,
        user,
        password,
        port,
        database,
      },
    });
  },
  inject: [],
};

export type DbService = ReturnType<typeof connectionFactory.useFactory>;

export const InjectDb = () => Inject(DB_CONNECTION);
