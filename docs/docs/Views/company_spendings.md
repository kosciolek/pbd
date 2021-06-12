# Company_spendings

Shows spendings per [companies](../Tables/client_company).
## Definition

```sql
CREATE OR ALTER VIEW dbo.company_spendings AS
SELECT cc.id, cc.name, cc.nip, opc.date_placed, effective_price
FROM client_company cc
         LEFT JOIN orders_per_client opc ON opc.client_id = cc.id
WHERE opc.state = 'completed';
```