create extension saturated_int;

select 999999999999999::saturated_int;
select 2147483648::saturated_int;
select 2147483647::saturated_int;
select (-2147483649)::saturated_int;
select (-2147483648)::saturated_int;

