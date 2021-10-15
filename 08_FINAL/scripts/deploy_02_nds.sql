create table SI_CUSTOMERS (
  customer_id number(5) not null,
  customer_type varchar2(10),
  gender varchar2(10))
tablespace USERS;

alter table SI_CUSTOMERS
add constraint SI_CUSTOMERS_PK primary key (customer_id)
using index tablespace USERS;


create table SI_LOCATIONS (
  location_id varchar2(10) not null,
  city varchar2(50))
tablespace USERS;

alter table SI_LOCATIONS
add constraint SI_LOCATIONS_PK primary key (location_id)
using index tablespace USERS;


create table SI_PAYMENT_TYPES (
  payment_type_id number(5) not null,
  payment_type_name varchar2(20))
tablespace USERS;

alter table SI_PAYMENT_TYPES
add constraint SI_PAYMENT_TYPES_PK primary key (payment_type_id)
using index tablespace USERS;


create table SI_PRODUCT_LINES (
  product_line_id number(5) not null,
  product_line_name varchar2(50))
tablespace USERS;

alter table SI_PRODUCT_LINES
add constraint SI_PRODUCT_LINES_PK primary key (product_line_id)
using index tablespace USERS;


create table SI_PRODUCTS (
  product_id number(5) not null,
  product_line_id number(5) not null,
  unit_price number(7,2))
tablespace USERS;

alter table SI_PRODUCTS
add constraint SI_PRODUCTS_PK primary key (product_id)
using index tablespace USERS;

alter table SI_PRODUCTS
add constraint SI_PRODUCTS_FK1 foreign key (product_line_id)
references SI_PRODUCT_LINES (product_line_id);


create table SI_ORDERS (
  invoice_id number(5) not null,
  customer_id number(5) not null,
  location_id varchar2(10) not null,
  payment_type_id number(5) not null,
  act_date date,
  invoice_tag varchar2(20),
  rating number(5,1))
tablespace USERS;

alter table SI_ORDERS
add constraint SI_ORDERS_PK primary key (invoice_id)
using index tablespace USERS;

alter table SI_ORDERS
add constraint SI_ORDERS_FK1 foreign key (location_id)
references SI_LOCATIONS (location_id);

alter table SI_ORDERS
add constraint SI_ORDERS_FK2 foreign key (customer_id)
references SI_CUSTOMERS (customer_id);

alter table SI_ORDERS
add constraint SI_ORDERS_FK3 foreign key (payment_type_id)
references SI_PAYMENT_TYPES (payment_type_id);


create table SI_ITEMS (
  item_id number(5) not null,
  invoice_id number(5) not null,
  product_id number(5) not null,
  quantity number(5))
tablespace USERS;

alter table SI_ITEMS
add constraint SI_ITEMS_PK primary key (item_id)
using index tablespace USERS;

alter table SI_ITEMS
add constraint SI_ITEMS_FK1 foreign key (invoice_id)
references SI_ORDERS (invoice_id);

alter table SI_ITEMS
add constraint SI_ITEMS_FK2 foreign key (product_id)
references SI_PRODUCTS (product_id);


create sequence CUSTOMER_ID
minvalue 1 start with 1 increment by 1 nocache nocycle;

create sequence ITEM_ID
minvalue 1 start with 1 increment by 1 nocache nocycle;

create sequence ORDER_ID
minvalue 1 start with 1 increment by 1 nocache nocycle;

create sequence PAYMENT_TYPE_ID
minvalue 1 start with 1 increment by 1 nocache nocycle;

create sequence PRODUCT_ID
minvalue 1 start with 1 increment by 1 nocache nocycle;

create sequence PRODUCT_LINE_ID
minvalue 1 start with 1 increment by 1 nocache nocycle;


begin
  for con in (select row_number() over(partition by table_name order by constraint_name) as rn, 
                     table_name, 
                     constraint_name 
                from USER_CONSTRAINTS
               where constraint_type = 'C'
                 and constraint_name like 'SYS%'
               order by table_name, constraint_name)
  loop
    execute immediate 'alter table ' || con.table_name || 
                      ' rename constraint ' || con.constraint_name || ' to ' || con.table_name || '_NN' || con.rn;
  end loop;  
end;
