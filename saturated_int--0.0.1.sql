-- Define saturated_int

CREATE FUNCTION saturated_int_in(cstring)
RETURNS saturated_int
AS 'MODULE_PATHNAME'
LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION saturated_int_out(saturated_int)
RETURNS cstring
AS 'int4out'
LANGUAGE internal IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION saturated_int_recv(internal)
RETURNS saturated_int
AS 'int4recv'
LANGUAGE internal IMMUTABLE PARALLEL SAFE;

CREATE FUNCTION saturated_int_send(saturated_int)
RETURNS bytea
AS 'int4send'
LANGUAGE internal IMMUTABLE PARALLEL SAFE;

CREATE TYPE saturated_int (
    input = saturated_int_in,
    output = saturated_int_out,
    receive = saturated_int_recv,
    send = saturated_int_send,
    like = integer,
    category = 'N'
);

-- Define casts into saturated_int

CREATE FUNCTION saturated_int8to4(bigint)
RETURNS saturated_int
AS 'MODULE_PATHNAME'
LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE CAST (bigint AS saturated_int)
WITH FUNCTION saturated_int8to4(bigint) AS ASSIGNMENT;

CREATE CAST (integer AS saturated_int)
WITHOUT FUNCTION AS ASSIGNMENT;

CREATE CAST (saturated_int as integer)
WITHOUT FUNCTION AS ASSIGNMENT;

-- Define comparison operators

CREATE FUNCTION saturated_int_eq(saturated_int, saturated_int)
RETURNS boolean
AS 'int4eq'
LANGUAGE internal IMMUTABLE PARALLEL SAFE;

CREATE FUNCTION saturated_int_ne(saturated_int, saturated_int)
RETURNS boolean
AS 'int4ne'
LANGUAGE internal IMMUTABLE PARALLEL SAFE;

CREATE FUNCTION saturated_int_lt(saturated_int, saturated_int)
RETURNS boolean
AS 'int4lt'
LANGUAGE internal IMMUTABLE PARALLEL SAFE;

CREATE FUNCTION saturated_int_le(saturated_int, saturated_int)
RETURNS boolean
AS 'int4le'
LANGUAGE internal IMMUTABLE PARALLEL SAFE;

CREATE FUNCTION saturated_int_gt(saturated_int, saturated_int)
RETURNS boolean
AS 'int4gt'
LANGUAGE internal IMMUTABLE PARALLEL SAFE;

CREATE FUNCTION saturated_int_ge(saturated_int, saturated_int)
RETURNS boolean
AS 'int4ge'
LANGUAGE internal IMMUTABLE PARALLEL SAFE;

CREATE FUNCTION saturated_int_cmp(saturated_int, saturated_int)
RETURNS integer
AS 'btint4cmp'
LANGUAGE internal IMMUTABLE PARALLEL SAFE;

CREATE FUNCTION hash_saturated_int(saturated_int)
RETURNS integer
AS 'hashint4'
LANGUAGE internal IMMUTABLE PARALLEL SAFE;

CREATE OPERATOR = (
    leftarg = saturated_int,
    rightarg = saturated_int,
    procedure = saturated_int_eq,
    commutator = '=',
    negator = '<>',
    restrict = eqsel,
    join = eqjoinsel,
    hashes, merges
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

CREATE OPERATOR > (
    leftarg = saturated_int,
    rightarg = saturated_int,
    procedure = saturated_int_gt,
    commutator = '<',
    negator = '<=',
    restrict = scalargtsel,
    join = scalargtjoinsel
);
COMMENT ON OPERATOR >(saturated_int, saturated_int) IS 'greater than';

DO $$
BEGIN
    IF current_setting('server_version_num')::int >= 110000 THEN
        CREATE OPERATOR <= (
            leftarg = saturated_int,
            rightarg = saturated_int,
            procedure = saturated_int_le,
            commutator = '>=',
            negator = '>',
            restrict = scalarlesel,
            join = scalarlejoinsel
        );

        CREATE OPERATOR >= (
            leftarg = saturated_int,
            rightarg = saturated_int,
            procedure = saturated_int_ge,
            commutator = '<=',
            negator = '<',
            restrict = scalargesel,
            join = scalargejoinsel
        );
    ELSE
        CREATE OPERATOR <= (
            leftarg = saturated_int,
            rightarg = saturated_int,
            procedure = saturated_int_le,
            commutator = '>=',
            negator = '>',
            restrict = scalarltsel,
            join = scalarltjoinsel
        );

        CREATE OPERATOR >= (
            leftarg = saturated_int,
            rightarg = saturated_int,
            procedure = saturated_int_ge,
            commutator = '<=',
            negator = '<',
            restrict = scalargtsel,
            join = scalargtjoinsel
        );
    END IF;
END;
$$;
COMMENT ON OPERATOR >=(saturated_int, saturated_int) IS 'greater than or equal';
COMMENT ON OPERATOR <=(saturated_int, saturated_int) IS 'less than or equal';

CREATE OPERATOR CLASS btree_saturated_int_ops
DEFAULT FOR TYPE saturated_int USING btree
AS
    OPERATOR    1   <,
    OPERATOR    2   <=,
    OPERATOR    3   =,
    OPERATOR    4   >=,
    OPERATOR    5   >,
    FUNCTION    1   saturated_int_cmp(saturated_int, saturated_int);

CREATE OPERATOR CLASS hash_saturated_int_ops
DEFAULT FOR TYPE saturated_int USING hash
AS
    OPERATOR    1   =,
    FUNCTION    1   hash_saturated_int(saturated_int);

-- Define arithmetic operators

CREATE FUNCTION saturated_int_mul(saturated_int, saturated_int)
RETURNS saturated_int
AS 'MODULE_PATHNAME'
LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE OPERATOR * (
    leftarg = saturated_int,
    rightarg = saturated_int,
    procedure = saturated_int_mul,
    commutator = '*'
);
COMMENT ON OPERATOR *(saturated_int, saturated_int) IS 'multiply';

CREATE FUNCTION saturated_int_div(saturated_int, saturated_int)
RETURNS saturated_int
AS 'MODULE_PATHNAME'
LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE OPERATOR / (
    leftarg = saturated_int,
    rightarg = saturated_int,
    procedure = saturated_int_div
);
COMMENT ON OPERATOR /(saturated_int, saturated_int) IS 'divide';

CREATE FUNCTION saturated_int_mod(saturated_int, saturated_int)
RETURNS saturated_int
AS 'int4mod'
LANGUAGE internal IMMUTABLE PARALLEL SAFE;

CREATE OPERATOR % (
    leftarg = saturated_int,
    rightarg = saturated_int,
    procedure = saturated_int_mod
);
COMMENT ON OPERATOR %(saturated_int, saturated_int) IS 'modulus';

CREATE FUNCTION saturated_int_pl(saturated_int, saturated_int)
RETURNS saturated_int
AS 'MODULE_PATHNAME'
LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE OPERATOR + (
    leftarg = saturated_int,
    rightarg = saturated_int,
    procedure = saturated_int_pl,
    commutator = '+'
);
COMMENT ON OPERATOR +(saturated_int, saturated_int) IS 'add';

CREATE FUNCTION saturated_int_mi(saturated_int, saturated_int)
RETURNS saturated_int
AS 'MODULE_PATHNAME'
LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE OPERATOR - (
    leftarg = saturated_int,
    rightarg = saturated_int,
    procedure = saturated_int_mi
);
COMMENT ON OPERATOR -(saturated_int, saturated_int) IS 'subtract';

-- Define aggregate functions

CREATE FUNCTION saturated_int_sum(state saturated_int, val saturated_int)
RETURNS saturated_int
AS 'MODULE_PATHNAME'
LANGUAGE C IMMUTABLE PARALLEL SAFE;

CREATE AGGREGATE sum(saturated_int) (
    sfunc = saturated_int_sum,
    stype = saturated_int,
    -- combinefunc = ...,
    -- msfunc = ...,
    -- minvfunc = ...,
    -- mfinalfunc = ...,
    -- mstype = ...,
    -- minitcond = '{0, 0}',
    parallel = SAFE
);
