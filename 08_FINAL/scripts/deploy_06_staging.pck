create or replace package PKG_STAGING is

  function SI_CUSTOMERS (
      p_customer_type in varchar2,
      p_gender in varchar2)
  return number;

  function SI_ITEMS (
      p_invoice_id in varchar2,
      p_product_line_name in varchar2,
      p_unit_price in varchar2,
      p_quantity in number)
  return number;

  function SI_LOCATIONS (
      p_location_id in varchar2,
      p_city in varchar2)
  return number;

  function SI_ORDERS (
      p_invoice_id in varchar2,
      p_branch in varchar2,
      p_customer_type in varchar2,
      p_gender in varchar2,
      p_date in varchar2,
      p_time in varchar2,
      p_payment_type_name in varchar2,
      p_rating in number)
  return number;

  function SI_PAYMENT_TYPES (
      p_payment_type_name in varchar2)
  return number;
      
  function SI_PRODUCT_LINES (
      p_product_line_name in varchar2)
  return number;
  
  function SI_PRODUCTS (
    p_product_line_name in varchar2,
    p_unit_price in number)
  return number;
    
end PKG_STAGING;
/
create or replace package body PKG_STAGING is

  function SI_CUSTOMERS (
      p_customer_type in varchar2,
      p_gender in varchar2)
  return number is
    v_not_exists number;
  begin  
    select count(*) into v_not_exists
      from SI_CUSTOMERS
     where customer_type = p_customer_type
       and gender = p_gender;
       
    if v_not_exists = 0 then
      insert into SI_CUSTOMERS
      values (CUSTOMER_ID.nextval, p_customer_type, p_gender);
      
      return 1;
    end if;
    
    return 0;
  end SI_CUSTOMERS;


  function SI_ITEMS (
      p_invoice_id in varchar2,
      p_product_line_name in varchar2,
      p_unit_price in varchar2,
      p_quantity in number)
  return number is
  begin  
    insert into SI_ITEMS 
    select ITEM_ID.nextval,
           o.invoice_id,
           p.product_id, 
           p_quantity
      from (select p_invoice_id as invoice_tag,
                   p_unit_price as unit_price,
                   p_product_line_name as product_line_name
              from dual) i
      join SI_ORDERS o
        on i.invoice_tag = o.invoice_tag
      join SI_PRODUCTS p
        on i.unit_price = p.unit_price
      join SI_PRODUCT_LINES pl
        on i.product_line_name = pl.product_line_name
       and p.product_line_id = pl.product_line_id;
       
    return 1;
  end SI_ITEMS;


  function SI_LOCATIONS (
      p_location_id in varchar2,
      p_city in varchar2)
  return number is
    v_not_exists number;
  begin  
    select count(*) into v_not_exists
      from SI_LOCATIONS
     where location_id = p_location_id
       and city = p_city;
    
    if v_not_exists = 0 then
      insert into SI_LOCATIONS
      values (p_location_id, p_city);
      
      return 1;
    end if;
    
    return 0;
  end SI_LOCATIONS;


  function SI_ORDERS (
      p_invoice_id in varchar2,
      p_branch in varchar2,
      p_customer_type in varchar2,
      p_gender in varchar2,
      p_date in varchar2,
      p_time in varchar2,
      p_payment_type_name in varchar2,
      p_rating in number)
  return number is
  begin     
    insert into SI_ORDERS 
    select ORDER_ID.nextval,
           c.customer_id,         
           p_branch, 
           pt.payment_type_id, 
           to_date(p_date || chr(10) || p_time, 'MM/DD/YYYY HH24:MI'),
           p_invoice_id,
           p_rating
      from (select p_customer_type as customer_type,
                   p_gender as gender,
                   p_payment_type_name as payment_name
              from dual) o
      join SI_CUSTOMERS c
        on o.customer_type = c.customer_type
       and o.gender = c.gender
      join SI_PAYMENT_TYPES pt
        on o.payment_name = pt.payment_type_name;
        
    return 1;
  end SI_ORDERS;


  function SI_PAYMENT_TYPES (
      p_payment_type_name in varchar2)
  return number is
    v_not_exists number;
  begin  
    select count(*) into v_not_exists
      from SI_PAYMENT_TYPES
     where payment_type_name = p_payment_type_name;

    if v_not_exists = 0 then
      insert into SI_PAYMENT_TYPES
      values (PAYMENT_TYPE_ID.nextval, p_payment_type_name);
      
      return 1;
    end if;
    
    return 0;
  end SI_PAYMENT_TYPES;


  function SI_PRODUCT_LINES (
      p_product_line_name in varchar2)
  return number is
    v_not_exists number;
  begin  
    select count(*) into v_not_exists
      from SI_PRODUCT_LINES
     where product_line_name = p_product_line_name;

    if v_not_exists = 0 then
      insert into SI_PRODUCT_LINES
      values (PRODUCT_LINE_ID.nextval, p_product_line_name);
      
      return 1;
    end if;
    
    return 0;
  end SI_PRODUCT_LINES;
  
  
  function SI_PRODUCTS (
      p_product_line_name in varchar2,
      p_unit_price in number)
  return number is
    v_not_exists number;
  begin  
    select count(*) into v_not_exists
      from SI_PRODUCTS p
      join SI_PRODUCT_LINES pl
        on p.product_line_id = pl.product_line_id
       and p.unit_price = trunc(p_unit_price, 2)
       and pl.product_line_name = p_product_line_name;

    if v_not_exists = 0 then
      insert into SI_PRODUCTS
      select PRODUCT_ID.nextval, product_line_id, p_unit_price
        from SI_PRODUCT_LINES
       where product_line_name = p_product_line_name;
       
      return 1;
    end if;
    
    return 0;
  end SI_PRODUCTS;
  
end PKG_STAGING;
/
