-- The PL/SQL statements contains tables for a clothing store database, each serving for a specific purpose. The table“employees” stores information about employees in the clothing store having manager_id ->references employee_id(PK) in the same table, the contacts and the salaries of employees; “customers “ table stores information about customers, their contacts and the cities where the customers live;”orders” table represents orders made by customers , the date and also the number of orders; “stores”table contains information about different stores from different cities; “locations” table represents the locations of products within the store;”products”table stores information about products available in the store and “order_items” table represents individual items within an order.
--  Moreover, there is a 1:1 relationship between “employees” and “managers”(self-referencing relationship within the Employees table using manager_id); it exists also a M:M relationship between “products” and “locations”(each product can be located in multiple stores, and each store can have multiple products) and there are two 1:M relationships, first one between “stores” and “locations”(each store can have multiple product locations, but each location is associated with only one store).
-- And the second one is a 1:M relationship between Orders and Order_Items (each order can have multiple items, but each item is associated with only one order).

--A.Interaction with the Oracle server through SQL commands (DDL and DML) in PL/SQL blocks: using execute immediate, particularities regarding the use of the select command, as well as functions at the row and group level.

--calculate and display the average minimum salary of all employees
declare
    v_avg_min_salary number;
begin
    execute immediate 'select avg(min_salary) from employees' into v_avg_min_salary;
    dbms_output.put_line('average minimum salary: ' || v_avg_min_salary);
end;

--rename the email column to contact_email in the customers table
begin
    execute immediate 'alter table customers rename column email to contact_email';
end;	

--retrieve and display the email and the name of employee with id =13 in uppercase.
declare
    v_email employees.email%type;
    v_name employees.employee_name%type;
begin
    execute immediate 'select upper(email), employee_name from employees where employee_id = 13' into v_email, v_name;
    dbms_output.put_line('employee email in uppercase: ' || v_email);
    dbms_output.put_line('employee name: ' || v_name);
end;


--update employee_id =13 with the full name: Alexia Stefania Tanasie
declare
    v_email employees.email%type;
    v_name employees.employee_name%type;
begin
    select upper(email), employee_name into v_email, v_name
    from employees
    where employee_id = 13;

    dbms_output.put_line('employee email in uppercase: ' || v_email);
    dbms_output.put_line('employee name: ' || v_name);

    update employees
    set employee_name = 'Alexia Stefania Tanasie'
    where employee_id = 13;
    dbms_output.put_line('employee name updated.');
end;

select * from employees


--B. Alternative and repetitive structures (IF, CASE, FOR, LOOP, WHILE)
--update the skirt color to red
declare
    v_skirt_color varchar2(20);
begin
    select color into v_skirt_color from locations where prod_id = 2344;
    if v_skirt_color is not null then
        execute immediate 'update locations set color = ''red'' where prod_id = 2344';
        dbms_output.put_line('skirt color updated to red.');
    else
        dbms_output.put_line('skirt with product_id 2344 not found.');
    end if;
end;

-- calculate and display the average maximum salary of cashiers and display also their id and name.
declare
    v_avg_max_salary number;
begin
    select avg(max_salary)
    into v_avg_max_salary
    from employees
    where type_job = 'cashier';
    dbms_output.put_line('average max salary: ' || v_avg_max_salary);
    for rec in (select employee_id, employee_name, max_salary from employees where type_job = 'cashier') loop
        dbms_output.put_line('employee id: ' || rec.employee_id || ', name: ' || rec.employee_name || ', max_salary: ' || rec.max_salary);
    end loop;
end;

--display the products with ids between 1000 and 2800 as long as their name and price 
declare
    v_product_id products.product_id%type;
    v_product_name products.product_name%type;
    v_price products.price%type;
begin
    for prod_rec in (select product_id, product_name, price
                     from products
                     where product_id between 1000 and 2800) loop
        v_product_id := prod_rec.product_id;
        v_product_name := prod_rec.product_name;
        v_price := prod_rec.price;

        dbms_output.put_line('product id: ' || v_product_id || ', product name: ' || v_product_name || ', price: ' || v_price);
    end loop;
end;



--display the details of orders, if nr of orders>2, then the cashier employees will have a min salary *1.05 , else remains the same
declare
    v_min_salary employees.min_salary%type;
    v_employee_id employees.employee_id%type;
    v_employee_name employees.employee_name%type;
    v_type_job employees.type_job%type;
    v_order_count number;
    v_cursor sys_refcursor;
begin
    open v_cursor for
        select e.employee_id, e.employee_name, e.type_job, count(o.order_id) as order_count, e.min_salary
        from employees e
        left join orders o on e.employee_id = o.employee_id
        where e.type_job = 'cashier'
        group by e.employee_id, e.employee_name, e.type_job, e.min_salary;

    loop
        fetch v_cursor into v_employee_id, v_employee_name, v_type_job, v_order_count, v_min_salary;
        exit when v_cursor%notfound;
        dbms_output.put_line('employee id: ' || v_employee_id || ', name: ' || v_employee_name || ', job type: ' || v_type_job || ', order count: ' || v_order_count);

        if v_order_count > 2 then
            v_min_salary := v_min_salary * 1.05;
            dbms_output.put_line('salary updated: ' || v_min_salary);
        else
            dbms_output.put_line('salary remains the same: ' || v_min_salary);
        end if;
    end loop;
    close v_cursor;
end;

--display products based on their price using a case statement. display the product id, product name, price, and their price category ("below average", "average", or "above average")

declare
    v_product_id products.product_id%type;
    v_product_name products.product_name%type;
    v_product_price products.price%type;
    v_average_price number;
    v_price_category varchar2(20);
    cursor product_cursor is
        select product_id, product_name, price
        from products;
begin
    select avg(price) into v_average_price from products;
    open product_cursor;
    loop
        fetch product_cursor into v_product_id, v_product_name, v_product_price;
        exit when product_cursor%notfound;
        
        v_price_category := case
            when v_product_price < v_average_price then 'below average'
            when v_product_price = v_average_price then 'average'
            else 'above average'
        end;
        
        dbms_output.put_line('product id: ' || v_product_id || ', name: ' || v_product_name || 
                             ', price: ' || v_product_price || ', category: ' || v_price_category);
    end loop;
    close product_cursor;
end

--display the details of orders. if the number of orders is greater than 2, then the cashier employees will have their minimum salary increased by 5%, otherwise it will remain the same. use a while loop.

declare
    cursor c_cashier_records is
        select e.employee_id, e.employee_name, e.min_salary, count(o.order_id) as order_count
        from employees e
        left join orders o on e.employee_id = o.employee_id
        where e.type_job = 'cashier'
        group by e.employee_id, e.employee_name, e.min_salary;
        
    v_employee_id employees.employee_id%type;
    v_employee_name employees.employee_name%type;
    v_min_salary employees.min_salary%type;
    v_order_count number;
    v_counter number := 0;
    v_total_rows number;
    
begin
    open c_cashier_records;
    
    select count(*) into v_total_rows from (
        select e.employee_id
        from employees e
        left join orders o on e.employee_id = o.employee_id
        where e.type_job = 'cashier'
        group by e.employee_id, e.employee_name, e.min_salary
    );

    fetch c_cashier_records into v_employee_id, v_employee_name, v_min_salary, v_order_count;

    while v_counter < v_total_rows loop
        dbms_output.put_line('employee id: ' || v_employee_id || ', name: ' || v_employee_name || ', order count: ' || v_order_count);
        
        if v_order_count > 2 then
            v_min_salary := v_min_salary * 1.05;
            dbms_output.put_line('salary updated: ' || v_min_salary);
        else
            dbms_output.put_line('salary remains the same: ' || v_min_salary);
        end if;
        
        v_counter := v_counter + 1;
        
        fetch c_cashier_records into v_employee_id, v_employee_name, v_min_salary, v_order_count;
    end loop;
    
    close c_cashier_records;
end;

--display the details of orders. If the number of orders is greater than 2, then the cashier employees will have their minimum salary increased by 5%, otherwise it will remain the same. use a LOOP.
declare
    cursor c_cashiers is
        select e.employee_id, e.employee_name, e.min_salary, count(o.order_id) as order_count
        from employees e
        left join orders o on e.employee_id = o.employee_id
        where e.type_job = 'cashier'
        group by e.employee_id, e.employee_name, e.min_salary;
    v_employee_id employees.employee_id%type;
    v_employee_name employees.employee_name%type;
    v_min_salary employees.min_salary%type;
    v_order_count number;
begin
    open c_cashiers;

    loop
        fetch c_cashiers into v_employee_id, v_employee_name, v_min_salary, v_order_count;
        
        exit when c_cashiers%notfound;

        dbms_output.put_line('employee id: ' || v_employee_id || ', name: ' || v_employee_name || ', order count: ' || v_order_count);
        



        if v_order_count > 2 then
            v_min_salary := v_min_salary * 1.05;
            dbms_output.put_line('salary updated: ' || v_min_salary);
        else
            dbms_output.put_line('salary remains the same: ' || v_min_salary);
        end if;
    end loop;
    close c_cashiers;
end;

--C. Data collections (index by table, nested table, varray)

 --use an index by table to store employee salaries and calculate the average salary. display the details of employees whose salary is above the average
declare
    type salary_table is table of number index by pls_integer;
    v_salaries salary_table;
        v_employee_id employees.employee_id%type;
    v_total_salary number := 0;
    v_average_salary number := 0;
    v_count pls_integer := 0;
    
begin
    for rec in (select employee_id, min_salary from employees) loop
        v_salaries(rec.employee_id) := rec.min_salary;
        v_total_salary := v_total_salary + rec.min_salary;
        v_count := v_count + 1;
    end loop;
        if v_count > 0 then
        v_average_salary := v_total_salary / v_count;
    end if;
    
    dbms_output.put_line('average salary: ' || to_char(v_average_salary, '99999.99'));
        dbms_output.put_line('employees with salary above the average:');
    for idx in v_salaries.first .. v_salaries.last loop
        if v_salaries.exists(idx) then
            if v_salaries(idx) > v_average_salary then
                dbms_output.put_line('employee id: ' || idx || ', salary: ' || v_salaries(idx));
            end if;
        end if;
    end loop;
end;

--create a table and a procedure that handles a collection of phone numbers using varray in pl/sql

create or replace type phone_varray is varray(3) of varchar2(20);
create table departments_varray (
    department_id number(4) primary key,
    department_name varchar2(40),
    phones phone_varray
);
create or replace procedure insert_department_data_varray is
begin
    insert into departments_varray values (
        1,
        'sales',
        phone_varray('0789 201 200', '0789 201 201')
    );

    insert into departments_varray values (
        2,
        'marketing',
        phone_varray('0789 759 012')
    );

    commit;
end;

--nested table
--store a list of products offered by stores using a nasted table
create or replace type product_table is table of number(8);
/
create table stores_with_products (
    store_id number(2) primary key,
    store_name varchar2(40),
    products product_table
)
nested table products store as products_nt;
/
create or replace procedure manage_store_products is
begin
    insert into stores_with_products values (
        1,
        'store a',
        product_table(2344, 53928, 1312)
    );

    insert into stores_with_products values (
        2,
        'store b',
        product_table(39976, 5859, 3627)
    );

    declare
        v_products product_table;
    begin
        select products into v_products
        from stores_with_products
        where store_id = 1;

        for i in 1..v_products.count loop
            dbms_output.put_line('product id: ' || v_products(i));
        end loop;
    end;
end;

begin
    manage_store_products;
end;





--D. Exception handling (minimum 3 implicit, 2 explicit).
--implicit exception handling
-- display the store with id 22 and if it doesn't exist, treat the exception by handling a no_data_found exception
begin
    declare
        v_store_name stores.address%type;
    begin
        select address into v_store_name
        from stores
        where store_id = 22;
        dbms_output.put_line('store address: ' || v_store_name);
    exception
        when no_data_found then
            dbms_output.put_line('no store found with id 22.');
    end;
end;







--handling a division by zero exception when calculating the average max salaries
declare
  v_total_max_salary employees.max_salary%type := 0;
  v_employee_count integer := 0;
  v_average_max_salary employees.max_salary%type;
begin
  select sum(max_salary), count(*) into v_total_max_salary, v_employee_count
  from employees;
  
  v_average_max_salary := v_total_max_salary / v_employee_count;
  
  dbms_output.put_line('average max salary: ' || v_average_max_salary);
exception
  when zero_divide then
    dbms_output.put_line('error: division by zero. no employees found.');
end;

-- handle a no_data_found exception when retrieving customer details by id
begin
    declare
        v_customer_name customers.customer_name%type;
    begin
        select customer_name into v_customer_name
        from customers
        where customer_id = 101; -- non-existent customer_id
        dbms_output.put_line('customer name: ' || v_customer_name);
    exception
        when no_data_found then
            dbms_output.put_line('no customer found with id 101.');
    end;
end;

--explicit
--handle a dup_val_index exception when attempting to insert a duplicate employee

begin
    begin
        insert into employees (employee_id, employee_name, email, phone, type_job, min_salary, max_salary, manager_id)
        values (13, 'alexia tanasie','alexia.t@astore.com','0789 919 766', 'store director', 7199.00, 12000.00, 49);
    exception
        when dup_val_on_index then
            dbms_output.put_line('duplicate employee id: 13');
    end;
end;

-- handle an others exception to catch any unexpected errors when inserting data into the locations table
begin
    begin
        insert into locations (loc_id, store_id, color, prod_id, size_p, quantity_loc)
        values (25, 10, 'red', 1234, 'm', 20); 
    exception
        when others then
            dbms_output.put_line('an unexpected error occurred during the insertion.');
    end;
end;

--E. cursor management: implicit and explicit (with and without parameters, for update).
-- retrieve all orders placed on a specific date using an explicit cursor with parameters
declare
    cursor order_c(date_param in date) is
        select * from orders where date_order = date_param;
begin
    for order_rec in order_c(to_date('2023-10-11', 'yyyy-mm-dd')) loop
        dbms_output.put_line('order id: ' || order_rec.order_id || ', customer id: ' || order_rec.customer_id ||
                             ', employee id: ' || order_rec.employee_id || ', date: ' || to_char(order_rec.date_order, 'dd-mm-yyyy') ||
                             ', total orders: ' || order_rec.total_orders);
    end loop;
end;


-- retrieve all customer names and emails using an implicit cursor and display them
begin
    for cust_record in (select customer_name, contact_email from customers) loop
        dbms_output.put_line('customer name: ' || cust_record.customer_name || ', email: ' || cust_record.contact_email);
    end loop;
end;


-- retrieve all employee IDs and phone numbers using an explicit cursor without parameters and display them
declare
    cursor emp_c is
        select employee_id, phone from employees;
begin
    for emp_record in emp_c loop
        dbms_output.put_line('employee id: ' || emp_record.employee_id || ', phone: ' || emp_record.phone);
    end loop;
end;

-- retrieve all orders placed by a specific customer using an explicit cursor with parameters and display them
declare
    cursor order_c(cust_id_param in number) is
        select * from orders where customer_id = cust_id_param;
begin
    for order_rec in order_c(77) loop
        dbms_output.put_line('order id: ' || order_rec.order_id || ', customer id: ' || order_rec.customer_id ||
                             ', employee id: ' || order_rec.employee_id || ', date: ' || to_char(order_rec.date_order, 'dd-mm-yyyy') ||
                             ', total orders: ' || order_rec.total_orders);
    end loop;
end;


-- increase the minimum salary of all employees by 10% using an implicit cursor with for update
declare
    cursor emp_cursor is
        select * from employees for update;

    emp_rec employees%rowtype;
begin
    open emp_cursor;
    loop
        fetch emp_cursor into emp_rec;
        exit when emp_cursor%notfound;

        update employees
        set min_salary = emp_rec.min_salary * 1.1
        where current of emp_cursor;
    end loop;

    close emp_cursor;
end;

--F. functions, procedures, inclusion in packages (minimum 3 functions, 3 procedures, and a package that includes different functions and procedures)

-- write a pl/sql function named calculate_total_orders that takes a customer_id as input and returns the total number of orders placed by that customer. test the function by providing different customer ids and verifying the returned total orders.

create or replace function calculate_total_orders(customer_id in number)
return number
is
    total_orders number := 0;
begin
    select sum(total_orders)
    into total_orders
    from orders
    where customer_id = calculate_total_orders.customer_id;

    return total_orders;
exception
    when no_data_found then
        return 0;
end;

-- create a pl/sql procedure named update_product_price that takes a product_id and a percentage_change as input parameters.this procedure should update the price of the specified product by increasing or decreasing it based on the percentage change provided. test the procedure by updating the prices of different products with various percentage changes

create or replace procedure update_product_price(
    product_id in number,
    percentage_change in number
)
is
begin
    update products
    set price = price * (1 + (percentage_change / 100))
    where product_id = update_product_price.product_id;
    commit;
end;

--develop a pl/sql function named get_employee_email that accepts an employee_name as input and returns the email address of the employee.test the function by providing different employee names and verifying the returned email addresses

create or replace function get_employee_email(employee_name in varchar2)
return varchar2
is
    emp_email varchar2(50);
begin
    select email into emp_email
    from employees
    where employee_name = get_employee_email.employee_name;

    return emp_email;
exception
    when no_data_found then
        return null;
end;


--implement a pl/sql procedure named add_customer to insert a new customer into the customers table. test the procedure by adding new customers with different details
create or replace procedure add_customer(
    customer_id in number,
    customer_name in varchar2,
    city in varchar2,
    phone in varchar2,
    contact_email in varchar2
)
is
begin
    insert into customers(customer_id, customer_name, city, phone, contact_email)
    values (add_customer.customer_id, add_customer.customer_name, add_customer.city, add_customer.phone, add_customer.contact_email);
    commit;
end;

-- develop a package named employee_info to facilitate management tasks related to employee information within the company's database. this package should encompass several functions and procedures to accomplish the following tasks:

--	calculate average salary: implement a function named calc_avg_salary that computes and returns the average maximum salary among all employees in the company.
--	get employee count by job type: create a function named get_emp_count_by_job that accepts a job type as input and returns the count of employees assigned to that specific job type.
--	update employee salary: design a procedure named update_salary to update the maximum salary of an employee identified by their employee id. this procedure should accept the employee id and the new salary as parameters.
--	delete employee record: develop a procedure called delete_employee to remove an employee's record from the database based on their employee id.
--	retrieve employee details: establish a function named get_emp_details to fetch detailed information about a particular employee specified by their employee id. this function should return a cursor containing the employee's details.
--	add new employee: implement a procedure named add_employee to insert a new employee into the database. this procedure should accept parameters such as employee id, name, email, phone number, job type, salary, and manager id.




create or replace package employee_info as
    function calc_avg_salary return number;
    function get_emp_count_by_job(job_type in varchar2) return number;
    procedure update_salary(emp_id in number, new_salary in number);
    procedure delete_employee(emp_id in number);
    function get_emp_details(emp_id in number) return sys_refcursor;
     procedure add_employee(emp_id in number, emp_name in varchar2, emp_email in varchar2,
                           emp_phone in varchar2, job_type in varchar2, salary in number, manager_id in number);
end employee_info;

--G. Triggers at statement and row level (minimum 2 of each).
--statement
-- trigger on insert to orders table to log new orders:
create or replace trigger log_new_orders
after insert on orders
declare
  v_order_count number;
begin
  select count(*) into v_order_count from orders;
  dbms_output.put_line('new order inserted. total orders: ' || v_order_count);
end;

-- trigger on delete from products table to prevent deletion if the product is referenced in order_items:
create or replace trigger prevent_product_deletion
before delete on products
for each row
declare
  v_order_count number;
begin
  select count(*) into v_order_count from order_items where product_id = :old.product_id;
  if v_order_count > 0 then
    raise_application_error(-20001, 'cannot delete product. it is referenced in order_items.');
  end if;
end;




--row level
- trigger to ensure max_salary is always greater than min_salary in employees table:
create or replace trigger check_salary
before insert or update on employees
for each row
begin
  if :new.max_salary <= :new.min_salary then
    raise_application_error(-20002, 'max salary must be greater than min salary.');
  end if;
end;

-- trigger to update total_orders in orders table after an insert or update in order_items
create or replace trigger update_total_orders
after insert or update on order_items
for each row
declare
  v_total_orders number;
begin
  select sum(quantity_id) into v_total_orders from order_items where order_id = :new.order_id;
  update orders set total_orders = v_total_orders where order_id = :new.order_id;
end;