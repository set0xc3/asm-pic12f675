PROCESSOR 12F675

// /opt/microchip/xc8/v2.41/pic/include/proc/pic12f675.inc
#include <pic12f675.inc>
    
// Определяем частоту тактирования
FOSC equ 4000000

// Определяем период таймера (в миллисекундах)
TMR0_PERIOD_MS equ 10
    
CONFIG  FOSC    = INTRCIO ; Oscillator Selection bits (INTOSC oscillator: I/O function on GP4/OSC2/CLKOUT pin, I/O function on GP5/OSC1/CLKIN)
CONFIG  WDTE    = OFF     ; Watchdog Timer Enable bit (WDT disabled)
CONFIG  PWRTE   = OFF     ; Power-Up Timer Enable bit (PWRT disabled)
CONFIG  MCLRE   = OFF     ; GP3/MCLR pin function select (GP3/MCLR pin function is digital I/O, MCLR internally tied to VDD)
CONFIG  BOREN   = OFF     ; Brown-out Detect Enable bit (BOD disabled)
CONFIG  CP      = OFF     ; Code Protection bit (Program Memory code protection is disabled)
CONFIG  CPD     = OFF     ; Data Code Protection bit (Data memory code protection is disabled)

PSECT ResetVector, class=CODE, delta=2
ResetVector:
    PAGESEL InitAll
    GOTO InitAll
    
PSECT ISRVector, class=CODE, delta=2
ISRVector:
    BCF	    STATUS, STATUS_RP0_POSITION	    ; Set bank 1
    
    BCF	    GPIO, GPIO_GPIO4_POSITION	    ; Disable GPI04
    BCF	    INTCON, INTCON_T0IF_POSITION    ; Clear T0IF
    BSF	    GPIO, GPIO_GPIO4_POSITION	    ; Enable GPI04
    CLRF    TMR0			    ; Clear Timer0 register
    RETFIE

PSECT code, delta=2
InitAll:
    BCF STATUS, STATUS_RP0_POSITION	; Set bank 1
    
    CLRF    GPIO			; Set byte at address GPIO to 0
    
    MOVLW   0x07
    MOVWF   CMCON			; Disable comparator
    
    BSF	    STATUS, STATUS_RP0_POSITION ; Set bank 2
    
    CLRF    ANSEL			; Set ports as digital I/O, not analog input
    
    MOVLW   0x08			; GP3 input, rest all output
    MOVWF   TRISIO			; Turns all pins which can act as digital outputs
    
    CALL    InitTimer0
    GOTO    Main
    
PSECT code, delta=2
InitTimer0:
    BCF	    STATUS, STATUS_RP0_POSITION	    ; Set bank 1
    
    CLRF    TMR0			    ; Clear Timer0 register
    CLRF    INTCON			    ; Disable interrupts and clear T0IF
    BSF	    INTCON, INTCON_T0IE_POSITION    ; Enable TMR0 interrupt
    BSF	    INTCON, INTCON_GIE_POSITION	    ; Enable all interrupts
    
    BSF	    STATUS, STATUS_RP0_POSITION	    ; Set bank 2
    
    MOVLW   0x08			    ; 1:8
    MOVWF   OPTION_REG			    ; Timer0 increment from internal clock with a prescaler of 1:8
    
    RETURN
    
PSECT code, delta=2
Main:
    GOTO    Main
END ResetVector
