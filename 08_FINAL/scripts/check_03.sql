select l.stage_id,
       l.stage_n,
       s.stage_name,
       s.stage_proc,
       l.act_date,
       l.start_time,
       l.end_time,
       l.err_code,
       l.err_text,
       l.commited, 
       lr.row_count, qr.err_rows
  from AI_LOGS l
  join AI_STAGES s
    on l.stage_n = s.stage_n
  left join AI_LOAD_RESULTS lr
    on l.stage_id = lr.stage_id
  left join AI_QUALITY_RESULTS qr
    on l.stage_id = qr.stage_id 
 order by l.stage_id desc;
