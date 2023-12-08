#include <xc.h>
#include <pic16f877a.h>
#include <stdio.h>

#define _XTAL_FREQ 4000000

#define ST PORTBbits.RB0
#define SA PORTBbits.RB3
#define SCF PORTBbits.RB7
#define SCA PORTBbits.RB6
#define MCA PORTBbits.RD3
#define MCF PORTBbits.RD4
#define Sirene PORTDbits.RD0

void motorAbrir(void)
{            // Função para abrir a cancela
    MCA = 1; // Motor de abrir cancela ligado
    MCF = 0; // Motor de fechar cancela desligado

    while (SCF)
        ;
};

void motorFechar(void)
{
    MCA = 0;
    MCF = 1;

    while (SCA)
        ;
};

void motorParar(void)
{ // Função para parar o motor
    MCA = 0;
    MCF = 0;
};

void __interrupt() interrupcao(void)
{
    if (INTF)
    {

        if (!SA)
        {
            __delay_ms(2000); // 2 segundos pra testar
        }

        motorParar();
        motorFechar();
        INTCONbits.INTF = 0;
    }
}

void main(void)
{

    OPTION_REGbits.INTEDG = 1;
    INTCONbits.GIE = 1;
    INTCONbits.INTE = 1;

    TRISB = 1;

    TRISD = 0;
    PORTD = 0;

    OPTION_REG = 0b01111111;
    while (1)
    {
        Sirene = !ST;
    }
}