CREATE FUNCTION sat_int4_in(cstring)
RETURNS saturated_int
AS 'MODULE_PATHNAME'
LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION sat_int4_out(saturated_int)
RETURNS cstring
AS 'int4out'
LANGUAGE internal IMMUTABLE STRICT PARALLEL SAFE;

CREATE TYPE saturated_int (
    input = sat_int4_in,
    output = sat_int4_out,
    -- receive = ...,
    -- send = ...,
    like = integer,
    category = 'N'
);

CREATE FUNCTION sat_int8to4(bigint)
RETURNS saturated_int
AS 'MODULE_PATHNAME'
LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE CAST (bigint AS saturated_int)
WITH FUNCTION sat_int8to4(bigint) AS ASSIGNMENT;

CREATE CAST (integer AS saturated_int)
WITHOUT FUNCTION AS ASSIGNMENT;

CREATE FUNCTION sat_int4_sum(state saturated_int, val saturated_int)
RETURNS saturated_int
AS 'MODULE_PATHNAME'
LANGUAGE C IMMUTABLE PARALLEL SAFE;

CREATE AGGREGATE sum(saturated_int) (
    sfunc = sat_int4_sum,
    stype = saturated_int,
    -- combinefunc = ...,
    -- msfunc = ...,
    -- minvfunc = ...,
    -- mfinalfunc = ...,
    -- mstype = ...,
    -- minitcond = '{0, 0}',
    parallel = SAFE
);
