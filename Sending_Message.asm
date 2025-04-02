
#include <p18f2520.inc>

    tmp1 equ 0x00
    tmp2 equ 0x01
    string_chars_count equ 0x02
    string_array equ 0x03
    dict_chars_count equ 0x11
    dict_array equ 0x12
    dict_encoding_array equ 0x20
    
    
            
    
    
org 0x00
 bra init
 
 
 org 0x08
	bra high_priority_interrupt
    
high_priority_interrupt
    movlw 0x0D
    cpfseq RCREG
        bra string_reception_not_done
        bra string_reception_done
	
        string_reception_not_done
	        incf string_chars_count
            movff RCREG,POSTINC0
            retfie


        string_reception_done
            lfsr FSR0, string_array
            lfsr FSR1, dict_array
            clrf tmp1
            clrf tmp2

            create_dict

            string_array_loop
                movf string_chars_count,w
                cpfslt tmp1
                    bra encode_dict

                    dict_array_loop
                        movf dict_chars_count,w   
                        cpfslt tmp2
                            bra char_not_in_dict

                            search_in_dict
                                movf INDF0,w
                                cpfseq POSTINC1
                                    bra check_next_character_in_dict
                                    bra char_in_dict
                    
                char_not_in_dict
                    movff POSTINC0,INDF1
                    incf dict_chars_count
                    lfsr FSR1,dict_array
                    incf tmp1
                    bra string_array_loop

                check_next_character_in_dict
                    incf tmp2
                    bra dict_array_loop
                
                char_in_dict
                    lfsr FSR1,dict_array
                    incf tmp1
                    movf POSTINC0,w
                    bra string_array_loop
 
 
	encode_dict
	    clrf tmp1
	    lfsr FSR0,dict_encoding_array
	    
	    loop_through_dict_for_encoding
	    movf dict_chars_count,w
	    cpfslt tmp1
		bra send_dict_through_uart
		movff tmp1,POSTINC0
		incf tmp1
		bra loop_through_dict_for_encoding
		
	send_dict_through_uart
	    clrf tmp1
	    lfsr FSR0,dict_array
	    
	    loop_send_dict_through_uart
	    movf dict_chars_count,w
	    cpfslt tmp1
		bra send_encoded_string
		movf POSTINC0,w
		call UART_transmit_character
		bra loop_send_dict_through_uart
	    
		
	send_encoded_string
	    clrf tmp1
	    lfsr FSR0,string_array
	    lfsr FSR1,dict_array
	    loop_send_encoded_string
		movf dict_chars_count,w
		cpfslt tmp1
		;do not know how yet
		
		
    init
    clrf string_chars_count
    lfsr FSR0, string_array
    
    
    loop
    
    bra loop
    
    
    configure_uart_port
	movlw 0x06 ;0000 0110
	movwf TXSTA
    bcf BAUDCON,BRG16   ;9600 Baudrate
	movlw 0x90  ;1001 0000
	movwf RCSTA

    return
    
    enable_interrupts
	bsf INTCON,GIE
	bsf INTCON,PEIE
	bsf PIE1,RCIE
    return
    
    UART_transmit_character
	    movwf TXREG
	    waiting_on_transmission
		btfss TXSTA,TRMT
		bra waiting_on_transmission
	    movlw 0x20
	    movwf TXREG
    return
    
    
    end