# GetClientType

Returns whether a [client](../Tables/client) is a [person](../Tables/client_person) or a [company](../Tables/client_company).

The values returned are `person` or `company`.

## Usage example

```sql
dbo.getClientType(23)
```
## Definition

```sql
CREATE OR
ALTER FUNCTION dbo.getClientType(@client_id INT)
    RETURNS varchar(20) AS
BEGIN
    if (exists(select id from client_person where id = @client_id))
        BEGIN
            RETURN 'person'
        END
    else
        if (exists(select id from client_company where id = @client_id))
            BEGIN
                RETURN 'company'
            END;

    return cast('No such client.' as int);
END
```