extern "C" {
#include "ledscape.h"
#include <stdint.h>
}
#include <iostream>
#include <chrono>

using namespace std;

typedef struct dmxChannels
{
	// in the DDR shared with the PRU
	uintptr_t pixels_dma;

	// Length in pixels of the longest LED strip.
	unsigned num_pixels;

	// write 1 to start, 0xFF to abort. will be cleared when started
	volatile unsigned command;

	// will have a non-zero response written when done
	volatile unsigned response;

	volatile unsigned int channel1;
	volatile unsigned int channel2;
	volatile unsigned int channel3;
	volatile unsigned int channel4;
	volatile unsigned int channel5;
	volatile unsigned int channel6;
} __attribute__((__packed__)) dmxChannels_t;


int main() {
	ledscape_t* leds;
	leds = ledscape_init_dmx(48);
	dmxChannels_t* dataram = (dmxChannels_t*)leds->pru1->data_ram;
	uint8_t* inDmx512 = (uint8_t*)leds->pru1->data_ram;
	inDmx512 += 40;
	uint8_t* outDMX512 = inDmx512 + 512;
	ledscape_frame(leds, 0);
	cout << dataram->response << endl;
	dataram->command = 1;
	for(int i = 0; i < 10; i++){
		if(dataram->channel1 != 2)
		{
		cout << dataram->channel1 << endl;
		cout << dataram->channel2 << endl;
		cout << dataram->channel3 << endl;
		cout << dataram->channel4 << endl;
		cout << dataram->channel5 << endl;
		for(int j = 0; j < 255; j++){
			cout << (int)inDmx512[j] << " ";
		}
		cout << " " << endl;

		cin.get();
		}
		usleep(2);
	}
	ledscape_close(leds);
	return 0;
}
