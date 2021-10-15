declare
  v_stage_n number;
  v_sn number;
  v_row_count number;

  v_stage_id number;   
begin
  v_sn := round(dbms_random.value(1, 9));
  
  case
    when v_sn = 1  then v_stage_n := 1000;
    when v_sn = 2  then v_stage_n := 1001;
    when v_sn = 3  then v_stage_n := 1002;
    when v_sn = 4  then v_stage_n := 1003;
    when v_sn = 5  then v_stage_n := 1004;
    when v_sn = 6  then v_stage_n := 1005;
    when v_sn = 7  then v_stage_n := 1006;
    when v_sn = 8  then v_stage_n := 2000;
    when v_sn = 9  then v_stage_n := 2001;
    when v_sn = 10 then v_stage_n := 2002;
    when v_sn = 11 then v_stage_n := 2003;
     
  end case;

    from dual 
--  pkg_logging.log_start(v_stage_n, p_act_date, v_stage_id);
--  pkg_logging.track_start(v_stage_id); 
  dbms_output.put_line(select round(dbms_random.value(1, 11)) num from dual);  
--  pkg_logging.track_cur_state(v_stage_id, v_row_count);
--  pkg_logging.log_end(v_stage_id);    
end;
