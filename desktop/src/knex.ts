import knex from 'knex';

const host = process.env.DB_HOST;
const user = process.env.DB_USER;
const password = process.env.DB_PASSWORD;
const port = parseInt(process.env.DB_PORT!, 10);
const database = process.env.DB_DATABASE;
export const db = knex({
  client: 'mssql',
  connection: {
    host,
    user,
    password,
    port,
    database
  }
});
