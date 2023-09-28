/*
 * This query performs the insert into the fact table fct_contracts
 * first with a cte to join the source data to the dim tables on the business
 * keys. The logic to derive the correct type column is in the final select statement
 */

insert into fct_contracts (
id
,account_id
,closed_date_id
,start_date_id
,end_date_id
,cancellation_date_id
,original_end_date_id
,source_id 
,type_id 
,industry_id 
,arr 
,value 
,number_of_licenses
)
with stg_cte as (
/*In this cte, get all of the dimension IDs except for type_id plus 
 * the dates required to derive the correct type column*/
select dce.id
,dce.account_id
,cls_dt.date_dim_id as closed_date_id
,start_dt.date_dim_id as start_date_id
,start_dt.date_actual as start_date_actual
,end_dt.date_dim_id as end_date_id
,end_dt.date_actual  as end_date_actual
,canx_dt.date_dim_id as cancellation_date_id
,orig_end_dt.date_dim_id as original_end_date_id
,src.source_id 
,ind.industry_id 
,dce.arr 
,dce.value 
,dce.number_of_licenses 
,lag(end_dt.date_actual) over (partition by dce.account_id order by end_dt.date_actual) AS lag_end_date
,start_dt.date_actual - lag(end_dt.date_actual) over (partition by dce.account_id order by end_dt.date_actual) days_since_renewal
from dim_contracts_example dce 
left join dim_Date cls_dt
	on cls_dt.date_actual = nullif(closed_date, '')::DATE
left join dim_Date start_dt
	on start_dt.date_actual = nullif(start_date , '')::DATE
left join dim_Date end_dt
	on end_dt.date_actual = nullif(end_date , '')::DATE
left join dim_Date canx_dt
	on canx_dt.date_actual = nullif(cancellation_date  , '')::DATE
left join dim_Date orig_end_dt
	on orig_end_dt.date_actual = nullif(original_end_date , '')::DATE
left join dim_source src
	on src."source" = dce."source"  
left join dim_industry ind
	on ind.industry = dce.industry 
)
select id
,account_id
,closed_date_id
,start_date_id
,end_date_id
,cancellation_date_id
,original_end_date_id
,source_id 
,typ.type_id 
,industry_id 
,cast(arr as decimal(10,2))
,cast(value as decimal(10,2))
,cast(number_of_licenses as int)
from stg_cte
left join dim_type typ
	on typ.type_name = case when stg_cte.cancellation_date_id is not null then 'Churned: Cancelled'
						when stg_cte.days_since_renewal is null then 'New Business'
						when stg_cte.days_since_renewal <= 0 then 'Mid-Cycle Expansion'
						when stg_cte.days_since_renewal > 0 and stg_cte.days_since_renewal <= 90 then 'Renewal 90d Grace'
						when stg_cte.days_since_renewal > 90 then 'Re-Engagement'
						end
;
					
					
