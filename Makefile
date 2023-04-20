src = $(wildcard *.c)
obj = $(src:.c=.o)

LDFLAGS = -Wl,--gc-sections
CFLAGS = -O3 -fdata-sections -ffunction-sections -DUNROLL_TRANSPOSE -g

name = bitslice

default: aes.so


$(name):  _testbench $(obj)
	$(CC) $(LDFLAGS) -o $@ $(obj) $(LDFLAGS)


test: _test $(obj)
	$(CC) $(LDFLAGS) -o $(name) $(obj) $(LDFLAGS)

footprint: _footprint $(obj)
	$(CC) $(LDFLAGS) -o $(name) $(obj) $(LDFLAGS)


_test: tests/tests.c
	$(eval obj+=$@.o)
	$(eval CFLAGS+= -DRUN_TESTS=1)
	$(CC) -c $(CFLAGS) -o $@.o $^

_footprint: tests/tests.c
	$(eval obj+=$@.o)
	$(eval CFLAGS+= -DRUN_TESTS=1 -DTEST_FOOTPRINT=1)
	$(CC) -c $(CFLAGS) -o $@.o $^

_testbench: testbench/app.c
	$(eval obj+=_testbench.o)
	$(eval LDFLAGS+= -lcrypto)
	$(CC) -c $(CFLAGS) -o $@.o $^

aes.so: aes.o bs.o key_schedule.o
	$(CC) -Wall -Os -g -shared -o libaes.so bs.o aes.o key_schedule.o

clean:
	rm -f $(obj) aes.o libaes.so _test.o _footprint.o _testbench.o $(name)
