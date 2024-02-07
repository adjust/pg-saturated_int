#include "c.h"
#include "postgres.h"
#include "fmgr.h"

#include <limits.h>

#include "utils/builtins.h"
#if PG_VERSION_NUM < 150000
#include "utils/int8.h"
#endif

PG_MODULE_MAGIC;

PG_FUNCTION_INFO_V1(saturated_int_in);
PG_FUNCTION_INFO_V1(saturated_int8to4);

PG_FUNCTION_INFO_V1(saturated_int_sum);

PG_FUNCTION_INFO_V1(saturated_int_mul);
PG_FUNCTION_INFO_V1(saturated_int_div);
PG_FUNCTION_INFO_V1(saturated_int_pl);
PG_FUNCTION_INFO_V1(saturated_int_mi);

/*
 * Cast bigint to integer with saturation.
 *
 * Return INT_MIN if the parsed value less than INT_MIN.
 * Return INT_MAX if the parsed value greater than INT_MAX.
 */
static inline int32
saturated_int8to4_impl(int64 num)
{
	if (unlikely(num < INT_MIN))
		return INT_MIN;
	if (unlikely(num > INT_MAX))
		return INT_MAX;

	return (int32) num;
}

/*
 * Parse integer with saturation.
 */
Datum
saturated_int_in(PG_FUNCTION_ARGS)
{
	char	   *arg = PG_GETARG_CSTRING(0);

#if PG_VERSION_NUM < 150000
	int64		result;
	(void) scanint8(arg, false, &result);
	PG_RETURN_INT32(saturated_int8to4_impl(result));
#else
	PG_RETURN_INT32(saturated_int8to4_impl(pg_strtoint64(arg)));
#endif
}

/*
 * Cast bigint to integer with saturation.
 */
Datum
saturated_int8to4(PG_FUNCTION_ARGS)
{
	int64		arg = PG_GETARG_INT64(0);

	PG_RETURN_INT32(saturated_int8to4_impl(arg));
}

/*
 * Compute the saturating addition (https://en.wikipedia.org/wiki/Saturation_arithmetic).
 */
Datum
saturated_int_sum(PG_FUNCTION_ARGS)
{
	int32		oldsum = PG_GETARG_INT32(0);
	int32		newval;

	if (PG_ARGISNULL(0))
	{
		/* No non-null input seen so far... */
		if (PG_ARGISNULL(1))
			PG_RETURN_NULL();	/* still no non-null */
		/* This is the first non-null input. */
		PG_RETURN_INT32(PG_GETARG_INT32(1));
	}

	/* Leave sum unchanged if new input is null. */
	if (PG_ARGISNULL(1))
		PG_RETURN_INT32(oldsum);

	/*
	 * Check for overflow.
	 * If oldsum >= 0 there can be only overflow if newval > INT_MAX - oldsum.
	 * If oldsum < 0 there can be only overflow if newval < INT_MIN - oldsum.
	 */
	newval = PG_GETARG_INT32(1);
	if (unlikely(oldsum >= 0 && newval > INT_MAX - oldsum))
		PG_RETURN_INT32(INT_MAX);
	else if (unlikely(oldsum < 0 && newval < INT_MIN - oldsum))
		PG_RETURN_INT32(INT_MIN);

	/* It is safe to return sum */
	PG_RETURN_INT32(oldsum + newval);
}

/*
 * Arithmetic functions for operators.
 */

Datum
saturated_int_mul(PG_FUNCTION_ARGS)
{
	int32		arg1 = PG_GETARG_INT32(0);
	int32		arg2 = PG_GETARG_INT32(1);

	PG_RETURN_INT32(saturated_int8to4_impl((int64) arg1 * (int64) arg2));
}

/*
 * Copy of int4div() with changes for saturated_int.
 */
Datum
saturated_int_div(PG_FUNCTION_ARGS)
{
	int32		arg1 = PG_GETARG_INT32(0);
	int32		arg2 = PG_GETARG_INT32(1);
	int32		result;

	if (unlikely(arg2 == 0))
	{
		ereport(ERROR,
				(errcode(ERRCODE_DIVISION_BY_ZERO),
				 errmsg("division by zero")));
		/* ensure compiler realizes we mustn't reach the division (gcc bug) */
		PG_RETURN_NULL();
	}

	/*
	 * INT_MIN / -1 will return INT_MAX, which isn't exactly just negation.
	 */
	if (arg2 == -1)
	{
		if (unlikely(arg1 == PG_INT32_MIN))
			PG_RETURN_INT32(PG_INT32_MAX);
		result = -arg1;
		PG_RETURN_INT32(result);
	}

	/* No overflow is possible */

	result = arg1 / arg2;

	PG_RETURN_INT32(result);
}

Datum
saturated_int_pl(PG_FUNCTION_ARGS)
{
	int32		arg1 = PG_GETARG_INT32(0);
	int32		arg2 = PG_GETARG_INT32(1);

	PG_RETURN_INT32(saturated_int8to4_impl((int64) arg1 + (int64) arg2));
}

Datum
saturated_int_mi(PG_FUNCTION_ARGS)
{
	int32		arg1 = PG_GETARG_INT32(0);
	int32		arg2 = PG_GETARG_INT32(1);

	PG_RETURN_INT32(saturated_int8to4_impl((int64) arg1 - (int64) arg2));
}
