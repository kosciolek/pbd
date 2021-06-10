import { DataGrid } from '@material-ui/data-grid';
import React, { useMemo } from 'react';
import { useQuery } from 'react-query';
import { db } from './knex';
import { LinearProgress } from '@material-ui/core';

export function View({ table }: { table: string }) {
  const { data, isLoading, error } = useQuery(
    [table],
    async () => await db.table<any, any, any>(table).select('*')
  );
  const gridData = (data || []).map((data, i) => {
    if (data.id === undefined) data.id = i;
    return data;
  });

  const columns = useMemo(
    () =>
      gridData.length
        ? Object.keys(gridData[0]).map(key => ({
            field: key,
            headerName: key
              .replaceAll('_', ' ')
              .replace(/(\b[a-z](?!\s))/g, x => x.toUpperCase()),
            width: 300
          }))
        : [{ field: 'Loading' }],
    [data]
  );

  return (
    <>
      <div style={{ height: '800px', width: '100%' }}>
        <DataGrid
          rowHeight={34}
          rows={gridData}
          columns={columns}
          pageSize={100}
        />
      </div>
      {isLoading && <LinearProgress />}
      {error && <div>Something went wrong!</div>}
    </>
  );
}
