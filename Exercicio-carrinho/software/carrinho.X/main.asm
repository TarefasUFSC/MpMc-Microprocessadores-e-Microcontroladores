;*******************************************************************************
;    UFSC- Universidade Federal de Santa Catarina
;    *Project Name:
;	      Carrinho
;    *Copyright:
;	      Rodrigo Ferraz Souza
;    *Test Configuration:
;	     MCU:              P16F877A
;	     Oscillator:       HS, 4.0 MHz
;	     Ext. Modules:     -
;    *NOTES:
;	
;*******************************************************************************

    
#include <P16F877A.INC> 	; Arquivo de include do uC usado, no caso PIC16F877A

; Palavra de configura??o, desabilita e habilita algumas op??es internas
__CONFIG  _CP_OFF & _CPD_OFF & _DEBUG_OFF & _LVP_OFF & _WRT_OFF & _BODEN_OFF & _PWRTE_OFF & _WDT_OFF & _XT_OSC

  
; Definição de variaveis
cblock 0x20
    ; variaveis pro delay
    tempo0		
    tempo1
    tempo2
    
    ; flags
    comecou
    carregando
endc
  
  
  
;************************ Vetor de Reset do uC ********************************
org 0x00			; Vetor de reset do uC.
goto inicio			; Desvia para o inicio do programa.

 
; Inicio do programa 
inicio:
    clrf	PORTB		; Inicializa o Port B com zero

    banksel	TRISB		; Seleciona banco de mem?ria 1
    movlw	0x0f
    movwf	TRISB		; configura metade como saida e metade como 
				; entradas

    movlw	0x00
    movwf	OPTION_REG	; Configura Op??es:
				; Pull-Up habilitados.
				; Interrup??o na borda de subida do sinal no pino B0.
				; Timer0 incrementado pelo oscilador interno.
				; Prescaler WDT 1:1.
				; Prescaler Timer0 1:2.x

    banksel PORTB		; Seleciona banco de mem?ria 1
    goto loop

    
; Rotinas
delay_segundo:
        movlw   .1	    ; vai carrega tempo2 com constante
        movwf   tempo2	    ; carrega tempo2
denovo2:
        movlw   .250	    ; vai carrega tempo1 com constante
        movwf   tempo1	    ; Carrega tempo1 
denovo:
        movlw   .250        ; vai carregar tempo0 com constante
        movwf   tempo0	    ; Carrega tempo0 
volta:
        nop		    ; gasta 1 ciclo de m?quina(1us para clock 4Mhz)
        decfsz  tempo0,F    ; Fim de tempo0 ? (gasta 2 us)
        goto    volta	    ; N?o - Volta (gasta 1us)
			    ; Sim - Passou-se 1ms. (4us x 250 = 1ms)
        decfsz  tempo1,F    ; Fim de tempo1?
        goto    denovo	    ; N?o - Volta 
			    ; Sim. 250 x 1ms = 250ms
        decfsz  tempo2,F    ; Fim de tempo2?
        goto    denovo2	    ; N?o - Volta 
			    ; Sim. 4 x 250 = 1s
return			    ; Retorna.

delay_cinco_segundos:
    call    delay_segundo		
    call    delay_segundo		
    call    delay_segundo		
    call    delay_segundo		
    call    delay_segundo		
return
    
verifica_sens_a:		
    ; se ele ja tiver começado e atingir o a, é pra parar de ir p esquerda
    btfsc	comecou, 0
    goto	$+2
    goto	$+3
    btfsc	PORTB,  0
    goto	$+2
    goto	$+4
    bcf		PORTB,5		; Desliga motor esquerdo
    movlw	0x00
    movwf	comecou
return
    

verifica_sens_b:
    ; se ele acabou de chegar ele começa a carregar, mas n faz nada se estiver
    ; esperando
    btfss	carregando, 0
    goto	$+2
    goto	$+3
    btfsc	PORTB,  1
    goto	$+2
    goto	$+5
    bcf		PORTB,6		; desliga motor direito 
    bsf		PORTB,4 	; Liga a comporta
    movlw	0x01
    movwf	carregando
return
    
verifica_sens_p:
    btfsc	PORTB,  3
    goto	$+2
    goto	$+6x'
    bcf		PORTB,4 	; Desliga a comporta
    call	delay_cinco_segundos
    bsf		PORTB,5		; Liga o motor esquerdo
    movlw	0x01
    movwf	comecou
return
verifica_btn_m:
    ; se ele estiver no A e for pressionado o M, inicia o percurso
    btfsc	PORTB,  0
    goto	$+2
    goto	$+3
    btfsc	PORTB,  2
    goto	$+2
    goto	$+5
    bsf		PORTB,6		; Liga motor direito
    movlw	0x01
    movwf	comecou
    call	delay_segundo
return
; Loop principal 
loop: 
    
    call	verifica_btn_m	
    
    call	verifica_sens_a
    
    call	verifica_sens_b
    
    call	verifica_sens_p
    
    goto	loop
    
   
    end		









