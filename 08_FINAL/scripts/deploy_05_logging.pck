create or replace package PKG_LOGGING is

  procedure LOG_START (
      p_stage_n in number,
      p_act_date in date,
      p_stage_id out number
  );

  procedure LOG_END (
      p_stage_id in number
  );
  
  procedure LOG_ERROR (
      p_stage_id in number,
      p_err_text in varchar2
  );
  
  procedure TRACK_START (
      p_stage_id in number
  );
  
  procedure TRACK_CUR_STATE (
      p_stage_id in number,
      p_row_count in number
  );  

end PKG_LOGGING;
/
create or replace package body PKG_LOGGING is

  procedure LOG_START (
      p_stage_n in number,
      p_act_date in date,
      p_stage_id out number)
  is
    pragma autonomous_transaction;
  begin
    insert into AI_LOGS
    values (STAGE_ID.nextval, p_stage_n, p_act_date, sysdate, null, 0, null, 0)
    returning stage_id into p_stage_id;

    commit;
  end LOG_START;


  procedure LOG_END (
      p_stage_id in number)      
  is
    pragma autonomous_transaction;
  begin
    update AI_LOGS
       set err_code = 1,
           end_time = sysdate,
           commited = 1
     where stage_id = p_stage_id;
    
    commit;
  end LOG_END;
  
  
  procedure LOG_ERROR (
      p_stage_id in number,
      p_err_text in varchar2)
  is
    pragma autonomous_transaction;
  begin
    update AI_LOGS 
       set end_time = sysdate,
           err_code = -1,
           err_text = p_err_text,
           commited = 1
     where stage_id = p_stage_id;
    
    commit;
  exception
    when others then
      raise_application_error(-20000, 'Error while Writing to the Event Log');
  end LOG_ERROR; 

  
  procedure TRACK_START (
      p_stage_id in number)
  is
    pragma autonomous_transaction;
  begin
    insert into AI_LOAD_RESULTS
    values (p_stage_id, 0, sysdate, null);

    commit;  
  end TRACK_START;  
  
  
  procedure TRACK_CUR_STATE (
      p_stage_id in number,
      p_row_count in number)
  is
    pragma autonomous_transaction;
  begin
    update AI_LOAD_RESULTS 
       set row_count = p_row_count,
           end_time = sysdate
     where stage_id = p_stage_id;

    commit;
  end TRACK_CUR_STATE;   

end PKG_LOGGING;
/
