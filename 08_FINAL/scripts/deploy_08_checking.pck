create or replace package PKG_CHECKING is

  procedure TAG_FORMAT (
      p_act_date in date
  );
  
  procedure NEGATIVE_QUANTITY (
      p_act_date in date
  ); 
  
  procedure COGS_LESS_TOTAL (
      p_act_date in date
  ); 
  
  procedure PRODUCT_LINE_NAMES_EXIST (
      p_act_date in date
  );  

end PKG_CHECKING;
/
create or replace package body PKG_CHECKING is
  
  C_ERR_MESSAGE varchar2(50) := 'Thread execution error :: STAGE_N = ';


  procedure TAG_FORMAT (
      p_act_date in date)
  is
    v_stage_n number := 3000;
    v_stage_id number;
    
    v_err_text varchar2(2000);
  begin
    pkg_logging.log_start(v_stage_n, p_act_date, v_stage_id);

    insert into AI_QUALITY_RESULTS
    select v_stage_id,
           sum(case
                 when regexp_like(invoice_tag, '\d{3}.\d{2}.\d{4}$') then 0
                 else 1
               end)
      from SI_ORDERS
     where trunc(act_date) = p_act_date;    
    
    commit;
    
    pkg_logging.log_end(v_stage_id);
  exception
    when others then
      rollback;
      
      v_err_text := dbms_utility.format_error_stack || dbms_utility.format_error_backtrace;
      pkg_logging.log_error(v_stage_id, v_err_text);
      
      raise_application_error(-20000, C_ERR_MESSAGE || v_stage_n || chr(10) || v_err_text);
  end TAG_FORMAT;
  
  
  procedure NEGATIVE_QUANTITY (
      p_act_date in date)
  is
    v_stage_n number := 3001;
    v_stage_id number;
    
    v_err_text varchar2(2000);
  begin
    pkg_logging.log_start(v_stage_n, p_act_date, v_stage_id);

    insert into AI_QUALITY_RESULTS
    select v_stage_id,
           sum(case
                 when quantity > 0 then 0
                 else 1
               end)
      from SI_ITEMS;
    
    commit;
    
    pkg_logging.log_end(v_stage_id);
  exception
    when others then
      rollback;
      
      v_err_text := dbms_utility.format_error_stack || dbms_utility.format_error_backtrace;
      pkg_logging.log_error(v_stage_id, v_err_text);
      
      raise_application_error(-20000, C_ERR_MESSAGE || v_stage_n || chr(10) || v_err_text);
  end NEGATIVE_QUANTITY;
  
  
  procedure COGS_LESS_TOTAL (
      p_act_date in date)
  is
    v_stage_n number := 3002;
    v_stage_id number;
    
    v_err_text varchar2(2000);
  begin
    pkg_logging.log_start(v_stage_n, p_act_date, v_stage_id);

    insert into AI_QUALITY_RESULTS
    select v_stage_id,
           sum(case
                 when total - cogs > 0 then 0
                 else 1
               end)
      from FT_ITEM_ORDERS
     where trunc(act_date) = p_act_date;
    
    commit;
    
    pkg_logging.log_end(v_stage_id);
  exception
    when others then
      rollback;
      
      v_err_text := dbms_utility.format_error_stack || dbms_utility.format_error_backtrace;
      pkg_logging.log_error(v_stage_id, v_err_text);
      
      raise_application_error(-20000, C_ERR_MESSAGE || v_stage_n || chr(10) || v_err_text);
  end COGS_LESS_TOTAL;
  
  
  procedure PRODUCT_LINE_NAMES_EXIST (
      p_act_date in date)
  is
    v_stage_n number := 3003;
    v_stage_id number;
    
    v_err_text varchar2(2000);
  begin
    pkg_logging.log_start(v_stage_n, p_act_date, v_stage_id);

    insert into AI_QUALITY_RESULTS
    select v_stage_id,
           count(*) 
      from (select product_line_name from DIM_PRODUCT_LINES
             minus
            select product_line_name from SI_PRODUCT_LINES);
    
    commit;
    
    pkg_logging.log_end(v_stage_id);
  exception
    when others then
      rollback;
      
      v_err_text := dbms_utility.format_error_stack || dbms_utility.format_error_backtrace;
      pkg_logging.log_error(v_stage_id, v_err_text);
      
      raise_application_error(-20000, C_ERR_MESSAGE || v_stage_n || chr(10) || v_err_text);
  end PRODUCT_LINE_NAMES_EXIST;      

end PKG_CHECKING;
/
