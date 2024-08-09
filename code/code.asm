
_configureINT0:

;code.c,62 :: 		void configureINT0(){
;code.c,66 :: 		INTCON.GIE = 1;
	BSF        INTCON+0, 7
;code.c,70 :: 		INTCON.INTE = 1;
	BSF        INTCON+0, 4
;code.c,74 :: 		INTCON.INTF = 0;
	BCF        INTCON+0, 1
;code.c,78 :: 		OPTION_REG.INTEDG = 1;
	BSF        OPTION_REG+0, 6
;code.c,80 :: 		}
L_end_configureINT0:
	RETURN
; end of _configureINT0

_initialize:

;code.c,84 :: 		void initialize() {
;code.c,88 :: 		TRISB = 0x03;
	MOVLW      3
	MOVWF      TRISB+0
;code.c,92 :: 		TRISC = 0x00;
	CLRF       TRISC+0
;code.c,96 :: 		TRISD = 0x00;
	CLRF       TRISD+0
;code.c,100 :: 		PORTC = 0x00;
	CLRF       PORTC+0
;code.c,104 :: 		PORTD = 0x00;
	CLRF       PORTD+0
;code.c,107 :: 		UNITS_ENABLE = 1;
	BSF        PORTB+0, 2
;code.c,108 :: 		TENS_ENABLE = 1;
	BSF        PORTB+0, 3
;code.c,109 :: 		}
L_end_initialize:
	RETURN
; end of _initialize

_interrupt:
	MOVWF      R15+0
	SWAPF      STATUS+0, 0
	CLRF       STATUS+0
	MOVWF      ___saveSTATUS+0
	MOVF       PCLATH+0, 0
	MOVWF      ___savePCLATH+0
	CLRF       PCLATH+0

;code.c,113 :: 		void interrupt() {
;code.c,117 :: 		if (INTCON.INTF) {
	BTFSS      INTCON+0, 1
	GOTO       L_interrupt0
;code.c,118 :: 		Delay_ms(30)  ;
	MOVLW      78
	MOVWF      R12+0
	MOVLW      235
	MOVWF      R13+0
L_interrupt1:
	DECFSZ     R13+0, 1
	GOTO       L_interrupt1
	DECFSZ     R12+0, 1
	GOTO       L_interrupt1
;code.c,121 :: 		INTCON.INTF = 0;
	BCF        INTCON+0, 1
;code.c,125 :: 		current_mode = (current_mode == 0?1 :0);
	MOVF       _current_mode+0, 0
	XORLW      0
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt2
	MOVLW      1
	MOVWF      R1+0
	GOTO       L_interrupt3
L_interrupt2:
	CLRF       R1+0
L_interrupt3:
	MOVF       R1+0, 0
	MOVWF      _current_mode+0
;code.c,127 :: 		}
L_interrupt0:
;code.c,129 :: 		}
L_end_interrupt:
L__interrupt63:
	MOVF       ___savePCLATH+0, 0
	MOVWF      PCLATH+0
	SWAPF      ___saveSTATUS+0, 0
	MOVWF      STATUS+0
	SWAPF      R15+0, 1
	SWAPF      R15+0, 0
	RETFIE
; end of _interrupt

_display:

;code.c,131 :: 		void display(unsigned char seconds) {
;code.c,133 :: 		unsigned char tens = seconds / 10;
	MOVLW      10
	MOVWF      R4+0
	MOVF       FARG_display_seconds+0, 0
	MOVWF      R0+0
	CALL       _Div_8X8_U+0
	MOVF       R0+0, 0
	MOVWF      display_tens_L0+0
;code.c,135 :: 		unsigned char units = seconds % 10;
	MOVLW      10
	MOVWF      R4+0
	MOVF       FARG_display_seconds+0, 0
	MOVWF      R0+0
	CALL       _Div_8X8_U+0
	MOVF       R8+0, 0
	MOVWF      R0+0
	MOVF       R0+0, 0
	MOVWF      display_units_L0+0
;code.c,138 :: 		if (seconds == 0 ){
	MOVF       FARG_display_seconds+0, 0
	XORLW      0
	BTFSS      STATUS+0, 2
	GOTO       L_display4
;code.c,139 :: 		UNITS_ENABLE = 0;
	BCF        PORTB+0, 2
;code.c,140 :: 		TENS_ENABLE = 0;
	BCF        PORTB+0, 3
;code.c,141 :: 		} else {
	GOTO       L_display5
L_display4:
;code.c,142 :: 		UNITS_ENABLE = 1;
	BSF        PORTB+0, 2
;code.c,143 :: 		TENS_ENABLE = 1;
	BSF        PORTB+0, 3
;code.c,144 :: 		}
L_display5:
;code.c,145 :: 		PORTC = (units & 0x0F) | ((tens & 0x0F) << 4);
	MOVLW      15
	ANDWF      display_units_L0+0, 0
	MOVWF      R3+0
	MOVLW      15
	ANDWF      display_tens_L0+0, 0
	MOVWF      R2+0
	MOVF       R2+0, 0
	MOVWF      R0+0
	RLF        R0+0, 1
	BCF        R0+0, 0
	RLF        R0+0, 1
	BCF        R0+0, 0
	RLF        R0+0, 1
	BCF        R0+0, 0
	RLF        R0+0, 1
	BCF        R0+0, 0
	MOVF       R0+0, 0
	IORWF      R3+0, 0
	MOVWF      PORTC+0
;code.c,147 :: 		}
L_end_display:
	RETURN
; end of _display

_main:

;code.c,149 :: 		int main() {
;code.c,151 :: 		initialize();
	CALL       _initialize+0
;code.c,153 :: 		configureINT0();
	CALL       _configureINT0+0
;code.c,155 :: 		while (1) {
L_main6:
;code.c,159 :: 		if(!current_mode){
	MOVF       _current_mode+0, 0
	BTFSS      STATUS+0, 2
	GOTO       L_main8
;code.c,161 :: 		WEST_RED_LIGHT = 1;
	BSF        PORTD+0, 0
;code.c,163 :: 		for (i = WEST_RED_TIME; i > 0 && !current_mode; i--) {
	MOVLW      15
	MOVWF      _i+0
L_main9:
	MOVF       _i+0, 0
	SUBLW      0
	BTFSC      STATUS+0, 0
	GOTO       L_main10
	MOVF       _current_mode+0, 0
	BTFSS      STATUS+0, 2
	GOTO       L_main10
L__main59:
;code.c,165 :: 		SOUTH_GREEN_LIGHT = (i > 3 ? 1 : 0);
	MOVF       _i+0, 0
	SUBLW      3
	BTFSC      STATUS+0, 0
	GOTO       L_main14
	MOVLW      1
	MOVWF      ?FLOC___mainT41+0
	GOTO       L_main15
L_main14:
	CLRF       ?FLOC___mainT41+0
L_main15:
	BTFSC      ?FLOC___mainT41+0, 0
	GOTO       L__main66
	BCF        PORTD+0, 5
	GOTO       L__main67
L__main66:
	BSF        PORTD+0, 5
L__main67:
;code.c,167 :: 		SOUTH_YELLOW_LIGHT = (i <= 3 ? 1 : 0);
	MOVF       _i+0, 0
	SUBLW      3
	BTFSS      STATUS+0, 0
	GOTO       L_main16
	MOVLW      1
	MOVWF      ?FLOC___mainT45+0
	GOTO       L_main17
L_main16:
	CLRF       ?FLOC___mainT45+0
L_main17:
	BTFSC      ?FLOC___mainT45+0, 0
	GOTO       L__main68
	BCF        PORTD+0, 4
	GOTO       L__main69
L__main68:
	BSF        PORTD+0, 4
L__main69:
;code.c,169 :: 		display(i);
	MOVF       _i+0, 0
	MOVWF      FARG_display_seconds+0
	CALL       _display+0
;code.c,171 :: 		Delay_ms(1000);
	MOVLW      11
	MOVWF      R11+0
	MOVLW      38
	MOVWF      R12+0
	MOVLW      93
	MOVWF      R13+0
L_main18:
	DECFSZ     R13+0, 1
	GOTO       L_main18
	DECFSZ     R12+0, 1
	GOTO       L_main18
	DECFSZ     R11+0, 1
	GOTO       L_main18
	NOP
	NOP
;code.c,163 :: 		for (i = WEST_RED_TIME; i > 0 && !current_mode; i--) {
	DECF       _i+0, 1
;code.c,173 :: 		}
	GOTO       L_main9
L_main10:
;code.c,175 :: 		WEST_RED_LIGHT = 0;
	BCF        PORTD+0, 0
;code.c,177 :: 		SOUTH_YELLOW_LIGHT = 0;
	BCF        PORTD+0, 4
;code.c,179 :: 		SOUTH_RED_LIGHT = 1;
	BSF        PORTD+0, 3
;code.c,181 :: 		for (i = SOUTH_RED_TIME; i > 0 && !current_mode; i--) {
	MOVLW      23
	MOVWF      _i+0
L_main19:
	MOVF       _i+0, 0
	SUBLW      0
	BTFSC      STATUS+0, 0
	GOTO       L_main20
	MOVF       _current_mode+0, 0
	BTFSS      STATUS+0, 2
	GOTO       L_main20
L__main58:
;code.c,183 :: 		WEST_GREEN_LIGHT = (i > 3 ? 1 : 0);
	MOVF       _i+0, 0
	SUBLW      3
	BTFSC      STATUS+0, 0
	GOTO       L_main24
	MOVLW      1
	MOVWF      ?FLOC___mainT59+0
	GOTO       L_main25
L_main24:
	CLRF       ?FLOC___mainT59+0
L_main25:
	BTFSC      ?FLOC___mainT59+0, 0
	GOTO       L__main70
	BCF        PORTD+0, 2
	GOTO       L__main71
L__main70:
	BSF        PORTD+0, 2
L__main71:
;code.c,185 :: 		WEST_YELLOW_LIGHT = (i <= 3 ? 1 : 0);
	MOVF       _i+0, 0
	SUBLW      3
	BTFSS      STATUS+0, 0
	GOTO       L_main26
	MOVLW      1
	MOVWF      ?FLOC___mainT63+0
	GOTO       L_main27
L_main26:
	CLRF       ?FLOC___mainT63+0
L_main27:
	BTFSC      ?FLOC___mainT63+0, 0
	GOTO       L__main72
	BCF        PORTD+0, 1
	GOTO       L__main73
L__main72:
	BSF        PORTD+0, 1
L__main73:
;code.c,187 :: 		display(i);
	MOVF       _i+0, 0
	MOVWF      FARG_display_seconds+0
	CALL       _display+0
;code.c,189 :: 		Delay_ms(1000);
	MOVLW      11
	MOVWF      R11+0
	MOVLW      38
	MOVWF      R12+0
	MOVLW      93
	MOVWF      R13+0
L_main28:
	DECFSZ     R13+0, 1
	GOTO       L_main28
	DECFSZ     R12+0, 1
	GOTO       L_main28
	DECFSZ     R11+0, 1
	GOTO       L_main28
	NOP
	NOP
;code.c,181 :: 		for (i = SOUTH_RED_TIME; i > 0 && !current_mode; i--) {
	DECF       _i+0, 1
;code.c,191 :: 		}
	GOTO       L_main19
L_main20:
;code.c,193 :: 		SOUTH_RED_LIGHT = 0;
	BCF        PORTD+0, 3
;code.c,195 :: 		WEST_YELLOW_LIGHT = 0;
	BCF        PORTD+0, 1
;code.c,197 :: 		}
	GOTO       L_main29
L_main8:
;code.c,203 :: 		if (WEST_RED_LIGHT) {
	BTFSS      PORTD+0, 0
	GOTO       L_main30
;code.c,205 :: 		for(i = SOUTH_YELLOW_TIME; i > 0 && current_mode; i--) {
	MOVLW      3
	MOVWF      _i+0
L_main31:
	MOVF       _i+0, 0
	SUBLW      0
	BTFSC      STATUS+0, 0
	GOTO       L_main32
	MOVF       _current_mode+0, 0
	BTFSC      STATUS+0, 2
	GOTO       L_main32
L__main57:
;code.c,207 :: 		SOUTH_YELLOW_LIGHT = 1;
	BSF        PORTD+0, 4
;code.c,209 :: 		SOUTH_GREEN_LIGHT = 0;
	BCF        PORTD+0, 5
;code.c,211 :: 		display(i);
	MOVF       _i+0, 0
	MOVWF      FARG_display_seconds+0
	CALL       _display+0
;code.c,213 :: 		Delay_ms(1000);
	MOVLW      11
	MOVWF      R11+0
	MOVLW      38
	MOVWF      R12+0
	MOVLW      93
	MOVWF      R13+0
L_main36:
	DECFSZ     R13+0, 1
	GOTO       L_main36
	DECFSZ     R12+0, 1
	GOTO       L_main36
	DECFSZ     R11+0, 1
	GOTO       L_main36
	NOP
	NOP
;code.c,205 :: 		for(i = SOUTH_YELLOW_TIME; i > 0 && current_mode; i--) {
	DECF       _i+0, 1
;code.c,215 :: 		}
	GOTO       L_main31
L_main32:
;code.c,217 :: 		while(current_mode && MANUAL_SWITCH ==1) {
L_main37:
	MOVF       _current_mode+0, 0
	BTFSC      STATUS+0, 2
	GOTO       L_main38
	BTFSS      PORTB+0, 1
	GOTO       L_main38
L__main56:
;code.c,219 :: 		WEST_RED_LIGHT = 0;
	BCF        PORTD+0, 0
;code.c,221 :: 		WEST_YELLOW_LIGHT = 0;
	BCF        PORTD+0, 1
;code.c,223 :: 		WEST_GREEN_LIGHT = 1;
	BSF        PORTD+0, 2
;code.c,225 :: 		SOUTH_RED_LIGHT = 1;
	BSF        PORTD+0, 3
;code.c,227 :: 		SOUTH_YELLOW_LIGHT = 0;
	BCF        PORTD+0, 4
;code.c,229 :: 		SOUTH_GREEN_LIGHT = 0;
	BCF        PORTD+0, 5
;code.c,231 :: 		display(0);
	CLRF       FARG_display_seconds+0
	CALL       _display+0
;code.c,233 :: 		Delay_ms(50);
	MOVLW      130
	MOVWF      R12+0
	MOVLW      221
	MOVWF      R13+0
L_main41:
	DECFSZ     R13+0, 1
	GOTO       L_main41
	DECFSZ     R12+0, 1
	GOTO       L_main41
	NOP
	NOP
;code.c,235 :: 		}
	GOTO       L_main37
L_main38:
;code.c,237 :: 		} else {
	GOTO       L_main42
L_main30:
;code.c,239 :: 		for(i = WEST_YELLOW_TIME; i > 0 && current_mode; i--) {
	MOVLW      3
	MOVWF      _i+0
L_main43:
	MOVF       _i+0, 0
	SUBLW      0
	BTFSC      STATUS+0, 0
	GOTO       L_main44
	MOVF       _current_mode+0, 0
	BTFSC      STATUS+0, 2
	GOTO       L_main44
L__main55:
;code.c,241 :: 		WEST_YELLOW_LIGHT = 1;
	BSF        PORTD+0, 1
;code.c,243 :: 		WEST_GREEN_LIGHT = 0;
	BCF        PORTD+0, 2
;code.c,245 :: 		display(i);
	MOVF       _i+0, 0
	MOVWF      FARG_display_seconds+0
	CALL       _display+0
;code.c,247 :: 		Delay_ms(1000);
	MOVLW      11
	MOVWF      R11+0
	MOVLW      38
	MOVWF      R12+0
	MOVLW      93
	MOVWF      R13+0
L_main48:
	DECFSZ     R13+0, 1
	GOTO       L_main48
	DECFSZ     R12+0, 1
	GOTO       L_main48
	DECFSZ     R11+0, 1
	GOTO       L_main48
	NOP
	NOP
;code.c,239 :: 		for(i = WEST_YELLOW_TIME; i > 0 && current_mode; i--) {
	DECF       _i+0, 1
;code.c,251 :: 		}
	GOTO       L_main43
L_main44:
;code.c,254 :: 		while(current_mode && MANUAL_SWITCH == 1) {
L_main49:
	MOVF       _current_mode+0, 0
	BTFSC      STATUS+0, 2
	GOTO       L_main50
	BTFSS      PORTB+0, 1
	GOTO       L_main50
L__main54:
;code.c,256 :: 		WEST_RED_LIGHT = 1;
	BSF        PORTD+0, 0
;code.c,258 :: 		WEST_YELLOW_LIGHT = 0;
	BCF        PORTD+0, 1
;code.c,260 :: 		WEST_GREEN_LIGHT = 0;
	BCF        PORTD+0, 2
;code.c,262 :: 		SOUTH_RED_LIGHT = 0;
	BCF        PORTD+0, 3
;code.c,264 :: 		SOUTH_YELLOW_LIGHT = 0;
	BCF        PORTD+0, 4
;code.c,266 :: 		SOUTH_GREEN_LIGHT = 1;
	BSF        PORTD+0, 5
;code.c,268 :: 		display(0);
	CLRF       FARG_display_seconds+0
	CALL       _display+0
;code.c,270 :: 		Delay_ms(50);
	MOVLW      130
	MOVWF      R12+0
	MOVLW      221
	MOVWF      R13+0
L_main53:
	DECFSZ     R13+0, 1
	GOTO       L_main53
	DECFSZ     R12+0, 1
	GOTO       L_main53
	NOP
	NOP
;code.c,272 :: 		}
	GOTO       L_main49
L_main50:
;code.c,274 :: 		}
L_main42:
;code.c,276 :: 		}
L_main29:
;code.c,278 :: 		}
	GOTO       L_main6
;code.c,280 :: 		}
L_end_main:
	GOTO       $+0
; end of _main
