create table AI_STAGES (
  stage_n number(5) not null,
  stage_name varchar2(150),
  stage_proc varchar2(100))
tablespace USERS;

alter table AI_STAGES
add constraint AI_STAGES_PK primary key (stage_n)
using index tablespace USERS;

insert into AI_STAGES values (1000, 'Download Customers', 'SI_CUSTOMERS');
insert into AI_STAGES values (1001, 'Download Locations', 'SI_LOCATIONS');
insert into AI_STAGES values (1002, 'Download Payment Types', 'SI_PAYMENT_TYPES');
insert into AI_STAGES values (1003, 'Download Product Lines', 'SI_PRODUCT_LINES');
insert into AI_STAGES values (1004, 'Download Products', 'SI_PRODUCTS');
insert into AI_STAGES values (1005, 'Download Orders', 'SI_ORDERS');
insert into AI_STAGES values (1006, 'Download Items', 'SI_ITEMS');
insert into AI_STAGES values (2000, 'Consolidate Add Info Dimension', 'DIM_ADD_INFO');
insert into AI_STAGES values (2001, 'Consolidate Payment Types Dimension', 'DIM_PAYMENT_TYPES');
insert into AI_STAGES values (2002, 'Consolidate Product Lines Dimension', 'DIM_PRODUCT_LINES');
insert into AI_STAGES values (2003, 'Consolidate Items/Orders Fact Table', 'FT_ITEM_ORDERS');
insert into AI_STAGES values (3000, 'Check Invoice Tag Format in SI_ORDERS', 'TAG_FORMAT');
insert into AI_STAGES values (3001, 'Check Negative Quantity in SI_ITEMS', 'NEGATIVE_QUANTITY');
insert into AI_STAGES values (3002, 'Check That GOGS Less Total in FT_ITEM_ORDERS', 'COGS_LESS_TOTAL');
insert into AI_STAGES values (3003, 'Check Product Lines Exist in DIM_PRODUCT_LINES', 'PRODUCT_LINE_NAMES_EXIST');


create table AI_LOGS (
  stage_id number(5) not null,
  stage_n number(5) not null,
  act_date date,
  start_time timestamp(3),
  end_time timestamp(3),
  err_code number(5),
  err_text varchar2(2000),
  commited number(1))
tablespace USERS;

alter table AI_LOGS
add constraint AI_LOGS_PK primary key (stage_id)
using index tablespace USERS;

alter table AI_LOGS
add constraint AI_LOGS_FK1 foreign key (stage_n)
references AI_STAGES (stage_n);


create table AI_LOAD_RESULTS (
  stage_id number(5) not null,
  row_count number(5),
  start_time timestamp(3),
  end_time timestamp(3))
tablespace USERS;

alter table AI_LOAD_RESULTS
add constraint AI_LOAD_RESULTS_PK primary key (stage_id)
using index tablespace USERS;

alter table AI_LOAD_RESULTS
add constraint AI_LOAD_RESULTS_FK1 foreign key (stage_id)
references AI_LOGS (stage_id);


create table AI_QUALITY_RESULTS (
  stage_id number(5) not null,
  err_rows number(5))
tablespace USERS;

alter table AI_QUALITY_RESULTS
add constraint AI_QUALITY_RESULTS_PK primary key (stage_id)
using index tablespace USERS;

alter table AI_QUALITY_RESULTS
add constraint AI_QUALITY_RESULTS_FK1 foreign key (stage_id)
references AI_LOGS (stage_id);


create sequence STAGE_ID
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
