SET max_parallel_workers_per_gather=4;
SET parallel_setup_cost = 10;
SET parallel_tuple_cost = 0.001;

CREATE TABLE parallel_test(id1 saturated_int, id2 int) WITH (parallel_workers = 4);
INSERT INTO parallel_test
SELECT i, i FROM generate_series(1::int, 1e4::int) g(i);

EXPLAIN (COSTS OFF, VERBOSE)
SELECT count(*) FROM parallel_test WHERE id1 = 5000::saturated_int;

EXPLAIN (COSTS OFF, VERBOSE)
SELECT id1, count(*) FROM parallel_test GROUP BY 1;
