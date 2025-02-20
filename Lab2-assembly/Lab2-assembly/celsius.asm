;  
;  lab2p2.asm
;  CelsiustoFahrenheitLook-UpTable
;  Created:   10:17:31 AM
;  Author:   Eugene Rockey / Joe Maloney
            .DSEG    
            .ORG     0x100  
output:     .BYTE    1                      ;  Assign SRAM address 0x0100 to label output
            .CSEG    
            .ORG     0x0    
            JMP      main                   ;  partial vector table at address 0x0
            .ORG     0x100                  ;  MAIN entry point at address 0x200 (step through the code)
main:       LDI      ZL     ,  low(2*table) ;  load the low byte of the 2-byte table address into ZL
            LDI      ZH     ,  high(2*table) ;  load the high byte of the 2-byte table address into ZL
            LDI      r16    ,  Celsius      ;  load the value to be converted into r16
            ADD      ZL     ,  r16          ;  add the value to be converted to the z pointer low byte
            LDI      r16    ,  0            ;  load zero into r16
            ADC      ZH     ,  r16          ;  add the carry from the first addition to the high byte of the Z pointer
            LPM                             ;  lpm = lpm r0,Z in reality, what does this mean? - Load the address in program memory at Z into r0
            STS      output ,  r0           ;  store look-up result to SRAM
            RET                             ;  consider MAIN as a subroutine to return from - but back to where?? - returns to line after hypothetical call instruction to main
;  Fahrenheit look-up table
table:      .DB      32     ,  34     ,  36     ,  37     ,  39     ,  41     ,  43     ,  45     ,  46     ,  48     ,  50     ,  52     ,  54     ,  55     ,  57     ,  59     ,  61     ,  63     ,  64     ,  66     
            .EQU     celsius=7              ;  modify Celsius from 0 to 19 degrees for different results
            .EXIT    
