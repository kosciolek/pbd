# Roles

Although roles are not explicitly coded into the system, we suggest the following...

:::info
Deletion is not necessary at all for the database to function (products are deactivated rather than deleted, etc), and thus we recommend switching off deletion permissions even for administrator roles for security purposes.
:::

#### Owner

The owner of the restaurant.

* `READ`, `INSERT`, `UPDATE` on
  * All tables
* May not create new table definitions or otherwise alter the database in any way.

#### Administrator

The technical administrator of the database. Due to the administrator's technical knowledge, he may delete tables as well. Has all permissions on all tables.

* `READ`, `INSERT`, `UPDATE`, `DELETE` on
  * All tables
* May change all aspects of the database, including its schema.

#### Manager

The manager, or otherwise the person responsible for rotating the menu, introducing new product types, setting seat limits and so on.


* **All worker permissions**, plus...
* `WRITE` on
  * [seafood_allowed_early_const](./Tables/seafood_allowed_early_const)
  * [product_availability](./Tables/product_availability)
  * [product](./Tables/product_availability)
  * [seat_limit](./Tables/seat_limit)

#### Worker
* `WRITE, READ, UPDATE` on
  * [client_company](./Tables/client_company)
  * [client](./Tables/client)
  * [client_person](./Tables/client_person)
  * [discount](./Tables/discount)
  * [order](./Tables/order)
  * [order_associated_employee](./Tables/order_associated_employee)
  * [order_product](./Tables/order_product)
  * [reservation](./Tables/reservation)
* `READ` ON
  * [seafood_allowed_early_const](./Tables/seafood_allowed_early_const)
  * [product_availability](./Tables/product_availability)
  * [product](./Tables/product_availability)
  * [seat_limit](./Tables/seat_limit)