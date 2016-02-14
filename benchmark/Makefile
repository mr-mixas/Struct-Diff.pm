PATH := .:$(PATH)

.PHONY: all benchmark clean

all: benchmark

benchmark: Structs.pm
	benchmark.pl

clean:
	rm -f Structs.pm

Structs.pm:
	mk_struct.pl > $@.TMP
	mv $@.TMP $@
