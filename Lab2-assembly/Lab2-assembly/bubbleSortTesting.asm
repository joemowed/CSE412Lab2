;  
;  Lab2-assembly.asm
;  
;  Created: 2/14/2025 12:01:11 AM
;  Author : malon
;  

            .MACRO    U16_CP                ;  args - rdH,rdL,rrH,rrL compares rdH:rdL to rrH:rdL
            CP        @1    ,  @3     
            CPC       @0    ,  @2     
            .ENDMACRO
            .MACRO    U16_ADD               ;  args rdH,rdL,rrH,rrL adds rdH:rdL to rrH:rrL and stores in rdH:rdL
            ADD       @1    ,  @3     
            ADC       @0    ,  @2     
            .ENDMACRO
            .MACRO    U16_SUB               ;  args rdH,rdL,rrH,rrL subtracts rrH:rrL from rdH:rdL and stores in rdH:rdL
            SUB       @1    ,  @3     
            SBC       @0    ,  @2     
            .ENDMACRO
;  Replace with your application code
            .LISTMAC 
            .EQU      CHAR_MAX=0xFF
            .CSEG    
            .ORG      0x0   
            CLR       r0    
            CLR       r1    
            CLR       r2    
            CLR       r3    
            CLR       r4    
            CLR       r5    
            CLR       r6    
            CLR       r7    
            CLR       r8    
            CLR       r9    
            CLR       r10   
            CLR       r11   
            CLR       r12   
            CLR       r13   
            CLR       r14   
            CLR       r15   
            CLR       r16   
            CLR       r17   
            CLR       r18   
            CLR       r19   
            CLR       r20   
            CLR       r21   
            CLR       r22   
            CLR       r23   
            CLR       r24   
            CLR       r25   
            CLR       r26   
            CLR       r27   
            CLR       r28   
            CLR       r29   
            CLR       r30   
            CLR       r31   

USART_Init:
;  Set baud rate to UBRR0
            LDI       r16   ,  0x0    
            STS       UBRR0H,  r16    
            LDI       r16   ,  103          ;  49 for 20K baud, 103 for 9600, 12 for 76800
            STS       UBRR0L,  r16    
;  Enable receiver and transmitter
            LDI       r16   ,  (1<<RXEN0)|(1<<TXEN0)
            STS       UCSR0B,  r16    
;  Set frame format: 8data, 1stop bit
            LDI       r16   ,  (0<<USBS0)|(3<<UCSZ00)
            STS       UCSR0C,  r16    

start:      RCALL     next                  ;  reserve first 2 bytes on stack for storing the test count
next:       RCALL     getTestCount
            RCALL     bSortTestLoop
end:        JMP       end   

getTestCount:LDI       XL    ,  0xFE   
            LDI       XH    ,  0x08         ;  set X to last SRAM location
            RCALL     uint16_Rx             ;  get and store test count in last SRAM location
            RET      

bSortTestLoop:LDI       XL    ,  0xFE   
            LDI       XH    ,  0x08   
            CLR       r17   
            LDI       r16   ,  0x1          ;  use r17:r16 to increment loop counter
            LD        r8    ,  X+     
            LD        r9    ,  X            ;  load test count into r9:r8, use for loop stop condition
            CLR       r10   
            CLR       r11                   ;  use r11:r10 for loop counter
bSortTestL1:U16_CP    r11   ,  r10    ,  r9     ,  r8     
            BREQ      bSortTestR
            RCALL     bSortTest
            CLR       r17   
            LDI       r16   ,  0x1          ;  use r17:r16 to increment loop counter
            U16_ADD   r11   ,  r10    ,  r17    ,  r16     ;  increment loop counter
            JMP       bSortTestL1
bSortTestR: RET      

;  uses X and Y for indirection to data, Z for accumulator
bSortTest:  RCALL     getData
            RCALL     bubbleSort
            RCALL     testComplete
            RET      

bubbleSort: LDI       XL    ,  0x0          ;  set X to location of n
            LDI       XH    ,  0x1    
            LDI       YL    ,  0x4    
            LDI       YH    ,  0x1          ;  set Y to second data location
            CLR       ZL    
            CLR       ZH                    ;  set Z to 0
            LD        r0    ,  X+     
            LD        r1    ,  X+           ;  store the number of numbers (n) in r1:r0,X now points at low byte of first uint16
            MOV       r18   ,  r0     
            MOV       r19   ,  r1           ;  use r19:r18 for outer loop end condition check
            LD        r2    ,  -X     
            LD        r2    ,  -X           ;  decrement X to addr of last data uint low byte
            U16_ADD   XH    ,  XL     ,  r1     ,  r0      ;  add n to X address, doing this twice because uint16 is 2 bytes large
            U16_ADD   XH    ,  XL     ,  r1     ,  r0      ;  add n to X address, this makes X point to the low byte of 1 of the last uint16
            MOV       r0    ,  XL     
            MOV       r1    ,  XH           ;  load the end of data address into r1:r0, this is stop condition for the loops
            LDI       XL    ,  0x2    
            LDI       XH    ,  0x1          ;  X points to first data uint16 low byte
            CLR       r2    
            CLR       r3    
            CLR       r4    
            CLR       r5    
            CLR       r17   
            LDI       r16   ,  0x1          ;  use r17:r16 to decrement the loop stop condition
            U16_SUB   r19   ,  r18    ,  r17    ,  r16     ;  outer loop runs (n-1) times
            CLR       r6    
            CLR       r7                    ;  use r7:r6 for outer loop iterator
bubbleL1:   U16_CP    r7    ,  r6     ,  r19    ,  r18     ;  outer loop r7:r6 is iterator, starts at 0, r19:r18 is stop condition, breaks at i = (n-1)
            BREQ      bubbleR               ;  stop sorting
bubbleL2:   U16_CP    r1    ,  r0     ,  XH     ,  XL     
            BREQ      bubbleL2end

            MOV       ZL    ,  XL     
            MOV       ZH    ,  XH           ;  Z reg used for swap, needs to point to orignial location of first uint low byte
            LD        r2    ,  X+     
            LD        r3    ,  X+           ;  Load first uint16 into r3:r2
            LD        r4    ,  Y+     
            LD        r5    ,  Y+           ;  Load second uint16 into r5:r4
            U16_CP    r3    ,  r2     ,  r5     ,  r4      ;  compare the numbers
            BRSH      callSwap              ;  swap if *X >= *Y, brsh is breq for unsigned numbers
            JMP       bubbleL2
callSwap:   RCALL     bubbleSwap            ;  swap the numbers if number at X >= number at Y
            JMP       bubbleL2
bubbleL2end:LDI       XL    ,  0x2    
            LDI       XH    ,  0x1          ;  reset the X pointer to first uint low byte
            LDI       YH    ,  0x1    
            LDI       YL    ,  0x4          ;  reset the Y pointer to first uint low byte
            U16_ADD   r7    ,  r6     ,  r17    ,  r16     ;  increment loop counter
            U16_SUB   r1    ,  r0     ,  r17    ,  r16    
            U16_SUB   r1    ,  r0     ,  r17    ,  r16     ;  decrement the inner loop stop condition address by 2 bytes, skip the last element that was sorted in the next iteration
            JMP       bubbleL1
bubbleR:    RET      

;  working regs r21:r20, swaps uint16, assumes *Z is low byte of first uint,r3:r2 is first uint,r5:r4 is second uint
bubbleSwap: MOV       r20   ,  r2     
            MOV       r21   ,  r3           ;  store first uint in r17:r16
            MOV       r3    ,  r5     
            MOV       r2    ,  r4           ;  write second uint into first uint's registers
            ST        Z+    ,  r2     
            ST        Z+    ,  r3           ;  write second uint into first's sram location
            ST        Z+    ,  r20    
            ST        Z+    ,  r21          ;  write first uint into second's sram location
            RET      

getData:    LDI       r26   ,  0x00         ;  set X to start of sram
            LDI       r27   ,  0x1    
            RCALL     uint16_Rx             ;  get first uint16 at 0x100, this is the number of numbers (n) in the dataset
            LDS       r0    ,  0x100  
            LDS       r1    ,  0x101        ;  load n into r0,r1.
            CLR       ZL    
            CLR       ZH                    ;  use Z for accumulator, and r1:r0 for compare
getDataL1:  U16_CP    r1    ,  r0     ,  ZH     ,  ZL     
            BREQ      getDataR
            RCALL     uint16_Rx             ;  get the next dataset number
            ADIW      ZL    ,  1      
            JMP       getDataL1
getDataR:   RET      

uint16_Rx:  RCALL     USART_Rx
            ST        X+    ,  r17    
            RCALL     USART_Rx
            ST        X+    ,  r17    
            RET      

uint16_Tx:  LD        r16   ,  X+     
            RCALL     USART_Tx
            LD        r16   ,  X+     
            RCALL     USART_Tx
            RET      
testComplete:LDI       r16   ,  0xFF   
            RCALL     USART_Tx
            RET      
receiveReady:LDI       r16   ,  0xF0        ;  sends a 0xF0 to the testing PC to ack that mcu ready for next uint16
            RCALL     USART_Tx
            RET      

;  Wait for empty transmit buffer
USART_Tx:   LDS       r17   ,  UCSR0A       ;  working: r17, sends byte in r16 , read uart status reg
            SBRS      r17   ,  UDRE0        ;  infinite loop untill I/0 is empty, checks if data empty bit is set in uart status reg
            RJMP      USART_Tx
;  Put data (r16) into buffer, sends the data
            STS       UDR0  ,  r16    
            RET      

USART_Rx:   RCALL     receiveReady
            LDS       r17   ,  UCSR0A       ;  reads uart into r17
            SBRS      r17   ,  RXC0   
            RJMP      USART_Rx
            LDS       r17   ,  UDR0   
            RET      
table:      .DB       0x64  ,  0x0    ,  0x6f   ,  0x18   ,  0x36   ,  0xc6   ,  0x7f   ,  0xa7   ,  0xf6   ,  0x8d   ,  0x0c   ,  0xb7   ,  0xb9   ,  0x70   ,  0xeb   ,  0x75   ,  0x82   ,  0x34   ,  0x2d   ,  0xaf   ,  0x43   ,  0xe6   ,  0x86   ,  0x1c   ,  0xb2   ,  0xcc   ,  0xdf   ,  0x93   ,  0x14   ,  0x19   ,  0xfb   ,  0xf2   ,  0x27   ,  0xc8   ,  0xa2   ,  0xb7   ,  0x80   ,  0xae   ,  0x07   ,  0xd9   ,  0xb7   ,  0xbb   ,  0x6d   ,  0x62   ,  0x3b   ,  0xfc   ,  0x07   ,  0x0d   ,  0xc3   ,  0x33   ,  0xc6   ,  0x22   ,  0x34   ,  0x5d   ,  0x19   ,  0x72   ,  0x8f   ,  0xc8   ,  0xdd   ,  0x16   ,  0xb7   ,  0x90   ,  0x93   ,  0xc1   ,  0x53   ,  0xeb   ,  0xb3   ,  0x5d   ,  0xee   ,  0x23   ,  0x91   ,  0xbf   ,  0xaa   ,  0x73   ,  0x4d   ,  0x8f   ,  0x7a   ,  0x49   ,  0x8d   ,  0x73   ,  0xf7   ,  0x84   ,  0xcd   ,  0xc7   ,  0xa9   ,  0xe7   ,  0x6a   ,  0xba   ,  0x2c   ,  0xf6   ,  0x56   ,  0x5f   ,  0xfb   ,  0x7b   ,  0x5e   ,  0x16   ,  0xdd   ,  0x78   ,  0xbd   ,  0xe5   ,  0xea   ,  0xab   ,  0x58   ,  0xbc   ,  0x2d   ,  0x0f   ,  0xf0   ,  0x07   ,  0x0e   ,  0x59   ,  0x93   ,  0x87   ,  0x12   ,  0x7a   ,  0x12   ,  0xf1   ,  0xd8   ,  0x90   ,  0x3d   ,  0x94   ,  0x0a   ,  0xaf   ,  0x99   ,  0xd4   ,  0x0f   ,  0x74   ,  0x45   ,  0x31   ,  0x55   ,  0x6c   ,  0x3c   ,  0xb0   ,  0xf2   ,  0xde   ,  0xe3   ,  0xcb   ,  0x32   ,  0xed   ,  0xa4   ,  0xa7   ,  0xaa   ,  0x82   ,  0x0b   ,  0xc3   ,  0x6b   ,  0xdc   ,  0x50   ,  0x21   ,  0xd6   ,  0x90   ,  0x75   ,  0x8f   ,  0x76   ,  0xc2   ,  0xdc   ,  0x32   ,  0xf1   ,  0x19   ,  0x78   ,  0xa5   ,  0xc2   ,  0xd5   ,  0x03   ,  0x93   ,  0x96   ,  0xb3   ,  0x98   ,  0x10   ,  0xe1   ,  0x61   ,  0xc7   ,  0x45   ,  0xa2   ,  0x11   ,  0xe9   ,  0x41   ,  0x7d   ,  0x61   ,  0x64   ,  0x73   ,  0x63   ,  0x85   ,  0x23   ,  0x16   ,  0xcb   ,  0x99   ,  0x76   ,  0x09   ,  0xab   ,  0xb9   ,  0x20   ,  0x84   ,  0xee   ,  0x7f   ,  0x43   ,  0xb3   ,  0xfc   ,  0xa4   ,  0x08   ,  0x84   ,  0x64   ,  0xf4   
getDataDebug:LDI       XL    ,  0x0    
            LDI       XH    ,  0x1    
            LDI       ZL    ,  low(table*2)
            LDI       ZH    ,  high(table*2) ;  set Z to starting address of table
            RCALL     getuint16Debug        ;  get the number of uint data elements in table (n)
            LDS       r0    ,  0x100  
            LDS       r1    ,  0x101        ;  load n into r0,r1.
            CLR       YL    
            CLR       YH                    ;  use Y for accumulator, and r1:r0 for compare
debugL1:    U16_CP    r1    ,  r0     ,  YH     ,  YL     
            BREQ      getDataDebugR
            RCALL     getuint16Debug        ;  get the next dataset number
            ADIW      YL    ,  1      
            JMP       debugL1
getDataDebugR:RET      

getuint16Debug:LPM       r16   ,  Z+     
            ST        X+    ,  r16          ;  store n low byte
            LPM       r16   ,  Z+     
            ST        X+    ,  r16          ;  store n high byte
            RET      

