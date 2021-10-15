begin
  for con in (select table_name, constraint_name 
                from USER_CONSTRAINTS
               where constraint_type = 'R')
  loop
    execute immediate 'alter table ' || con.table_name || 
                      ' disable constraint ' || con.constraint_name;
  end loop;
  
  for tab in (select table_name 
                from USER_TABLES)
  loop
    execute immediate 'truncate table ' || tab.table_name;
  end loop;
  
  for seq in (select sequence_name 
                from USER_SEQUENCES)
  loop
    execute immediate 'drop sequence ' || seq.sequence_name;
    
    execute immediate 'create sequence ' || seq.sequence_name ||
                      ' minvalue 1 start with 1 increment by 1 nocache nocycle';
  end loop;
    
  for con in (select table_name, constraint_name 
                from USER_CONSTRAINTS
               where constraint_type = 'R')
  loop
    execute immediate 'alter table ' || con.table_name || ' enable constraint ' || con.constraint_name;
  end loop;  
  
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
  
  commit;
end;
