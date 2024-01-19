-- Define saturated_int

CREATE FUNCTION sat_int4_in(cstring)
RETURNS saturated_int
AS 'MODULE_PATHNAME'
LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION sat_int4_out(saturated_int)
RETURNS cstring
AS 'int4out'
LANGUAGE internal IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION sat_int4_recv(internal)
RETURNS saturated_int
AS 'int4recv'
LANGUAGE internal IMMUTABLE PARALLEL SAFE;

CREATE FUNCTION sat_int4_send(saturated_int)
RETURNS bytea
AS 'int4send'
LANGUAGE internal IMMUTABLE PARALLEL SAFE;

CREATE TYPE saturated_int (
    input = sat_int4_in,
    output = sat_int4_out,
    receive = sat_int4_recv,
    send = sat_int4_send,
    like = integer,
    category = 'N'
);

-- Define casts into saturated_int

CREATE FUNCTION sat_int8to4(bigint)
RETURNS saturated_int
AS 'MODULE_PATHNAME'
LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE CAST (bigint AS saturated_int)
WITH FUNCTION sat_int8to4(bigint) AS ASSIGNMENT;

CREATE CAST (integer AS saturated_int)
WITHOUT FUNCTION AS ASSIGNMENT;

-- Define comparison operators

CREATE FUNCTION saturated_int_eq(saturated_int, saturated_int)
RETURN boolean
AS 'int4eq'
LANGUAGE internal IMMUTABLE PARALLEL SAFE;

CREATE FUNCTION saturated_int_ne(saturated_int, saturated_int)
RETURN boolean
AS 'int4ne'
LANGUAGE internal IMMUTABLE PARALLEL SAFE;

CREATE FUNCTION saturated_int_lt(saturated_int, saturated_int)
RETURN boolean
AS 'int4lt'
LANGUAGE internal IMMUTABLE PARALLEL SAFE;

CREATE FUNCTION saturated_int_le(saturated_int, saturated_int)
RETURN boolean
AS 'int4le'
LANGUAGE internal IMMUTABLE PARALLEL SAFE;

CREATE FUNCTION saturated_int_gt(saturated_int, saturated_int)
RETURN boolean
AS 'int4gt'
LANGUAGE internal IMMUTABLE PARALLEL SAFE;

CREATE FUNCTION saturated_int_ge(saturated_int, saturated_int)
RETURN boolean
AS 'int4ge'
LANGUAGE internal IMMUTABLE PARALLEL SAFE;

CREATE FUNCTION saturated_int_cmp(saturated_int, saturated_int)
RETURN integer
AS 'btint4cmp'
LANGUAGE internal IMMUTABLE PARALLEL SAFE;

CREATE FUNCTION hash_saturated_int(saturated_int)
RETURN integer
AS 'hashint4'
LANGUAGE internal IMMUTABLE PARALLEL SAFE;

CREATE OPERATOR = (
    leftarg = saturated_int,
    rightarg = saturated_int,
    procedure = saturated_int_eq,
    commutator = '=',
    negator = '<>',
    restrict = eqsel,
    join = eqjoinsel
);
COMMENT ON OPERATOR =(saturated_int, saturated_int) IS 'equals';

CREATE OPERATOR <> (
    leftarg = saturated_int,
    rightarg = saturated_int,
    procedure = saturated_int_ne,
    commutator = '<>',
    negator = '=',
    restrict = neqsel,
    join = neqjoinsel
);
COMMENT ON OPERATOR <>(saturated_int, saturated_int) IS 'not equals';

CREATE OPERATOR < (
    leftarg = saturated_int,
    rightarg = saturated_int,
    procedure = saturated_int_lt,
    commutator = '>',
    negator = '>=',
    restrict = scalarltsel,
    join = scalarltjoinsel
);
COMMENT ON OPERATOR <(saturated_int, saturated_int) IS 'less than';

CREATE OPERATOR <= (
    leftarg = saturated_int,
    rightarg = saturated_int,
    procedure = saturated_int_le,
    commutator = '>=',
    negator = '>',
    restrict = scalarlesel,
    join = scalarlejoinsel
);
COMMENT ON OPERATOR <(saturated_int, saturated_int) IS 'less than or equal';

-- Define aggregate functions

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
