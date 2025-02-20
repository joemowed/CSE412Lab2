;  Division Source Code, Single Call
;  
;  Declare Variables
;  ******************************
            .DSEG                           ;  location counter in data segment
            .ORG     0x100                  ;  originate data storage at address 0x100
quotient:   .BYTE    1                      ;  uninitialized quotient variable stored in SRAM aka data segment
remainder:  .BYTE    1                      ;  uninitialized remainder variable stored in SRAM
            .SET     count=0                ;  initialized count variable stored in SRAM
;  ******************************
            .CSEG                           ;  Declare and Initialize Constants (modify them for different results)
            .EQU     dividend=20            ;  8-bit dividend constant (positive integer) stored in FLASH memory aka code segment
            .EQU     divisor=3              ;  8-bit divisor constant (positive integer) stored in FLASH memory
;  ******************************
;  * Vector Table (partial)
;  ******************************
            .ORG     0x0                    ;  set location counter to 0x0
reset:      JMP      main                   ;  RESET Vector at address 0x0 in FLASH memory (handled by MAIN)
int0v:      JMP      int0h                  ;  External interrupt vector at address 0x2 in Flash memory (handled by int0)
;  ******************************
;  * MAIN entry point to program*
;  ******************************
            .ORG     0x100                  ;  originate MAIN at address 0x100 in FLASH memory (step through the code)
;  For these stack is shown as array of 2-byte values, with value at first index bottom of stack and value at top as last index (e.g. [bottom,middle1,middle2...,top]
main:       CALL     init                   ;  call init routine, SP=0x08FF ,Stack = [],PC=0x0100
endmain:    JMP      endmain                ;  halt program, SP=0x08FF,Stack=[],PC=0x0102
init:       LDS      r0     ,  count        ;  SP=0x08FD, Stack=[0x0102], PC=0x0104
            STS      quotient,  r0          ;  use the same r0 value to clear the quotient-
            STS      remainder,  r0         ;  and the remainder storage locations
            RCALL    getnums                ;  call getnums, SP and stack unchanged from start of init call, PC=0x010A
            RET                             ;  SP=0x08FD, Stack=[0x0102],PC=0x010F
getnums:    LDI      r30    ,  dividend     ;  SP=0x08FB, Stack=[0x0102,0x010B], PC=0x010C
            LDI      r31    ,  divisor      ;  load divisor into r31
            RCALL    test                   ;  call test, SP and Stack unchanged from start of call, PC=0x010E
            RET                             ;  SP=0x08FB, Stack=[0x0102,0x010B], PC=0x010F
test:       CPI      r30    ,  0            ;  is dividend == 0 ?
            BRNE     test2                  ;  run code at test2 if this test passes
test1:      JMP      test1                  ;  halt program, output = 0 quotient and 0 remainder
test2:      CPI      r31    ,  0            ;  is divisor == 0 ?
            BRNE     test4                  ;  run code at test4 if this test passes
            LDI      r30    ,  0xEE         ;  set output to all EE's = Error division by 0
            STS      quotient,  r30         ;  store 0xEE @ quotient address
            STS      remainder,  r30        ;  store 0xEE @ remainder address
test3:      JMP      test3                  ;  halt program, look at output
test4:      CP       r30    ,  r31          ;  is dividend == divisor ?
            BRNE     test6                  ;  run code at test6 if this test passes
            LDI      r30    ,  1            ;  then set output accordingly
            STS      quotient,  r30         ;  store 0x1 at quotient if divisor==dividend
test5:      JMP      test5                  ;  halt program, look at output
test6:      BRPL     test8                  ;  is dividend < divisor ?
            SER      r30                    ;  set r30 to 0xFF
            STS      quotient,  r30         ;  set quotient to 0xFF
            STS      remainder,  r30        ;  set output to all FF's = not solving Fractions in this program
test7:      JMP      test7                  ;  halt program look at output
test8:      RCALL    divide                 ;  call divide subroutine, SP=0x8F9, Stack=[0x0102,0x010B,0x010F], PC=0x012C
            RET                             ;  return from test call, SP=0x08F9, Stack=[0x0102,0x010B,0x010F], PC=0x012D
divide:     LDS      r0     ,  count        ;  Load count (0x0) into r0
divide1:    INC      r0                     ;  Increment loop counter
            SUB      r30    ,  r31          ;  Subtract divisor from dividend
            BRPL     divide1                ;  Repeat loop if divisor>dividend after subtraction (if it is not, N flag is set and does not branch)
            DEC      r0                     ;  Decrement loop counter, becuase loop counter is incremented prior to checking if subtraction resulted in a positive number
            ADD      r30    ,  r31          ;  Add dividend to what remains of the divisor.  What remains of the divisor is gaurenteed to be negative.  This calculates the remainder
            STS      quotient,  r0          ;  store quotient at pre-defined quotient return address
            STS      remainder,  r30        ;  store quotient at pre-defined remainder return address
divide2:    RET                             ;  SP=0x08F7, Stack=[0x0102,0x010B,0x010F,0x012D], PC=0x0139
int0h:      JMP      int0h                  ;  interrupt 0 handler goes here

