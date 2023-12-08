;*******************************************************************************
;    UFSC- Universidade Federal de Santa Catarina
;    *Project Name:
;	      Pisca com Botão
;    *Copyright:;
;	      Rodrigo Ferraz Souza
;    *Test Configuration:
;	     MCU:              P16F877A
;	     Oscillator:       HS, 4.0 MHz
;	     Ext. Modules:     -
;    *NOTES:
;	Começa desligado. Se apertar o botão ele pisca po 1s.
;*******************************************************************************

    
#include <P16F877A.INC> 	; Arquivo de include do uC usado, no caso PIC16F877A

; Palavra de configura??o, desabilita e habilita algumas op??es internas
__CONFIG  _CP_OFF & _CPD_OFF & _DEBUG_OFF & _LVP_OFF & _WRT_OFF & _BODEN_OFF & _PWRTE_OFF & _WDT_OFF & _XT_OSC

  
; Definição de variaveis
cblock 0x20
    tempo0		
    tempo1			; Vari?veis usadas na rotina de delay.	
endc
  
  
  
;************************ Vetor de Reset do uC ********************************
org 0x00			; Vetor de reset do uC.
goto inicio			; Desvia para o inicio do programa.

 
; Inicio do programa 
inicio:
    clrf	PORTB		; Inicializa o Port B com zero
    clrf	PORTD		; Inicializa o Port D com zero

    banksel	TRISB		; Seleciona banco de mem?ria 1
    movlw	0xff
    movwf	TRISB		; Configura tudo como entrada

    banksel	TRISD		; Seleciona banco de mem?ria 1
    movlw	0x00
    movwf	TRISD		; Configura tudo como saida

    movlw	0x00
    movwf	OPTION_REG	; Configura Op??es:
				; Pull-Up habilitados.
				; Interrup??o na borda de subida do sinal no pino B0.
				; Timer0 incrementado pelo oscilador interno.
				; Prescaler WDT 1:1.
				; Prescaler Timer0 1:2.
    banksel PORTA		; Seleciona banco de mem?ria 0.

    banksel PORTB		; Seleciona banco de mem?ria 1
    goto loop

    
; Rotinas e Sub-rotinas
delay_ms:
	movwf	tempo1		; Carrega tempo1 (Unidade de ms).
	movlw	.250
	movwf	tempo0		; Carrega tempo0 (Para contar 1ms).
	nop					; Perde tempo.
	decfsz	tempo0,F	; Fim de tempo0 ?
	goto	$-2			; N?o - Volta duas instru??es.
						; Sim - Passou-se 1ms.
	decfsz	tempo1,F	; Fim de tempo1 ?
	goto	$-6			; N?o - Volta seis instru??es.
						; Sim.
 return   			; Retorna.

blink:
    bsf	    PORTD,7		; Liga led
    call    delay_ms		; Rotina gasta tempo
    bcf	    PORTD,7		; Apaga
    return
; Loop principal 
loop: 
    btfss   PORTB,  0
    call    blink
    goto    loop
    
   
    end		



