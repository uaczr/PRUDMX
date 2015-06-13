






.origin 0
.entrypoint START





.macro LD32
.mparam dst,src
    LBBO dst,src,#0x00,4
.endm

.macro LD16
.mparam dst,src
    LBBO dst,src,#0x00,2
.endm

.macro LD8
.mparam dst,src
    LBBO dst,src,#0x00,1
.endm

.macro ST32
.mparam src,dst
    SBBO src,dst,#0x00,4
.endm

.macro ST16
.mparam src,dst
    SBBO src,dst,#0x00,2
.endm

.macro ST8
.mparam src,dst
    SBBO src,dst,#0x00,1
.endm

.macro stack_init
    mov r0, (0x2000 - 0x200)
.endm

.macro push
.mparam reg, cnt
    sbbo reg, r0, 0, 4*cnt
    add r0, r0, 4*cnt
.endm

.macro pop
.mparam reg, cnt
    sub r0, r0, 4*cnt
    lbbo reg, r0, 0, 4*cnt
.endm

.macro INCREMENT
.mparam reg
    add reg, reg, 1
.endm

.macro DECREMENT
.mparam reg
    sub reg, reg, 1
.endm







.macro SLEEPNS
.mparam ns,inst,lab
 MOV r7, (ns/10)-1-inst
lab:
 SUB r7, r7, 1
 QBNE lab, r7, 0
.endm



.macro WAITNS
.mparam ns,lab
 MOV r8, 0x22000




 MOV r28, (ns)/5 - 20
lab:
 LBBO r9, r8, 0xC, 4

 QBGT lab, r9, r28
.endm


.macro WAIT_TIMEOUT
.mparam timeoutNs, timeoutLabel

    MOV r28, ((timeoutNs)/5 - 20)
    QBGT timeoutLabel, r28, r9
.endm


.macro RESET_COUNTER

  MOV r8, 0x22000
  LBBO r9, r8, 0, 4
  CLR r9, r9, 3
  SBBO r9, r8, 0, 4

  MOV r28, 0
  SBBO r28, r8, 0xC, 4

  SET r9, r9, 3
  SBBO r9, r8, 0, 4




.endm


.macro RAISE_ARM_INTERRUPT

  MOV R31.b0, 19 +16



.endm


.macro ZERODMXBUFFER
    MOV r4, 36
 MOV r6, 1024
REDO:
    MOV r5, 0
 SBCO r5, C24, r4, 1
 ADD r4, r4, 1
 QBGT REDO, r4, r6
.endm




START:






 LBCO r0, C4, 4, 4
 CLR r0, r0, 4
 SBCO r0, C4, 4, 4




 MOV r0, 0x00000120
 MOV r1, 0x22028
 ST32 r0, r1




 MOV r0, 0x00100000
 MOV r1, 0x2202C
 ST32 r0, r1

 MOV r0, 0
 CLR r0, 0
 CLR r0, 13
 CLR r0, 14
 SBCO r0, C7, 0x30, 4



 LDI r0, #0x1
 SBCO r0, C7, 0x34, 4



 LDI r0, 59
 SBCO r0, C7, 0x20, 4


 LDI r0, 0
 SBCO r0, C7, 0x24, 4




 MOV r0, 0
 SET r0, 0
 SET r0, 1
 SET r0, 2
 SET r0, 3
 SET r0, 6
 SET r0, 7
 SBCO r0, C7, 0x8, 4


 MOV r0, 0
 SET r0, 0
 SET r0, 1
 SET r0, 2


 SBCO r0, C7, 0xC, 4


 MOV r0, 0

 SBCO r0, C7, 0x10, 4



 MOV r0, 0
 SET r0, 0
 SET r0, 1
 SET r0, 2
 SBCO r0, C7, 0x4, 4

 MOV r2, #0x1
 SBCO r2, C24, 12, 4



 MOV r20, 0xFFFFFFFF




_LOOP:


 RAISE_ARM_INTERRUPT



 LBCO r0, C24, 0, 12


 QBEQ _LOOP, r2, #0


 RESET_COUNTER




 MOV r3, 0
 SBCO r3, C24, 8, 4

 SBCO r18, C24, 16, 4

 QBEQ EXIT, r2, #0xFF


UARTSTART:




 MOV r10, 0
 MOV r13, 0
 MOV r9, 0
 MOV r15, 0
 MOV r18, 0
 MOV r14, 0
 SBCO r18, C24, 16, 4
 SBCO r9, C24, 20, 4
 SBCO r15, C24, 24, 4
 SBCO r10, C24, 28, 4
 SBCO r13, C24, 32, 4

 MOV r0, 0
 SET r0, 0
 SET r0, 13
 SET r0, 14
 SBCO r0, C7, 0x30, 4
 LBCO r9, C7, 0x14, 4
 LBCO r15, C7, 0x8, 4
 LDI r7, 125
 SBCO r7, C7, 0x0, 4
 ZERODMXBUFFER

WAITINTERRUPT:
 LBCO r2, C24, 8, 4
 QBEQ EXIT, r2, 0xFF
 LBCO r15, C7, 0x8, 4
 LBCO r9, C7, 0x14, 4
 QBBS WAITINTERRUPT, r15, 0

 SBCO r18, C24, 16, 1
 SBCO r15, C24, 20, 4
 SBCO r9, C24, 24, 4
 SBCO r10, C24, 28, 4
 SBCO r13, C24, 32, 4
 SBCO r7, C24, 36, 4
 MOV r7, r15
 MOV r6, 0xE

 AND r7, r7, r6

 QBEQ RBRINTERRUPT, r7, 4
 QBEQ LSRINTERRUPT, r7, 6
 QBEQ THRINTERRUPT, r7, 2


RBRINTERRUPT:
 LBCO r18, C7, 0x0, 4
 LDI r14, 40
 ADD r14, r14, r13
 SBCO r18, C24, r14, 1
 ADD r10, r10, 1
 ADD r13, r13, 1
 SBCO r18, C7, 0x0, 4
 LBCO r9, C7, 0x14, 4
 QBBS RBRINTERRUPT, r9, 0
 JMP WAITINTERRUPT

LSRINTERRUPT:
 LBCO r9, C7, 0x14, 4
 QBBC NOBREAK, r9, 4
  LBCO r18, C7, 0x0, 4
  MOV r13, 0
  NOBREAK:
 LBCO r9, C7, 0x14, 4
 QBBC NOOVERUN, r9, 1
  LBCO r18, C7, 0x0, 4
  NOOVERUN:
 LBCO r9, C7, 0x14, 4
 QBBC NOFRAME, r9, 3
  LBCO r18, C7, 0x0, 4
  NOFRAME:

 JMP WAITINTERRUPT


THRINTERRUPT:

 JMP WAITINTERRUPT


EXIT:

 MOV r2, #0xFF
 SBCO r2, C24, 12, 4

 LBCO r0, C7, 0x30, 4
 MOV r0, #0x0
 SBCO r0, C7, 0x30, 4

 RAISE_ARM_INTERRUPT

 HALT
