create table DIM_ADD_INFO (
  add_info_sk number(5) not null,
  customer_type varchar2(10),
  gender varchar2(10),
  branch varchar2(10),
  city varchar2(50))
tablespace USERS;

alter table DIM_ADD_INFO
add constraint DIM_ADD_INFO_PK primary key (add_info_sk)
using index tablespace USERS;


create table DIM_PAYMENT_TYPES (
  payment_type_sk number(5) not null,
  payment_type_name varchar2(20))
tablespace USERS;

alter table DIM_PAYMENT_TYPES
add constraint DIM_PAYMENT_TYPES_PK primary key (payment_type_sk)
using index tablespace USERS;


create table DIM_PRODUCT_LINES (
  product_line_sk number(5) not null,
  product_line_name varchar2(50))
tablespace USERS;

alter table DIM_PRODUCT_LINES
add constraint DIM_PRODUCT_LINES_PK primary key (product_line_sk)
using index tablespace USERS;


create table FT_ITEM_ORDERS (
  item_order_sk number(5) not null,
  add_info_sk number(5) not null,
  payment_type_sk number(5) not null,  
  product_line_sk number(5) not null,
  act_date date,
  invoice_tag varchar2(20),
  unit_price number(7,2),
  quantity number(5),
  cogs number(7,2),
  tax_5 number(8,3),
  total number(8,3),
  gross_margin_percent number(7,2),
  gross_income number(8,3))
tablespace USERS;

alter table FT_ITEM_ORDERS
add constraint FT_ITEM_ORDERS_PK primary key (item_order_sk)
using index tablespace USERS;

alter table FT_ITEM_ORDERS
add constraint FT_ITEM_ORDERS_FK1 foreign key (add_info_sk)
references DIM_ADD_INFO (add_info_sk);

alter table FT_ITEM_ORDERS
add constraint FT_ITEM_ORDERS_FK2 foreign key (payment_type_sk)
references DIM_PAYMENT_TYPES (payment_type_sk);

alter table FT_ITEM_ORDERS
add constraint FT_ITEM_ORDERS_FK3 foreign key (product_line_sk)
references DIM_PRODUCT_LINES (product_line_sk);


create sequence ADD_INFO_SK
minvalue 1 start with 1 increment by 1 nocache nocycle;

create sequence ITEM_ORDER_SK
minvalue 1 start with 1 increment by 1 nocache nocycle;

create sequence PAYMENT_TYPE_SK
minvalue 1 start with 1 increment by 1 nocache nocycle;

create sequence PRODUCT_LINE_SK
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
