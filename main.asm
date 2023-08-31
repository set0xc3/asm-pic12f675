PROCESSOR 12F675

// /opt/microchip/xc8/v2.41/pic/include/proc/pic12f675.inc
#include <xc.inc>
#include <pic12f675.inc>
    
CONFIG  FOSC    = INTRCIO ; Oscillator Selection bits (INTOSC oscillator: I/O function on GP4/OSC2/CLKOUT pin, I/O function on GP5/OSC1/CLKIN)
CONFIG  WDTE    = OFF     ; Watchdog Timer Enable bit (WDT disabled)
CONFIG  PWRTE   = OFF     ; Power-Up Timer Enable bit (PWRT disabled)
CONFIG  MCLRE   = OFF     ; GP3/MCLR pin function select (GP3/MCLR pin function is digital I/O, MCLR internally tied to VDD)
CONFIG  BOREN   = OFF     ; Brown-out Detect Enable bit (BOD disabled)
CONFIG  CP      = OFF     ; Code Protection bit (Program Memory code protection is disabled)
CONFIG  CPD     = OFF     ; Data Code Protection bit (Data memory code protection is disabled)

w_save	    EQU 0
s_save	    EQU 0
    
PSECT reset_vector, class=CODE, delta=2
reset_vector:
    GOTO main
PSECT isr_vector, class=CODE, delta=2
isr_vector:
    bcf	    INTF
    
    ; save context
    movwf   w_save
    movf    STATUS,w
    movwf   s_save
    
    BCF	    RP0 ; Set bank 0
    
    ; restore context
    movf    s_save,w
    movwf   STATUS
    movf    w_save,w
    
    RETFIE
PSECT code, delta=2
init_timer0:
    BCF	    RP0	    ; Set bank 0
    MOVLW   0xE7
    MOVWF   TMR0
    CLRF    INTCON  ; Disable interrupts and clear T0IF
    BSF	    T0IE    ; Enable TMR0 interrupt
    BSF	    GIE	    ; Enable all interrupts
    BSF	    RP0	    ; Set bank 1

    ; Configure TIMER0 with prescaler of 1:256 and enable interrupt
    MOVLW   0b111
    MOVWF   OPTION_REG
    RETURN
PSECT code, delta=2
main:
    BCF	    RP0		; Set bank 0
    CLRF    GPIO	; Set byte at address GPIO to 0
    MOVLW   0x07
    MOVWF   CMCON	; Disable comparator
    BSF	    RP0		; Set bank 1
    CLRF    ANSEL	; Set ports as digital I/O, not analog input
    MOVLW   0x08	; GP3 input, rest all output
    MOVWF   TRISIO	; Turns all pins which can act as digital outputs
    CALL    init_timer0
loop:
    BCF	    RP0	    ; Set bank 0
    BSF	    GPIO4   ; Enable GPI04
    BCF	    GPIO4   ; Disable GPI04
    GOTO    loop
END reset_vector