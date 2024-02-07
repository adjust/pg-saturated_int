SET enable_seqscan to off;

CREATE TABLE btree_test(id saturated_int);
INSERT INTO btree_test
SELECT i  FROM generate_series(1::int, 1e4::int) g(i);

CREATE INDEX btree_test_idx ON btree_test (id);

EXPLAIN (COSTS OFF, VERBOSE)
SELECT id FROM btree_test WHERE id = 5000::saturated_int;

SELECT id FROM btree_test WHERE id = 5000::saturated_int;

CREATE TABLE hash_test(id saturated_int);
INSERT INTO hash_test
SELECT i  FROM generate_series(1::int, 1e4::int) g(i);

CREATE INDEX hash_test_idx ON hash_test (id);

EXPLAIN (COSTS OFF, VERBOSE)
SELECT id FROM hash_test WHERE id = 5000::saturated_int;

SELECT id FROM hash_test WHERE id = 5000::saturated_int;
