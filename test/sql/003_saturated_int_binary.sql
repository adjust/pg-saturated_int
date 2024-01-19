CREATE TABLE before (i saturated_int);
CREATE TABLE after (i saturated_int);

INSERT INTO before VALUES (1), (-1), (2147483649), (-2147483649);
SELECT * FROM before;

COPY before TO '/tmp/tst' WITH (FORMAT binary);
COPY after FROM '/tmp/tst' WITH (FORMAT binary);

SELECT * FROM after;
