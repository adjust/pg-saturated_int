EXTENSION = saturated_int
MODULE_big = saturated_int

PG_CONFIG ?= PG_CONFIG

DATA = $(wildcard *--*.sql)
OBJS = $(patsubst %.c,%.o,$(wildcard src/*.c))

PGXS := $(shell $(PG_CONFIG) --pgxs)

include $(PGXS)
