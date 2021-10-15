create or replace package PKG_PROCESSING is

  procedure DIM_ADD_INFO (
      p_act_date in date
  );
  
  procedure DIM_PAYMENT_TYPES (
      p_act_date in date
  );
  
  procedure DIM_PRODUCT_LINES (
      p_act_date in date
  );
      
  procedure FT_ITEM_ORDERS (
      p_act_date in date
  );
    
end PKG_PROCESSING;
/
create or replace package body PKG_PROCESSING is

  C_ERR_MESSAGE varchar2(50) := 'Thread execution error :: STAGE_N = ';
  

  procedure DIM_ADD_INFO (
      p_act_date in date)     
  is
    v_stage_n number := 2000;
    v_row_count number := 0;

    v_stage_id number;

    v_err_text varchar2(2000);  
  begin  
    pkg_logging.log_start(v_stage_n, p_act_date, v_stage_id);
    pkg_logging.track_start(v_stage_id);    
        
    for rec in (select c.customer_type, c.gender, l.location_id as branch, l.city
                  from SI_ORDERS o
                  join SI_CUSTOMERS c
                    on o.customer_id = c.customer_id                
                  join SI_LOCATIONS l
                    on o.location_id = l.location_id
                 minus
                select customer_type, gender, branch, city
                  from DIM_ADD_INFO)
    loop
      insert into DIM_ADD_INFO
      values (ADD_INFO_SK.nextval, rec.customer_type, rec.gender, rec.branch, rec.city);
      
      v_row_count := v_row_count + 1;
      if mod(v_row_count, 100) = 0 then
        pkg_logging.track_cur_state(v_stage_id, v_row_count);
      end if;      
    end loop;
    
    commit;  

    pkg_logging.track_cur_state(v_stage_id, v_row_count);    
    pkg_logging.log_end(v_stage_id);   
  exception
    when others then
      rollback;
      
      v_err_text := dbms_utility.format_error_stack || dbms_utility.format_error_backtrace;
      pkg_logging.log_error(v_stage_id, v_err_text);
      
      raise_application_error(-20000, C_ERR_MESSAGE || v_stage_n || chr(10) || v_err_text);     
  end DIM_ADD_INFO;


  procedure DIM_PAYMENT_TYPES (
      p_act_date in date)
  is
    v_stage_n number := 2001;
    v_row_count number := 0;

    v_stage_id number;
    
    v_err_text varchar2(2000);    
  begin  
    pkg_logging.log_start(v_stage_n, p_act_date, v_stage_id);
    pkg_logging.track_start(v_stage_id);    
        
    for rec in (select payment_type_name
                  from SI_PAYMENT_TYPES
                 minus
                select payment_type_name
                  from DIM_PAYMENT_TYPES)
    loop
      insert into DIM_PAYMENT_TYPES
      values (PAYMENT_TYPE_SK.nextval, rec.payment_type_name);
      
      v_row_count := v_row_count + 1;
      if mod(v_row_count, 100) = 0 then
        pkg_logging.track_cur_state(v_stage_id, v_row_count);
      end if;      
    end loop;
    
    commit; 
    
    pkg_logging.track_cur_state(v_stage_id, v_row_count);
    pkg_logging.log_end(v_stage_id);   
  exception
    when others then
      rollback;
      
      v_err_text := dbms_utility.format_error_stack || dbms_utility.format_error_backtrace;
      pkg_logging.log_error(v_stage_id, v_err_text);
      
      raise_application_error(-20000, C_ERR_MESSAGE || v_stage_n || chr(10) || v_err_text);        
  end DIM_PAYMENT_TYPES;


  procedure DIM_PRODUCT_LINES (
      p_act_date in date)
  is
    v_stage_n number := 2002;
    v_row_count number := 0;

    v_stage_id number;   
    
    v_err_text varchar2(2000);  
  begin 
    pkg_logging.log_start(v_stage_n, p_act_date, v_stage_id);
    pkg_logging.track_start(v_stage_id);    
         
    for rec in (select product_line_name
                  from SI_PRODUCT_LINES
                 minus
                select product_line_name
                  from DIM_PRODUCT_LINES)
    loop
      insert into DIM_PRODUCT_LINES
      values (PRODUCT_LINE_SK.nextval, rec.product_line_name);
      
      v_row_count := v_row_count + 1;
      if mod(v_row_count, 100) = 0 then
        pkg_logging.track_cur_state(v_stage_id, v_row_count);
      end if;
    end loop;
    
    commit;  
    
    pkg_logging.track_cur_state(v_stage_id, v_row_count);
    pkg_logging.log_end(v_stage_id);   
  exception
    when others then
      rollback;
      
      v_err_text := dbms_utility.format_error_stack || dbms_utility.format_error_backtrace;
      pkg_logging.log_error(v_stage_id, v_err_text);
      
      raise_application_error(-20000, C_ERR_MESSAGE || v_stage_n || chr(10) || v_err_text);       
  end DIM_PRODUCT_LINES;


  procedure FT_ITEM_ORDERS (
      p_act_date in date)
  is
    v_stage_n number := 2003;

    v_stage_id number;
    
    v_err_text varchar2(2000);  
  begin  
    pkg_logging.log_start(v_stage_n, p_act_date, v_stage_id);
    pkg_logging.track_start(v_stage_id);
    
    delete from FT_ITEM_ORDERS
     where trunc(act_date) = p_act_date;
        
    insert into FT_ITEM_ORDERS
    select ITEM_ORDER_SK.nextval,
           add_info_sk,
           payment_type_sk,
           product_line_sk,
           act_date,
           invoice_tag,
           unit_price,
           quantity,
           cogs,
           tax_5,
           total,
           round((total - cogs) / total * 100, 2) as gross_margin_percent,
           round(total - cogs, 3) as gross_income
      from (select dai.add_info_sk, 
                   dpt.payment_type_sk, 
                   dpl.product_line_sk, 
                   o.act_date,
                   o.invoice_tag, 
                   p.unit_price, 
                   i.quantity,
                   p.unit_price * i.quantity as cogs,
                   round(p.unit_price * i.quantity * 0.05, 3) as tax_5,
                   round(p.unit_price * i.quantity * 1.05, 3) as total
              from SI_ORDERS o
              join SI_CUSTOMERS c
                on o.customer_id = c.customer_id
               and trunc(o.act_date) = p_act_date 
              join SI_LOCATIONS l
                on o.location_id = l.location_id
              join DIM_ADD_INFO dai
                on c.customer_type = dai.customer_type
               and c.gender = dai.gender
               and l.location_id = dai.branch
               and l.city = dai.city
              join SI_PAYMENT_TYPES spt
                on o.payment_type_id = spt.payment_type_id
              join DIM_PAYMENT_TYPES dpt
                on spt.payment_type_name = dpt.payment_type_name
              join SI_ITEMS i
                on o.invoice_id = i.invoice_id
              join SI_PRODUCTS p
                on i.product_id = p.product_id
              join SI_PRODUCT_LINES spl
                on p.product_line_id = spl.product_line_id
              join DIM_PRODUCT_LINES dpl
                on spl.product_line_name = dpl.product_line_name);

    pkg_logging.track_cur_state(v_stage_id, sql%rowcount);
    commit; 
    
    pkg_logging.log_end(v_stage_id);   
  exception
    when others then
      rollback;
      
      v_err_text := dbms_utility.format_error_stack || dbms_utility.format_error_backtrace;
      pkg_logging.log_error(v_stage_id, v_err_text);
      
      raise_application_error(-20000, C_ERR_MESSAGE || v_stage_n || chr(10) || v_err_text);        
  end FT_ITEM_ORDERS;
  
end PKG_PROCESSING;
/
