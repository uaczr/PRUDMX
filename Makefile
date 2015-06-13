CXXFLAGS = -Wall -D__DEBUG -O2 -mtune=cortex-a8 -march=armv7-a -std=c++11
CFLAGS+= -Wall -D__DEBUG -O2 -mtune=cortex-a8 -march=armv7-a -std=c99
LDFLAGS+=-Lbin -lprussdrv

all: dmxrec.bin dmxrechost

clean:
	rm -f dmxrec *.o *.bin *.p.i pru/bin/dmxrec.bin

dmxrec.bin: dmxrec.p
	mkdir -p bin
	cd `dirname $@` && gcc -E - < $(notdir $<) | perl -p -e 's/^#.*//; s/;/\n/g; s/BYTE\((\d+)\)/t\1/g' > $(notdir $<).i
	pasm -V3 -b $<.i pru/bin/$(notdir $(basename $@))
DMXTest.o: DMXTest.cpp ledscape.h pru.h prussdrv.h util.h pruss_intc_mapping.h
	$(CROSS_COMPILE)g++ $(CXXFLAGS) -c -o $@ $<

ledscape.o: ledscape.c ledscape.h pru.h prussdrv.h util.h pruss_intc_mapping.h
	$(CROSS_COMPILE)gcc $(CFLAGS) -c -o $@ $<

pru.o: pru.c ledscape.h pru.h prussdrv.h util.h pruss_intc_mapping.h
	$(CROSS_COMPILE)gcc $(CFLAGS) -c -o $@ $<
util.o: util.c ledscape.h pru.h prussdrv.h util.h pruss_intc_mapping.h
	$(CROSS_COMPILE)gcc $(CFLAGS) -c -o $@ $<

dmxrechost:DMXTest.o ledscape.o pru.o util.o
	$(CROSS_COMPILE)g++ $(CXXFLAGS) -o $@ $^ $(LDFLAGS)


