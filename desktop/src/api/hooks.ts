import { useQuery } from 'react-query';
import { db } from '../knex';

export const useProducts = () =>
  useQuery(
    ['products'],
    async () => await db.table<any, any, any>('product').select('*')
  );
