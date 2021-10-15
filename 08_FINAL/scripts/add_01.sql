declare
  v_stage_n number;
  v_sn number;
  v_row_count number;
  v_stage_id number; 
  
  v_act_date date;  
begin
  for i in 1 .. 678 loop
    v_sn := round(dbms_random.value(1, 4));
    v_row_count := round(dbms_random.value(1, 100));
    v_act_date := to_date('10-03-2019', 'DD-MM-YYYY') + round(dbms_random.value(0, 15));

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
      when v_sn = 1  then v_stage_n := 3000;
      when v_sn = 2  then v_stage_n := 3001;
      when v_sn = 3  then v_stage_n := 3002;
      when v_sn = 4  then v_stage_n := 3003;        
    end case;

    pkg_logging.log_start(v_stage_n, v_act_date, v_stage_id);
    pkg_logging.track_start(v_stage_id); 

    pkg_logging.track_cur_state(v_stage_id, v_row_count);
    pkg_logging.log_end(v_stage_id); 
  end loop;   
end;
