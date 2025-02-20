
            .MACRO   ZEROALL                ;  zeros SRAM and registers so that inspecting them is easy, and for repeatability
            CLR      r0                     ;  Clear register r0
            CLR      r1                     ;  Clear register r1
            CLR      r2                     ;  Clear register r2
            CLR      r3                     ;  Clear register r3
            CLR      r4                     ;  Clear register r4
            CLR      r5                     ;  Clear register r5
            CLR      r6                     ;  Clear register r6
            CLR      r7                     ;  Clear register r7
            CLR      r8                     ;  Clear register r8
            CLR      r9                     ;  Clear register r9
            CLR      r10                    ;  Clear register r10
            CLR      r11                    ;  Clear register r11
            CLR      r12                    ;  Clear register r12
            CLR      r13                    ;  Clear register r13
            CLR      r14                    ;  Clear register r14
            CLR      r15                    ;  Clear register r15
            CLR      r16                    ;  Clear register r16
            CLR      r17                    ;  Clear register r17
            CLR      r18                    ;  Clear register r18
            CLR      r19                    ;  Clear register r19
            CLR      r20                    ;  Clear register r20
            CLR      r21                    ;  Clear register r21
            CLR      r22                    ;  Clear register r22
            CLR      r23                    ;  Clear register r23
            CLR      r24                    ;  Clear register r24
            CLR      r25                    ;  Clear register r25
            CLR      r26                    ;  Clear register r26
            CLR      r27                    ;  Clear register r27
            CLR      r28                    ;  Clear register r28
            CLR      r29                    ;  Clear register r29
            CLR      r30                    ;  Clear register r30
            CLR      r31                    ;  Clear register r31
            RCALL    zeroSRAM               ;  zero the first 0x500 bytes in sram so the memory view looks nice
            .ENDMACRO                       ;  end of macro definition
            .MACRO   U16_CP                 ;  args - rdH,rdL,rrH,rrL compares rdH:rdL to rrH:rdL
            CP       @1     ,  @3           ;  compare low byte
            CPC      @0     ,  @2           ;  compare high byte w/ carry bit from low byte
            .ENDMACRO                       ;  end the macro definition
            .MACRO   U16_ADD                ;  args rdH,rdL,rrH,rrL adds rdH:rdL to rrH:rrL and stores in rdH:rdL
            ADD      @1     ,  @3           ;  add the low bytes
            ADC      @0     ,  @2           ;  add the high bytes w/ carry bit from low bytes
            .ENDMACRO                       ;  end the macro definition
            .MACRO   U16_SUB                ;  args rdH,rdL,rrH,rrL subtracts rrH:rrL from rdH:rdL and stores in rdH:rdL
            SUB      @1     ,  @3           ;  subtract the low bytes
            SBC      @0     ,  @2           ;  subtract the high bytes w/ carry bit from low bytes
            .ENDMACRO                       ;  end the macro definition
            .MACRO   U16_PUSH               ;  args - rrH,rrL pushes uint onto stack
            PUSH     @0                     ;  push high byte onto stack
            PUSH     @1                     ;  push low byte onto stack
            .ENDMACRO                       ;  end the macro definition
            .MACRO   U16_POP                ;  args - rrH,rrL pops uint from the stack
            POP      @1                     ;  pop low byte
            POP      @0                     ;  pop high byte
            .ENDMACRO                       ;  end the macro definition
            .LISTMAC                        ;  expand macros in the listing file
            ;
            ;
            ;
            ;
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

;
;
;
;
; Sorting Source code, table
            .CSEG                           ;  start writing in code segment
            .ORG     0x0                    ;  code segment start address
            ZEROALL                         ;  zero everything for repeatability and readability of memory/processor view
sort:       RCALL    getDataDebug           ;  Load constant dataset from flash into sram
;  data for sorting is stored in sram
;  0x101:0x100 - size of the array (n), e.g. if this equals 2, there are 2 2-byte elements in the array
;  0x102 and upwards - the data in the array.  Stored as uint16, with low byte at low address.
;  example:
;  address :   value
;  0x100   :   0x02
;  0x101   :   0x00 - n = 0x0002, 2 elements in array
;  0x102   :   0x01
;  0x103   :   0x00 - arr[0] = 0x0001
;  0x104   :   0xFF
;  0x105   :   0x01 - arr[1] = 0x01FF
            LDI      XH     ,  0x1          ;  set high byte
            LDI      XL     ,  0x0          ;  set X to sram start
            LD       r2     ,  X+           ;  load n low byte
            LD       r3     ,  X+           ;  load n high byte, set X to low byte of first data element
;  quicksort call argument 1: r3:r2 - uint16, this is the number of 2-byte elements in array
;  quicksort call argument 2: X - points to low byte of first element in array
            RCALL    quickSort              ;  sort dataset in place
end:        JMP      end                    ;  end  of program

quickSort:  LDI      r16    ,  0x1          ;  set low byte
            CLR      r17                    ;  use r17:r16 for a constant uint 0x0001
            U16_CP   r17    ,  r16    ,  r3     ,  r2      ;  base case - break if length is 1 or 0
            BRGE     qSortR                 ;  return if array size is 1 or 0 elements

            RCALL    part                   ;  after partitioning, the ending address of the pivot is stored in the Y pointer
            U16_PUSH YH     ,  YL           ;  store pivot location on stack
            U16_SUB  YH     ,  YL     ,  XH     ,  XL      ;  calculate lower array size in bytes
            LSR      YH                     ;  This number is guaranteed to be even
            ROR      YL                     ;  divide by 2 to get number of elements, ror is lsr w/ carry bit
            U16_SUB  r3     ,  r2     ,  YH     ,  YL      ;  calculate number of elements in upper half, including pivot
            U16_SUB  r3     ,  r2     ,  r17    ,  r16     ;  r3:r2=(r3:r2)-1, get rid of the pivot
            U16_PUSH r3     ,  r2           ;  store upper array size on stack
            MOV      r3     ,  YH           ;  set high byte
            MOV      r2     ,  YL           ;  move array length into r3:r2 for next call to quicksort
            RCALL    quickSort              ;  lower half, X is equivalent for this call, r3:r2 holds new length
            U16_POP  r3     ,  r2           ;  move upper array length into r3:r2 for next call to quicksort
            U16_POP  XH     ,  XL           ;  restore X pointer to previous pivot
            U16_ADD  XH     ,  XL     ,  r17    ,  r16     ;  do this twice because uint16 is 2 bytes large
            U16_ADD  XH     ,  XL     ,  r17    ,  r16     ;  move X to element after previous pivot (lower byte of first element in upper half array)
            RCALL    quickSort              ;  Upper half, X is at the element after previous pivot, r3:r2 holds upper half length

qSortR:     RET      

;  Array start address is X (array start and pivot are the same element), array length stored at r3:r2
part:       MOV      r0     ,  XL           ;  set low byte
            MOV      r1     ,  XH           ;  write down pivot address in r1:r0
            MOV      YL     ,  XL           ;  set low byte
            MOV      YH     ,  XH           ;  set y pointer to first (non-pivot) value in array
            LD       r4     ,  X+           ;  read low byte
            LD       r5     ,  X+           ;  load the pivot into r5:r4, X now points to second element in array
            CLR      r17                    ;  set high byte to 0x0
            LDI      r16    ,  0x1          ;  use r17:r16 to increment loop counter
            CLR      r7                     ;  set high byte to 0x0
            MOV      r6     ,  r16          ;  use r7:r6 for loop counter, start at 1
partL1:     U16_CP   r7     ,  r6     ,  r3     ,  r2      ;  stop loop when counter == r3:r2 (array length)
            BREQ     partR                  ;  return if loop counter is equal to array length
            LD       r12    ,  X+           ;  read low byte
            LD       r13    ,  X+           ;  load the current value into r13:r12
            U16_CP   r13    ,  r12    ,  r5     ,  r4      ;  compare value to pivot
            BRLO     partL2                 ;  swap values if value<pivot
            JMP      partL3                 ;  don't swap if value>pivot
partL2:     RCALL    qSwap                  ;  swap the pivot and value if value is less than pivot
partL3:     U16_ADD  r7     ,  r6     ,  r17    ,  r16     ;  increment loop counter
            JMP      partL1                 ;  repeat loop after incrementing counter
partR:      RCALL    qSwapPivot             ;  swap *Y and pivot
            RET                             ;  return from partitioning

qSwapPivot: LD       r14    ,  Y+           ;  set low byte
            LD       r15    ,  Y+           ;  store value to be swapped in r15:r14
            U16_SUB  YH     ,  YL     ,  r17    ,  r16     ;  do this twice because uint16 is 2 bytes large
            U16_SUB  YH     ,  YL     ,  r17    ,  r16     ;  send Y pointer back to address of value to be swapped
            MOV      XL     ,  r0           ;  set low byte
            MOV      XH     ,  r1           ;  restore X to pivot location
            ST       X+     ,  r14          ;  set low byte
            ST       X+     ,  r15          ;  store *Y at original pivot location
            ST       Y+     ,  r4           ;  set low byte
            ST       Y+     ,  r5           ;  store pivot at address of Y
            U16_SUB  YH     ,  YL     ,  r17    ,  r16     ;  do this twice because uint16 is 2 bytes large
            U16_SUB  YH     ,  YL     ,  r17    ,  r16     ;  send Y pointer back to address of value to be swapped
            U16_SUB  XH     ,  XL     ,  r17    ,  r16     ;  do this twice because uint16 is 2 bytes large
            U16_SUB  XH     ,  XL     ,  r17    ,  r16     ;  send X pointer back to original array start addr, used for calculating upper/lower half length in qsort
            RET                             ;  return from swapping pivot with location of final value swapped into the lower half

;  swaps values at (Y+1) and X, does not change X, Y=(Y+1)
qSwap:      LD       r15    ,  -X           ;  do this twice because uint16 is 2 bytes large
            LD       r15    ,  -X           ;  retract X back to the address of the value to be swapped
            U16_ADD  YH     ,  YL     ,  r17    ,  r16     ;  do this twice because uint16 is 2 bytes large
            U16_ADD  YH     ,  YL     ,  r17    ,  r16     ;  increment Y pointer
            LD       r14    ,  Y+           ;  read low byte
            LD       r15    ,  Y+           ;  load value to be swapped from Y pointer into r15:r14
            U16_SUB  YH     ,  YL     ,  r17    ,  r16     ;  do this twice because uint16 is 2 bytes large
            U16_SUB  YH     ,  YL     ,  r17    ,  r16     ;  send Y pointer back to address of value to be swapped
            LD       r18    ,  X+           ;  load low byte
            LD       r19    ,  X+           ;  load other value to be swapped into r19:r18
            U16_SUB  XH     ,  XL     ,  r17    ,  r16     ;  do this twice because uint16 is 2 bytes large
            U16_SUB  XH     ,  XL     ,  r17    ,  r16     ;  decrement X pointer to original location
            ST       X+     ,  r14          ;  store low byte
            ST       X+     ,  r15          ;  store the *(Y+1) value at the original location of X
            ST       Y+     ,  r18          ;  store low byte
            ST       Y+     ,  r19          ;  store the *X value at (Y+1)
            U16_SUB  YH     ,  YL     ,  r17    ,  r16     ;  do this twice because uint16 is 2 bytes large
            U16_SUB  YH     ,  YL     ,  r17    ,  r16     ;  Y now addresses (Y+1) from the original Y
            RET                             ;  return from swapping values
;  table - a 20 value table
table:      .DB      0x14   ,  0x0    ,  0x5e   ,  0x3e   ,  0x81   ,  0x9d   ,  0x2f   ,  0xff   ,  0x03   ,  0x6a   ,  0x07   ,  0x30   ,  0xda   ,  0x71   ,  0xd4   ,  0xb0   ,  0xec   ,  0x92   ,  0xad   ,  0xd1   ,  0xe7   ,  0xf8   ,  0x3e   ,  0xf1   ,  0x39   ,  0x64   ,  0x55   ,  0xdd   ,  0x4f   ,  0xe0   ,  0x20   ,  0x06   ,  0x55   ,  0x02   ,  0x4d   ,  0xaf   ,  0x63   ,  0x80   ,  0x6b   ,  0x33   ,  0x22   ,  0xbd   
;  table20 - a 20 byte (10 value) table
table20:    .DB      0x0a   ,  0x0    ,  0xa2   ,  0x35   ,  0xfa   ,  0x94   ,  0x5c   ,  0xbe   ,  0x29   ,  0xb0   ,  0x3d   ,  0xe4   ,  0x62   ,  0x32   ,  0x9a   ,  0xb8   ,  0x9a   ,  0xfb   ,  0x87   ,  0x86   ,  0x91   ,  0x96   
getDataDebug:LDI      XL     ,  0x0         ;  same as getData, but reads from program flash instead of receiving data via uart
            LDI      XH     ,  0x1          ;  set X to start of sram
            LDI      ZL     ,  low(table*2) ;  set low byte
            LDI      ZH     ,  high(table*2) ;  set Z to starting address of table
            RCALL    getuint16Debug         ;  get the number of uint data elements in table (n)
            LDS      r0     ,  0x100        ;  load low byte
            LDS      r1     ,  0x101        ;  load n into r0,r1.
            CLR      YL                     ;  clear low byte
            CLR      YH                     ;  use Y for accumulator, and r1:r0 for compare
debugL1:    U16_CP   r1     ,  r0     ,  YH     ,  YL      ;  compare loop counter to array size
            BREQ     getDataDebugR          ;  stop loading when all values are loaded into sram
            RCALL    getuint16Debug         ;  get the next dataset number
            ADIW     YL     ,  1            ;  increment loop counter
            JMP      debugL1                ;  repeat loop
getDataDebugR:RET                           ;  return from loading values into sram

getuint16Debug:LPM      r16    ,  Z+        ;  same as getuint16, but loads uint16 from program memory for debugging
            ST       X+     ,  r16          ;  store n low byte
            LPM      r16    ,  Z+           ;  load high byte
            ST       X+     ,  r16          ;  store n high byte
            RET                             ;  return after getting both bytes of the uint16
zeroSRAM:   LDI      r16    ,  0x0          ;  zero the first 0x500 values in sram so the sorted values are easy to see in the memory viewer
            LDI      YH     ,  0x5          ;  set high byte
            LDI      YL     ,  0x1          ;  use Y for loop stop condition
            LDI      XL     ,  0x0    
            LDI      XH     ,  0x1          ;  set X to start of sram

zeroSRAML1: U16_CP   XH     ,  XL     ,  YH     ,  YL      ;  stop loop at X=Y=0x300
            BREQ     zeroSRAMR              ;  return from zeroing
            ST       X+     ,  r16          ;  zero the current byte
            JMP      zeroSRAML1             ;  repeat loop
zeroSRAMR:  RET                             ;  return from zeroing sram

