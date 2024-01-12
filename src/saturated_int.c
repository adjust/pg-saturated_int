#include "postgres.h"
#include "fmgr.h"

#include <limits.h>

#include "utils/builtins.h"

PG_MODULE_MAGIC;

PG_FUNCTION_INFO_V1(sat_int4_in);
PG_FUNCTION_INFO_V1(sat_int8to4);
PG_FUNCTION_INFO_V1(sat_int4_sum);

/*
 * Cast bigint to integer with saturation.
 *
 * Return INT_MIN if the parsed value less than INT_MIN.
 * Return INT_MAX if the parsed value greater than INT_MAX.
 */
static inline int32
sat_int8to4_impl(int64 num)
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
sat_int4_in(PG_FUNCTION_ARGS)
{
	char	   *arg = PG_GETARG_CSTRING(0);

	PG_RETURN_INT32(sat_int8to4_impl(pg_strtoint64(arg)));
}

/*
 * Cast bigint to integer with saturation.
 */
Datum
sat_int8to4(PG_FUNCTION_ARGS)
{
	int64		arg = PG_GETARG_INT64(0);

	PG_RETURN_INT32(sat_int8to4_impl(arg));
}

/*
 * Compute the saturating addition (https://en.wikipedia.org/wiki/Saturation_arithmetic).
 */
Datum
sat_int4_sum(PG_FUNCTION_ARGS)
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
	if (oldsum >= 0 && newval > INT_MAX - oldsum)
		PG_RETURN_INT32(INT_MAX);
	else if (oldsum < 0 && newval < INT_MIN - oldsum)
		PG_RETURN_INT32(INT_MIN);

	/* It is safe to return sum */
	PG_RETURN_INT32(oldsum + newval);
}
