select
    t.*
from
(
    select
        passenger_id,
        row_number() over(partition by passenger_id order by concat_ws('-',year,month,day)) as visit,
        datediff(concat_ws('-',year,month,day), first_value(concat_ws('-',year,month,day)) over(partition by passenger_id order by concat_ws('-',year,month,day))) as tstart,
        datediff(lead(concat_ws('-',year,month,day), 1, '2018-08-24') over(partition by passenger_id order by concat_ws('-',year,month,day)),
                first_value(concat_ws('-',year,month,day)) over(partition by passenger_id order by concat_ws('-',year,month,day))) as tstop,
        if(lead(concat_ws('-',year,month,day)) over(partition by passenger_id order by concat_ws('-',year,month,day)) is null, 0, 1) as status
    from
        gulfstream_dwd.dwd_order_make_d  -- eg.乘客在某天有过发单需求、则在对应ymd分区有一条记录
    where
        concat_ws('-',year,month,day) between '2018-08-20' and '2018-08-24'
        and is_td_finish=1
        and city_id in (1)
) t
where
    t.tstart<t.tstop;