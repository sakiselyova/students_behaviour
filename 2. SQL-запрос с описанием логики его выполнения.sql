
with first_payments as ( --1. первая успешная транзакция для каждого студента

    select user_id 
        , date_trunc ('day', min (transaction_datetime)) first_payment_date --дата первой успешной транзакции без времени
    from skyeng_db.payments
    where status_name = 'success' --успешная транзакция
    group by 1  
)
, all_dates as ( --2. уникальные даты уроков (без времени) 

    select distinct date_trunc ('day', class_start_datetime) dt --даты уроков
    from skyeng_db.classes
    where date_part ('year', class_start_datetime)= 2016 -- за 2016 год 
   
) 
, all_dates_by_user as ( --3. даты жизни студента после того, как произошла его первая транзакция (весь период жизни студента)

    select fp.user_id, dt 
    from all_dates ad
          join first_payments fp on ad.dt >= fp.first_payment_date --дата урока больше либо равна дате первой оплаты
)
, payments_by_dates as ( -- 4. сколько уроков было начислено или списано в день успешной транзакции

    select user_id 
        , date_trunc ('day', transaction_datetime) payment_date --дата оплаты (без времени)
        , sum (classes) transaction_balance_change --сумма начисленных или списанных уроков
    from skyeng_db.payments 
    where status_name = 'success' --успешные оплаты 
    and date_part ('year', transaction_datetime)= 2016 -- за 2016 год 
    group by 1, 2  
)
, payments_by_dates_cumsum as ( --5. кумулятивная сумма транзакций для каждого ученика с первой по текущую дату, где дата начисленных/списанных уроков = дате успешной транзакции  

    select adbu.user_id, adbu.dt, pbd.transaction_balance_change
        , sum (coalesce (transaction_balance_change, 0)) over (partition by adbu.user_id order by adbu.dt rows between unbounded preceding and current row) transaction_balance_change_cs
    from all_dates_by_user adbu   
        left join payments_by_dates pbd on adbu.user_id=pbd.user_id and adbu.dt = pbd.payment_date --условие, где дата урока = дате оплаты
) 
, classes_by_dates as ( --6.количество списанных с баланса каждого ученика уроков (пройденных) за каждый день

    select user_id
        , date_trunc ('day', class_start_datetime) class_date
        , count (id_class)*-1 classes
    from skyeng_db.classes
    where class_status in ('success', 'failed_by_student') and class_type != 'trial'
    and date_part ('year', class_start_datetime)= 2016 -- за 2016 год 
    group by 1, 2
)
, classes_by_dates_cumsum  as (  --7. кумулятивная сумма пройденных уроков для каждого ученика с первой по текущую дату  

    select adbu.user_id, adbu.dt, cbd.classes
        , sum (coalesce (classes, 0)) over (partition by adbu.user_id order by adbu.dt rows between unbounded preceding and current row) classes_cs
    from all_dates_by_user adbu   
        left join classes_by_dates cbd on adbu.user_id=cbd.user_id and adbu.dt = cbd.class_date --условие, где дата урока = дате списания пройденного урока с баланса 
)
, balances as ( -- 8. вычисленныe балансы каждого студента

    select pbdcs.user_id, pbdcs.dt, pbdcs.transaction_balance_change, pbdcs.transaction_balance_change_cs, cbdcs.classes, cbdcs.classes_cs
        , (cbdcs.classes_cs + pbdcs.transaction_balance_change_cs) balance
    from payments_by_dates_cumsum pbdcs
        join classes_by_dates_cumsum cbdcs on pbdcs.user_id = cbdcs.user_id and pbdcs.dt = cbdcs.dt
    order by 1, 2 
    -- limit 1000
)
select dt --9. изменение общего количества уроков на балансах студентов
        , sum (transaction_balance_change) as transaction_balance_change
        , sum (transaction_balance_change_cs) as transaction_balance_change_cs
        , sum (classes) as classes
        , sum (classes_cs) as classes_cs
        , sum (balance) as balance
from balances
group by 1 
order by 1 


