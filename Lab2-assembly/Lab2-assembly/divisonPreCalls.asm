;  Division Source Code
;  
;  Created: 2/14/2025 12:01:11 AM
;  Author : Joe Maloney / Eugene Rockey
;  
;  Declare Variables
;  ******************************
            .DSEG    
            .ORG     0x100                  ;  originate data storage at address 0x100
quotient:   .BYTE    1                      ;  uninitialized quotient variable stored in SRAM aka data segment
remainder:  .BYTE    1                      ;  uninitialized remainder variable stored in SRAM
            .SET     count=0                ;  initialized count variable stored in SRAM
;  ******************************
            .CSEG                           ;  Declare and Initialize Constants (modify them for different results)
            .EQU     dividend=20            ;  8-bit dividend constant (positive integer) stored in FLASH memory aka code segment
            .EQU     divisor=5              ;  8-bit divisor constant (positive integer) stored in FLASH memory
;  ******************************
;  * Vector Table (partial)
;  ******************************
            .ORG     0x0    
reset:      JMP      main                   ;  RESET Vector at address 0x0 in FLASH memory (handled by MAIN)
int0v:      JMP      int0h                  ;  External interrupt vector at address 0x2 in Flash memory (handled by int0)
;  ******************************
;  * MAIN entry point to program*
;  ******************************
            .ORG     0x100                  ;  originate MAIN at address 0x100 in FLASH memory (step through the code)
main:       CALL     init                   ;  initialize variables subroutine, set break point here, Stack contains address of below call (0x0102),SP=0x08FD (first empty byte on stack),PC=0x0100 (current  instruction)
            CALL     getnums                ;  PC=0x0102, SP=0x08FF, Stack unmodified from above call.  After this instruction, SP=(SP-2), Stack = 0x0104, PC=0x0111
            CALL     test                   ;  PC=0x0104, SP=0x08FF, Stack unmodified from above call.  After this instruction, SP=(SP-2), Stack = 0x0106, PC=0x114
            CALL     divide                 ;  PC=0x0106, SP=0x08FF, Stack unmodified from above call.  After this instruction, SP=(SP-2), Stack= 0x0108, PC=0x0131
endmain:    JMP      endmain
init:       LDS      r0     ,  count        ;  get initial count, Stack = 0x0102,SP=0x08FD,PC=0x010A
            STS      quotient,  r0          ;  use the same r0 value to clear the quotient-
            STS      remainder,  r0         ;  and the remainder storage locations
            RET                             ;  return from subroutine, Stack and SP unmodified from calling this function, PC=0x0100, after this instruction SP=0x08FF,PC=0x0102 (popped from stack), Stack remains the same
getnums:    LDI      r30    ,  dividend     ;  SP=0x08FD,PC=0x0111,Stack = 0x0104
            LDI      r31    ,  divisor
            RET                             ;  Stack and SP unmodified from start of function call. After this instruction, SP=0x08FF,PC=0x0104(popped from stack)
test:       CPI      r30    ,  0            ;  is dividend == 0 ?
            BRNE     test2  
test1:      JMP      test1                  ;  halt program, output = 0 quotient and 0 remainder
test2:      CPI      r31    ,  0            ;  is divisor == 0 ?
            BRNE     test4  
            LDI      r30    ,  0xEE         ;  set output to all EE's = Error division by 0
            STS      quotient,  r30    
            STS      remainder,  r30    
test3:      JMP      test3                  ;  halt program, look at output
test4:      CP       r30    ,  r31          ;  is dividend == divisor ?
            BRNE     test6  
            LDI      r30    ,  1            ;  then set output accordingly
            STS      quotient,  r30    
test5:      JMP      test5                  ;  halt program, look at output
test6:      BRPL     test8                  ;  is dividend < divisor ?
            SER      r30    
            STS      quotient,  r30    
            STS      remainder,  r30        ;  set output to all FF's = not solving Fractions in this program
test7:      JMP      test7                  ;  halt program look at output
test8:      RET                             ;  otherwise, return to do positive integer division
divide:     LDS      r0     ,  count        ;  Load count (0x0) into r0
divide1:    INC      r0                     ;  Increment loop counter
            SUB      r30    ,  r31          ;  Subtract divisor from dividend
            BRPL     divide1                ;  Repeat loop if divisor>dividend after subtraction (if it is not, N flag is set and does not branch)
            DEC      r0                     ;  Decrement loop counter, becuase loop counter is incremented prior to checking if subtraction resulted in a positive number
            ADD      r30    ,  r31          ;  Add dividend to what remains of the divisor.  What remains of the divisor is gaurenteed to be negative.  This calculates the remainder
            STS      quotient,  r0          ;  store quotient at pre-defined quotient return address
            STS      remainder,  r30        ;  store quotient at pre-defined remainder return address
divide2:    RET                             ;  end function call
int0h:      JMP      int0h                  ;  interrupt 0 handler goes here

