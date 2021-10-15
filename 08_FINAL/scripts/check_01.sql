select 'DIM_ADD_INFO' as table_name, count(*) as cnt from DIM_ADD_INFO
 union all
select 'DIM_PAYMENT_TYPES' as table_name, count(*) as cnt from DIM_PAYMENT_TYPES
 union all
select 'DIM_PRODUCT_LINES' as table_name, count(*) as cnt from DIM_PRODUCT_LINES
 union all
select 'FT_ITEM_ORDERS' as table_name, count(*) as cnt from FT_ITEM_ORDERS
 union all
select 'SI_CUSTOMERS' as table_name, count(*) as cnt from SI_CUSTOMERS
 union all
select 'SI_ITEMS' as table_name, count(*) as cnt from SI_ITEMS
 union all
select 'SI_LOCATIONS' as table_name, count(*) as cnt from SI_LOCATIONS
 union all
select 'SI_ORDERS' as table_name, count(*) as cnt from SI_ORDERS
 union all
select 'SI_PAYMENT_TYPES' as table_name, count(*) as cnt from SI_PAYMENT_TYPES
 union all
select 'SI_PRODUCTS' as table_name, count(*) as cnt from SI_PRODUCTS
 union all
select 'SI_PRODUCT_LINES' as table_name, count(*) as cnt from SI_PRODUCT_LINES;