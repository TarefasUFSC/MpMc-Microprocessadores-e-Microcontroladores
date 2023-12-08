/*******************************************************************************
    UFSC- Universidade Federal de Santa Catarina
    *Project Name:
        Exercicio da Cancela
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

#define ST PORTBbits.RB0

#define MotorFechando PORTCbits.RC0
#define MotorAbrindo PORTCbits.RC1
#define LedFechando PORTCbits.RC2
#define LedAbrindo PORTCbits.RC3

#define SA PORTCbits.RC5
#define SCF PORTCbits.RC6
#define SCA PORTCbits.RC7

// direction -> A: Turns motor to the Left
//              F: Turns motor do the Right
void rotateMotor(char direction)
{
    int abrindo = direction == 'A' || direction == 'a';
    int fechando = direction == 'F' || direction == 'f';
    MotorAbrindo = abrindo;
    LedAbrindo = abrindo;
    MotorFechando = fechando;
    LedFechando = fechando;
    return;
}
void stopMotor()
{
    MotorAbrindo = 0;
    MotorFechando = 0;

    LedAbrindo = 0;
    LedFechando = 0;
}
int SA_press = 0;
int trem_passando = 0;
void __interrupt() tremInterruption(void)
{

    if (INTF)
    {
        trem_passando = 1;
        rotateMotor('F');
        while (SCF == 0)
            ;
        stopMotor();
        SA_press = 0;
        INTCONbits.INTF = 0;
    }

    return;
}
void main(void)
{
    OPTION_REGbits.INTEDG = 1;
    INTCONbits.GIE = 1;
    INTCONbits.INTE = 1;

    TRISB = 0XFF;
    PORTB = 0;

    TRISC = 0XF0;
    PORTC = 0;
    while (1)
    {
        trem_passando = 0;
        if (SA && SA_press == 0)
        {
            SA_press = 1;
            rotateMotor('A');
            while (SCA == 0)
            {
                if (trem_passando)
                {
                    break;
                }
            }
            if (trem_passando)
            {
                break;
            }
            stopMotor();
            for (int i = 0; i < 20; i++)
            {
                if (trem_passando)
                {
                    break;
                }
                __delay_ms(100);
            }
            rotateMotor('F');
            while (SCF == 0)
            {
                if (trem_passando)
                {
                    break;
                }
            }
            stopMotor();
        }
        else
        {
            if (!SA)
            {
                SA_press = 0;
            }
        }
    }
    return;
}
