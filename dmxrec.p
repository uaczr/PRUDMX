// WS281x Signal Generation PRU Program Template
//

//
//

// Mapping lookup

.origin 0
.entrypoint START

#include "dmxrec.hp"

#define CHECK_TIMEOUT WAIT_TIMEOUT 3000, FRAME_DONE

START:
	

	// Enable OCP master port
	// clear the STANDBY_INIT bit in the SYSCFG register,
	// otherwise the PRU will not be able to write outside the
	// PRU memory space and to the BeagleBon's pins.
	LBCO	r0, C4, 4, 4
	CLR		r0, r0, 4
	SBCO	r0, C4, 4, 4

	// Configure the programmable pointer register for PRU0 by setting
	// c28_pointer[15:0] field to 0x0120.  This will make C28 point to
	// 0x00012000 (PRU shared RAM).
	MOV		r0, 0x00000120
	MOV		r1, CTPPR_0
	ST32	r0, r1

	// Configure the programmable pointer register for PRU0 by setting
	// c31_pointer[15:0] field to 0x0010.  This will make C31 point to
	// 0x80001000 (DDR memory).
	MOV		r0, 0x00100000
	MOV		r1, CTPPR_1
	ST32	r0, r1
	
	MOV r0, 0
	CLR r0, UART_FREE					//FREE RUNNING MODE
	CLR r0, UART_URRST					//ENABLE RECEIVE
	CLR r0, UART_UTRST					//ENABLE TRANSMIT
	UART_PWR_WRITE(r0)
	
	
	//MDR REGISTER
	LDI r0, #0x1				//16x Clock Devisor
	UART_MDR_WRITE(r0)
	
	
	//DLL REGISTER
	LDI r0, 59
	UART_DLL_WRITE(r0) 		//DEVISOR 48
	
	//DLH REGISTER
	LDI r0, 0
	UART_DLH_WRITE(r0)
	

	
	//FCR REGISTER
	MOV r0, 0
	SET r0, UART_FIFOEN			//enable FIFO-MODE
	SET r0, UART_RXCLR			//clear RECEIVER FIFO
	SET r0, UART_TXCLR			//clear transmitter FIFO
	SET r0, UART_DMAMODE1		//ENABLE Dmamode1 for FIFOS
	SET r0, UART_RXFIFTL1		//1 byte fifo
	SET r0, UART_RXFIFTL2
	UART_FCR_WRITE(r0)
	
	//LCR REGISTER
	MOV r0, 0
	SET r0, UART_WLS1			//8 Data bits
	SET r0, UART_WLS2
	SET r0, UART_STB
	//SET r0, UART_DLAB
	//MOV r0, 0x5;//2 Stop bits -- 1 bei empfang
	UART_LCR_WRITE(r0)

	//MCR REGISTER
	MOV r0, 0
	//SET r0, 4
	UART_MCR_WRITE(r0)
	
	//Setup UART for Serial-Receive
	//IER REGISTER
	MOV r0, 0
	SET r0, UART_ERBI		//ENABLE RECEIVER line status interrupt
	SET r0, UART_ETBEI		//enable transmitter holding register
	SET r0, UART_ELSI		//enable data available interrupt
	UART_IER_WRITE(r0)		//write to register


	

	
	

	
	MOV r2, #0x1
	SBCO r2, CONST_PRUDRAM, 12, 4
	
	

	MOV r20, 0xFFFFFFFF
	// Wait for the start condition from the main program to indicate
	// that we have a rendered frame ready to clock out.  This also
	// handles the exit case if an invalid value is written to the start
	// start position.
_LOOP:
	// Let ledscape know that we're starting the loop again. It waits for this
	// interrupt before sending another frame
	RAISE_ARM_INTERRUPT
	// Load the pointer to the buffer from PRU DRAM into r0 and the
	// length (in bytes-bit words) into r1.
	// start command into r2
	LBCO      r_data_addr, CONST_PRUDRAM, 0, 12

	// Wait for a non-zero command
	QBEQ _LOOP, r2, #0

	// Reset the sleep timer
	RESET_COUNTER

	// Zero out the start command so that they know we have received it
	// This allows maximum speed frame drawing since they know that they
	// can now swap the frame buffer pointer and write a new start command.
	MOV r3, 0
	SBCO r3, CONST_PRUDRAM, 8, 4

	SBCO dmx_data, CONST_PRUDRAM, 16, 4
	// Command of 0xFF is the signal to exit
	QBEQ EXIT, r2, #0xFF

	
UARTSTART:
	//Enable Rx and Tx, running in Free-Mode
	//LOADREG(r0, UART_PWREMU_MGMT)
	//MOV r0,0x6001
	
	MOV counter, 0
	MOV counter2, 0
	MOV lsr_register, 0
	MOV iir_register, 0
	MOV dmx_data, 0
	MOV write_pos, 0
	SBCO dmx_data, CONST_PRUDRAM, 16, 4
	SBCO lsr_register, CONST_PRUDRAM, 20, 4
	SBCO iir_register, CONST_PRUDRAM, 24, 4
	SBCO counter, CONST_PRUDRAM, 28, 4
	SBCO counter2, CONST_PRUDRAM, 32, 4
	
	MOV r0, 0
	SET r0, UART_FREE					//FREE RUNNING MODE
	SET r0, UART_URRST					//ENABLE RECEIVE
	SET r0, UART_UTRST					//ENABLE TRANSMIT
	UART_PWR_WRITE(r0)
	LOADREG(lsr_register, UART_LSR)
	LOADREG(iir_register, UART_IIR)
	LDI r7, 125
	UART_THR_WRITE(r7)
	ZERODMXBUFFER

WAITINTERRUPT:
	LOADCOMMAND											//LADE command
	BREAKCHECKCOMMAND									//checke ob Abbruch
	LOADREG(iir_register, UART_IIR)						//Lade iir
	LOADREG(lsr_register, UART_LSR)
	QBBS WAITINTERRUPT, iir_register, UART_IPEND
	//LDI write_pos, 16
	SBCO dmx_data, CONST_PRUDRAM, 16, 1
	SBCO iir_register, CONST_PRUDRAM, 20, 4				//Speichere iir in Channel2
	SBCO lsr_register, CONST_PRUDRAM, 24, 4				//Speichere lsr in Channel3
	SBCO counter, CONST_PRUDRAM, 28, 4					//Speichere lsr in Channel3
	SBCO counter2, CONST_PRUDRAM, 32, 4					//Speichere lsr in Channel3
	SBCO r7, CONST_PRUDRAM, 36, 4
	MOV r7, iir_register
	MOV r6, 0xE
	
	AND r7, r7, r6
	//SBCO r7, CONST_PRUDRAM, 32, 4	
	QBEQ RBRINTERRUPT, r7, 4
	QBEQ LSRINTERRUPT, r7, 6
	QBEQ THRINTERRUPT, r7, 2
	
	
RBRINTERRUPT:
	LOADREG(dmx_data, UART_RBR)
	LDI write_pos, 40
	ADD write_pos, write_pos, counter2
	SBCO dmx_data, CONST_PRUDRAM, write_pos, 1
	ADD counter, counter, 1
	ADD counter2, counter2, 1
	UART_THR_WRITE(dmx_data)
	LOADREG(lsr_register, UART_LSR)
	QBBS RBRINTERRUPT, lsr_register, UART_DR
	JMP WAITINTERRUPT

LSRINTERRUPT:
	LOADREG(lsr_register, UART_LSR)	
	QBBC NOBREAK, lsr_register, UART_BI
		LOADREG(dmx_data, UART_RBR)
		MOV counter2, 0
		NOBREAK:
	LOADREG(lsr_register, UART_LSR)	
	QBBC NOOVERUN, lsr_register, UART_OE
		LOADREG(dmx_data, UART_RBR)
		NOOVERUN:
	LOADREG(lsr_register, UART_LSR)	
	QBBC NOFRAME, lsr_register, UART_FE
		LOADREG(dmx_data, UART_RBR)
		NOFRAME:
		
	JMP WAITINTERRUPT
	
	
THRINTERRUPT:
	
	JMP WAITINTERRUPT
	

EXIT:
	// Write a 0xFF into the response field so that they know we're done
	MOV r2, #0xFF
	SBCO r2, CONST_PRUDRAM, 12, 4
	//Disable UArt before Halting
	LOADREG(r0,UART_PWREMU_MGMT)
	MOV r0, #0x0
	WRITEREG(r0,UART_PWREMU_MGMT)
	
	RAISE_ARM_INTERRUPT

	HALT
