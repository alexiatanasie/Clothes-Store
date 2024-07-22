# Clothes-Store
PL/SQL project 

SGBD 2024

The PL/SQL statements contains tables for a clothing store database, each serving for a specific purpose. The table“employees” stores information about employees in the clothing store having manager_id ->references employee_id(PK) in the same table, the contacts and the salaries of employees; “customers “ table stores information about customers, their contacts and the cities where the customers live;”orders” table represents orders made by customers , the date and also the number of orders; “stores”table contains information about different stores from different cities; “locations” table represents the locations of products within the store;”products”table stores information about products available in the store and “order_items” table represents individual items within an order.
 Moreover, there is a 1:1 relationship between “employees” and “managers”(self-referencing relationship within the Employees table using manager_id); it exists also a M:M relationship between “products” and “locations”(each product can be located in multiple stores, and each store can have multiple products) and there are two 1:M relationships, first one between “stores” and “locations”(each store can have multiple product locations, but each location is associated with only one store).
And the second one is a 1:M relationship between Orders and Order_Items (each order can have multiple items, but each item is associated with only one order).
