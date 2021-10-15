create or replace package PKG_MISC is

  function CHECK_PREV_DATE (
      p_act_date in date)
  return number;

  procedure CLEAR_NDS (
      p_act_date in date
  );

end PKG_MISC;
/
create or replace package body PKG_MISC is

  function CHECK_PREV_DATE (
      p_act_date in date)
  return number is
    v_result number;
  begin
    select count(*) into v_result
      from (select max(stage_id) over(partition by stage_n) as max_stage_id, 
                   stage_id,
                   err_code
              from AI_LOGS
             where stage_n = 2003
               and act_date = p_act_date)
     where max_stage_id = stage_id
       and err_code = 1;

    return v_result;
  end CHECK_PREV_DATE;  
  

  procedure CLEAR_NDS (
      p_act_date in date)
  is
  begin
    delete from SI_ITEMS
     where invoice_id in (select invoice_id
                            from SI_ORDERS
                           where trunc(act_date) = p_act_date);
                               
    delete from SI_ORDERS
     where trunc(act_date) = p_act_date;
  end CLEAR_NDS;   

end PKG_MISC;
/
