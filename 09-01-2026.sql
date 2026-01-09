use role accountadmin;
use warehouse my_warehouse;
use schema my_db.my_schema;
show integrations;
create storage integration aws_int
type = external_stage
enabled = true
storage_provider = s3
storage_aws_role_arn = 'arn:aws:iam::487512485733:role/snowflake_s3_role'
storage_allowed_locations = ('s3://snowflakepsiva/files/');
desc integration aws_int;
show stages;
show file formats;
create or replace stage aws_s3_stage
storage_integration = aws_int
url = 's3://snowflakepsiva/files/'
directory = (enable = true);
desc stage aws_s3_stage;
ls @aws_s3_stage;
select * from directory('@aws_s3_stage');
select $1,$2,$3,$4,$5,$6,$7,$8,metadata$filename,metadata$file_row_number,metadata$file_last_modified from @aws_s3_stage/csv/Customers.csv
(file_format=> CSV_SKIP_HEADER);
select regexp_replace(column_name,'\\d+'),type from table(infer_schema(location => '@aws_s3_stage/csv/Customers.csv',file_format => 'CSV_parse_header'));
select * from customers;
drop table customers;
create table customers
(
    customer_id int,
    gender text,
    age int,
    annual_income number,
    spending_score number,
    profession text,
    work_exp    number,
    family_size number,
    filename text,
    file_row_number number
);
copy into customers from 
(select $1,$2,$3,$4,$5,$6,$7,$8,metadata$filename,metadata$file_row_number from @aws_s3_stage/csv/Customers.csv
(file_format=> CSV_SKIP_HEADER));
select * from customers;