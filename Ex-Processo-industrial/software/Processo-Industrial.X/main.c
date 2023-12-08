/*******************************************************************************
    UFSC- Universidade Federal de Santa Catarina
    *Project Name:
        Exercicio do Processo Industrial
    *Copyright:;
	      Rodrigo Ferraz Souza
    *Test Configuration:
	     MCU:              P16F877A
	     Oscillator:       HS, 4.0 MHz
	     Ext. Modules:     -
    *NOTES:
	
*******************************************************************************/

#include <xc.h>
#include <pic16f877a.h>
#include <stdio.h>

#define _XTAL_FREQ 4000000

// Substitui��es dos nomes dos pinos pelas suas fun��es no circuito
#define sensor_nivel    PORTBbits.RB1
#define termostato      PORTBbits.RB2
#define misturador      PORTBbits.RB3
#define aquecedor       PORTBbits.RB4
#define valvula         PORTBbits.RB5
#define bomba           PORTBbits.RB6






int misturar = 0;
int contador_mistura = 0;
void __interrupt() tremInterruption(void){
    
    if(TMR1IF){
        if(misturar){
            misturador = 1;
            valvula = 0;
            contador_mistura++;
            if(contador_mistura == 20){
                misturador = 0;
                contador_mistura = 0;
                misturar = 0;
                valvula = 1;
                __delay_ms(2000);
                valvula = 0;
            }
        }
        PIR1bits.TMR1IF = 0;
        TMR1H = 0x0B;
        TMR1L = 0xDC;
    }
    
    return;
}
void main(void) {
    
    // Configura��o do PORTB
    TRISB =  0b00000111;
    PORTB = 0;
    
    
    // Configs de interrup��o
    INTCONbits.GIE = 1;
    INTCONbits.PEIE = 1;
    PIE1bits.TMR1IE = 1;
    
    /* Configura��o do Timer1 como temporazidaor*/
    T1CONbits.TMR1CS = 0;
    
    // Define o pre-scaler em 1:8
    T1CONbits.T1CKPS0 = 1;
    T1CONbits.T1CKPS1 = 1;
    
    /* Calculos para o contador
     * clock = 4Mhz -> clock/4 = 1Mhz
     * 1Mhz/8 = 125Khz -> periodo = 0.000008s ou 8ms
     * Para uma interrup��o a cada 500ms s�o necess�rias 62500 ciclos de m�quina
     * 65536 - 62500 = 3036     
     */
    TMR1H = 0x0B;
    TMR1L = 0xDC;
    
    T1CONbits.TMR1ON = 1;
    int btn_nivel = 0;
    // Loop infinito
    while(1){
        // o Sensor de n�vel usa uma l�gica invertida
        //      Quando ele est� sendo excitado, o sinal � 0, caso o nivel caia ele sinaliza com tens�o de 5v
        if(sensor_nivel && btn_nivel==0){
            btn_nivel = 1;
            bomba = 1;
            while(sensor_nivel);
            bomba = 0;
            aquecedor = 1;
            while(termostato == 0);
            aquecedor = 0;
            misturador = 1;
            misturar = 1;
            contador_mistura = 0;
            
        }else{
            if(sensor_nivel == 0){
                btn_nivel = 0;
            }
        }
        
    }
    return;
}
