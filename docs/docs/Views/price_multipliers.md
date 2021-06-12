# Price_multipliers

Shows price multipliers calculated from the passive discount and the [active discount](../Tables/discount) for every [individual client](../Tables/client_person).

Every price multiplier is a number ranging from `0` to `1`.
## Definition
```sql
CREATE OR ALTER VIEW [dbo].[price_multipliers] AS
SELECT id                             as client_id,
       1 - IIF(EXISTS(SELECT client_id from passive_discounts where client_id = id), (select r1 from const), 0) -
       IIF(EXISTS(SELECT id from discounts WHERE active = 1 AND client_person_id = client_person.id),
           (select r2 from const), 0) as 'multiplier'
from client_person
```