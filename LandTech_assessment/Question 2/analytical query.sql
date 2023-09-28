/*This query is an example of an aggregation that can be performed that sums 
 * all arr values grouping by year, month and contract type. This could be made 
 * into a pivot table or graph to create the graph in the question.
 */
select start_date.date_year 
, start_date.date_month 
,typ.type_name 
,sum(arr) sum_arr
from fct_contracts fct
left join dim_date start_date
	on start_date.date_dim_id = fct.start_date_id 
left join dim_type typ
	on typ.type_id = fct.type_id 
group by start_date.date_year, start_date.date_month, typ.type_name
order by start_date.date_year, start_date.date_month, typ.type_name
;


	
