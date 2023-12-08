;*******************************************************************************
;    UFSC- Universidade Federal de Santa Catarina
;    *Project Name:
;	      Display 7seg com contador com memória
;    *Copyright:;
;	      Rodrigo Ferraz Souza
;    *Test Configuration:
;	     MCU:              P16F877A
;	     Oscillator:       HS, 4.0 MHz
;	     Ext. Modules:     -
;    *NOTES:
;	Conta os numeros no display 7seg (2 digitos) e tem 3 botões
;	    um para incrementar e outro para decrementar
;	    um 3o para salvar o valor atual na memoria - quando apertado, zero o display
;	Se o valor do display for igual ao da memoria acende um led
;*******************************************************************************


#include <P16F877A.INC> 	; Arquivo de include do uC usado, no caso PIC16F877A

; Palavra de configura??o, desabilita e habilita algumas op??es internas
__CONFIG  _CP_OFF & _CPD_OFF & _DEBUG_OFF & _LVP_OFF & _WRT_OFF & _BODEN_OFF & _PWRTE_OFF & _WDT_OFF & _XT_OSC

  
; Definição de variaveis
cblock 0x20
    tempo0		
    tempo1	
    contador_display
    unidade_zero
    numero_salvo
endc
  
  
  
;************************ Vetor de Reset do uC ********************************
org 0x00			; Vetor de reset do uC.
goto inicio			; Desvia para o inicio do programa.
    
 ; Inicio do programa 
inicio:
    clrf	PORTB		; Inicializa o Port B com zero
    clrf	PORTD		; Inicializa o Port D com zero
    
    banksel	TRISB		
    movlw	0xff
    movwf	TRISB		; Configura tudo como entrada
    
    banksel	TRISD		
    movlw	0x00
    movwf	TRISD		; Configura tudo como saida
    
    banksel	TRISC		
    movlw	0x00
    movwf	TRISC		; Configura tudo como saida
    
    banksel	TRISA		
    movlw	0x00
    movwf	OPTION_REG	; Configura Opções:
				; Pull-Up habilitados.
				; Interrup??o na borda de subida do sinal no pino B0.
				; Timer0 incrementado pelo oscilador interno.
				; Prescaler WDT 1:1.
				; Prescaler Timer0 1:2.
    banksel	PORTA		; Seleciona banco de mem?ria 0.
    
    movlw	0x00
    movwf	contador_display
    movwf	unidade_zero
    movlw	0x00
    movwf	PORTC
    
    goto	loop

;sub-rotinas decremento
    
    ;esse bloco verifica os 4 bits da unidade do contador ]
    ;e levanta uma flga se for tudo 0
    verifica_unidade0:
	btfss	contador_display, 0
	call	verifica_unidade1
	nop
	return
    verifica_unidade1:
	btfss	contador_display, 1
	call	verifica_unidade2
	nop
	return
    verifica_unidade2:
	btfss	contador_display, 2
	call	verifica_unidade3
	nop
	return
    verifica_unidade3:
	btfss	contador_display, 3
	call	set_flag_unidade
	nop
	return
    ;fim do bloco de verificar unidade
    
    ;levanta uma flag se a unidade for 0
    set_flag_unidade:
	movlw	0x01
	movwf	unidade_zero
	return
	
    decrementa_unidade:
	decf	contador_display, W 
	movwf	contador_display
	return
    decrementa_dezena:
	; decrementa 0x06 do contador 
	;(não sei fazer isso por comando pq o COMF não funciona)
	decf	contador_display, W 
	movwf	contador_display
	decf	contador_display, W 
	movwf	contador_display
	decf	contador_display, W 
	movwf	contador_display
	decf	contador_display, W 
	movwf	contador_display
	decf	contador_display, W 
	movwf	contador_display
	decf	contador_display, W 
	movwf	contador_display
	return
	
	
;sub-rotinas incremento
    ;como a parte da unidade atingiu 10 (1010), 
    ;somo 6 para dar 16 e somar 1 na dezena
    incrementa_dezena:
	movf	contador_display,	W
	addlw	0x06
	movwf	contador_display
	return

    ;verifica se o bit 1 do contador é 1 
    verifica_dezena1:
	btfsc	contador_display, 1
	call	incrementa_dezena
	nop
	return

    ;verifica se o bit 3 do contador é 1
    verifica_dezena3:
	btfsc	contador_display, 3
	call	verifica_dezena1
	nop
	return
	
	
;Rotinas
delay_ms:
    movwf	tempo1		; Carrega tempo1 (Unidade de ms).
    movlw	.250
    movwf	tempo0		; Carrega tempo0 (Para contar 1ms).
    nop				; Perde tempo.
    decfsz	tempo0,F	; Fim de tempo0 ?
    goto	$-2		; N?o - Volta duas instru??es.
				; Sim - Passou-se 1ms.
    decfsz	tempo1,F	; Fim de tempo1 ?
    goto	$-6		; N?o - Volta seis instru??es.
				; Sim.
return 

;Converte o numero em 2 casas decimais e mostra no display
mostra_numero_display:
    movf	contador_display,	W
    movwf	PORTD
    return


incrementa_contador:
    ;soma 1 no contador
    movf	contador_display,	W
    addlw	1
    movwf	contador_display
    
    ;inicia a verificação para ver se a unidade atingiu "10"
    call	verifica_dezena3   
    
    ; Faz 2 delays pq 1 não funciona por algum motivo...
    call	delay_ms
    call	delay_ms
    return




decrementa_contador:
    ;Verifica se a unidade é 0 e levanta uma flag se for
    call	verifica_unidade0
    
    ;verifica a flag da unidade 
    ;e se for 0 decrementa uma dezena e deixa a unidade com 9
    btfsc	unidade_zero, 0
    call	decrementa_dezena
    call	decrementa_unidade
    
    ; Faz 2 delays pq 1 não funciona por algum motivo...
    call	delay_ms
    call	delay_ms
    return
    
save_number:

    movf	contador_display,	W
    movwf	numero_salvo
    movlw	0x00
    movwf	contador_display
    ; Faz 2 delays pq 1 não funciona por algum motivo...
    call	delay_ms
    call	delay_ms
    return
pulse:
    call	incrementa_contador
    ; verifica se o numero do display é igual ao da memoria
    call	mostra_numero_display
    movf	numero_salvo, W
    subwf	contador_display, W
    btfsc	STATUS,Z
    goto	$+2
    goto	$+7
    movlw	0x00
    movwf	contador_display
    movlw	0x20    
    movwf	PORTC
    call	delay_ms
    call	delay_ms
    nop
    movlw	0x00
    movwf	PORTC
    
    
    
    
    return
loop:
    
    ;verifica o botão +
    btfss	PORTB,  0
    call	incrementa_contador
    nop
    
    ;verifica o botão -
    btfss	PORTB,  1
    call	decrementa_contador
    nop
    
    ;verifica o botão enter
    btfss	PORTB,  2
    call	save_number
    nop
    
    ;verifica o botão pulse
    btfss	PORTB,  3
    call	pulse
    nop
   
    
    
    call	mostra_numero_display
    goto	loop
    end