create extension saturated_int;

-- Test cast to saturated_int

select 999999999999999::saturated_int;
select 2147483648::saturated_int;
select 2147483647::saturated_int;
select (-2147483649)::saturated_int;
select (-2147483648)::saturated_int;

-- Test comparison operators

select 999999999999999::saturated_int < 2147483648::saturated_int;
select 999999999999999::saturated_int > 2147483648::saturated_int;
select 999999999999999::saturated_int = 2147483648::saturated_int;
select 2147483647::saturated_int = 2147483648::saturated_int;
select 2147483647::saturated_int <= 2147483648::saturated_int;
select 2147483646::saturated_int = 2147483648::saturated_int;
select 2147483646::saturated_int < 2147483648::saturated_int;
select 2147483646::saturated_int <= 2147483648::saturated_int;
select 2147483647::saturated_int > 2147483648::saturated_int;
select 2147483647::saturated_int >= 2147483648::saturated_int;
-- ERROR: operator does not exist
select 2147483647::int = 2147483648::saturated_int;
select 2147483647::int > 2147483648::saturated_int;
select 2147483647::int >= 2147483648::saturated_int;
select 2147483647::int <= 2147483648::saturated_int;
select 2147483647::int < 2147483648::saturated_int;
