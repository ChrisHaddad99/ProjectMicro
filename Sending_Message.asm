
#include <p18f2520.inc>

    string_chars_count equ 0x00
    
    
    org 0x08
	bra high_priority_interrupt
    
high_priority_interrupt
	incf string_chars_count
	
	retfie
    
    
    
org 0x00

    init
    
    
    
    loop
    
    bra loop
    
    
    configure_uart_port
	movlw 0x06 ;0000 0110
	movwf TXSTA
	movlw 0x90  ;1001 0000
	movwf RCSTA
    return
    
    enable_interrupts
	bsf INTCON,GIE
	bsf INTCON,PEIE
	bsf PIE1,RCIE
    return
    
    
    end
