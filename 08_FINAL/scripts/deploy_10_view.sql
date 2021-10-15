create or replace view statistic_stages as
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
       lr.row_count,
       qr.err_rows,
       case
         when l.stage_n between 1000 and 1006 then 'Download'
         when l.stage_n between 2000 and 2003 then 'Consolidate'
         else 'Check'
       end as stage_type
  from AI_LOGS l
  join AI_STAGES s
    on l.stage_n = s.stage_n
  left join AI_LOAD_RESULTS lr
    on l.stage_id = lr.stage_id
  left join AI_QUALITY_RESULTS qr
    on l.stage_id = qr.stage_id;
