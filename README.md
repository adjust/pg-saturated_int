![CI](https://github.com/adjust/pg-saturated_int/workflows/CI/badge.svg)

# pg-saturated_int

An integer type with [saturation arithmetic](https://en.wikipedia.org/wiki/Saturation_arithmetic).
The difference from builtin integer type is that if an input value is out of allowed range
then the error `integer out of range` won't be raised.

## Types

### `saturated_int`

`saturated_int` is an integer type which implements [saturation arithmetic](https://en.wikipedia.org/wiki/Saturation_arithmetic).
Allowed range is `-2147483648` to `+2147483647`.

```sql
-- Cast to saturated_int

select 999999999999999::saturated_int;
 saturated_int 
---------------
 2147483647

select 2147483648::saturated_int;
 saturated_int 
---------------
 2147483647

select (-2147483649)::saturated_int;
 saturated_int 
---------------
 -2147483648
```

## Supported operators

`saturated_int` supports comparison (`<`, `<=`, `<>`, `=`, `>`, `>=`) and arithmetic operators. Here is some examples:

```sql
select 999999999999999::saturated_int > 2147483648::saturated_int;
 ?column? 
----------
 f

select 999999999999999::saturated_int = 2147483648::saturated_int;
 ?column? 
----------
 t

select 999999999999999::saturated_int * 2147483648::saturated_int;
  ?column?  
------------
 2147483647

select (-999999999999999)::saturated_int * 2147483648::saturated_int;
  ?column?   
-------------
 -2147483648

select 2147483648::saturated_int / (-1)::saturated_int;
  ?column?   
-------------
 -2147483647
```

Note that it is necessary to explicitly cast both of operands to `saturated_int`. Implicit cast isn't supported:

```sql
select 2147483647::int = 2147483648::saturated_int;
ERROR:  operator does not exist: integer = saturated_int at character 24

select 2147483647::int * 2147483648::saturated_int;
ERROR:  operator does not exist: integer * saturated_int at character 24
```

## Index support

The extension supports `btree` and `hash` indexes.

## Installation from source codes

To install `saturated_int`, execute this in the extension's directory:

```shell
make install
```

> **Notice:** Don't forget to set the `PG_CONFIG` variable (`make PG_CONFIG=...`)
> in case you want to test `saturated_int` on a non-default or custom build of PostgreSQL.
> Read more [here](https://wiki.postgresql.org/wiki/Building_and_Installing_PostgreSQL_Extension_Modules).
