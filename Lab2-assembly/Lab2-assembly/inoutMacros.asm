;  
;  Lab2-assembly.asm
;  
;  Created: 2/14/2025 12:01:11 AM
;  Author : malon
;  

;  Replace with your application code
.macro inMap ; subtracts 0x20 offset for use with in/out instructions
.if @0<0x20
.error "constant addr too low for inMap"
.else
.if @0>0x5F
.error "constant addr too high for inMap"
.else
in (@0-0x20),@1
.endif
.endif
.endmacro
.macro outMap ; subtracts 0x20 offset for use with in/out instructions
.if @0<0x20
.error "constant addr too low for outMap"
.else
.if @0>0x5F
.error "constant addr too high for outmap"
.else
out (@0-0x20),@1
.endif
.endif
.endmacro
            .CSEG    
			.org 0x0
USART_Init:
;  Set baud rate to UBRR0
            LDI      r16    ,  0x0    
            outMap      UBRR0H ,  r16    
            LDI      r16    ,  49           ;  49 for 20K baud
            OUT      UBRR0L ,  r16    
;  Enable receiver and transmitter
            LDI      r16    ,  (1<<RXEN0)|(1<<TXEN0)
            OUT      UCSR0B ,  r16    
;  Set frame format: 8data, 1stop bit
            LDI      r16    ,  (0<<USBS0)|(3<<UCSZ00)
            OUT      UCSR0C ,  r16    
            RET      
start:      LDI      r16    ,  0x01   
            RCALL    USART_Transmit
            RJMP     start  
;  Wait for empty transmit buffer
USART_Transmit:
            IN       r17    ,  UCSR0A       ;  read uart status reg
            SBRS     r17    ,  UDRE0         ;  infinite loop untill I/0 is empty, checks if data empty bit is set in uart status reg
            RJMP     USART_Transmit
;  Put data (r16) into buffer, sends the data
            OUT      UDR0   ,  r16    
            RET      

