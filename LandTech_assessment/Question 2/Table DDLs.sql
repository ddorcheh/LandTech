/*Create dim_Source table */
create table dim_Source as
select distinct dense_rank() over (order by source) source_id
, source 
from dim_contracts_example dce;

/*Create dim_Industry table */
select distinct dense_rank() over (order by industry) industry_id
, industry  
from dim_contracts_example dce;


/*Create dim_Type table and insert data*/
create table dim_Type 
(type_id INT
, type_name VARCHAR(20)
);

insert into dim_Type (
type_id
,type_name
)
values
(1, 'Churned: Cancelled')
,(2, 'Mid-Cycle Expansion')
,(3, 'New Business')
,(4, 'Re-Engagement')
,(5, 'Renewal 90d Grace');

/*Create dim_Date table*/
create table dim_Date as
SELECT TO_CHAR(datum, 'yyyymmdd')::INT AS date_dim_id,
       datum AS date_actual,
       EXTRACT(YEAR FROM datum) AS date_year,
       EXTRACT(MONTH FROM datum) AS date_month,
       EXTRACT(DAY FROM datum) as date_day,
       TO_CHAR(datum, 'TMMonth') AS month_name,
       TO_CHAR(datum, 'Mon') AS month_name_abbreviated,
       EXTRACT(QUARTER FROM datum) AS quarter_no
FROM (SELECT '2015-01-01'::DATE + SEQUENCE.DAY AS datum
      FROM GENERATE_SERIES(0, 8000) AS SEQUENCE (DAY)
      GROUP BY SEQUENCE.day
     ) DQ
ORDER BY 1;


/*create fct_Contracts table without data*/
create table fct_Contracts (
id varchar(20)
,account_id varchar(20)
,closed_date_id int
,start_date_id int
,end_date_id int
,cancellation_date_id int
,original_end_date_id int
,source_id int
,type_id int
,industry_id int
,arr decimal(10,2)
,value decimal(10,2)
,number_of_licenses int
)
;


