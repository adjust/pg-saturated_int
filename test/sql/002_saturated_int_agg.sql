CREATE TABLE sat_agg (id1 saturated_int, id2 saturated_int);

INSERT INTO sat_agg
SELECT i, 1 FROM pg_catalog.generate_series(2147483645::bigint, 2147483650::bigint) g(i);

SELECT * FROM sat_agg;

-- Test aggregate functions
SELECT sum(id1), sum(id2) FROM sat_agg;
