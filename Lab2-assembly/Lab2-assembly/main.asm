;  
;  Lab2-assembly.asm
;  
;  Created: 2/14/2025 12:01:11 AM
;  Author : malon
;  

;  Replace with your application code
            .EQU     CHAR_MAX=0xFF
USART_Init:
;  Set baud rate to UBRR0
            LDI      r16    ,  0x0    
            STS      UBRR0H ,  r16    
            LDI      r16    ,  49           ;  49 for 20K baud
            STS      UBRR0L ,  r16    
;  Enable receiver and transmitter
            LDI      r16    ,  (1<<RXEN0)|(1<<TXEN0)
            STS      UCSR0B ,  r16    
;  Set frame format: 8data, 1stop bit
            LDI      r16    ,  (0<<USBS0)|(3<<UCSZ00)
            STS      UCSR0C ,  r16    
            LDI      r26    ,  0x00         ;  set X to start of sram
            LDI      r27    ,  0x1    
start:      RCALL    uint16_Rx
            MOV      r16    ,  r17    
            RJMP     start  
uint16_Rx:  RCALL    USART_Rx
            ST       X+     ,  r17    
            RCALL    USART_Rx
            ST       X+     ,  r17    
            RET      

;  Wait for empty transmit buffer
USART_Tx:   LDS      r17    ,  UCSR0A       ;  working: r17, sends byte in r16 , read uart status reg
            SBRS     r17    ,  UDRE0        ;  infinite loop untill I/0 is empty, checks if data empty bit is set in uart status reg
            RJMP     USART_Tx
;  Put data (r16) into buffer, sends the data
            STS      UDR0   ,  r16    
            RET      

;  Wait for data to be received
USART_Rx:   LDS      r17    ,  UCSR0A       ;  reads uart into r17
            SBRS     r17    ,  RXC0   
            RJMP     USART_Rx
            LDS      r17    ,  UDR0   
            RET      
;  Get and return received data from buffer
