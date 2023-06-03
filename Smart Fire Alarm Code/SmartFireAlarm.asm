
_msDelay:

;SmartFireAlarm.c,39 :: 		void msDelay(unsigned int mscnt) {
;SmartFireAlarm.c,42 :: 		for (ms = 0; ms < mscnt; ms++) {
	CLRF       R1+0
	CLRF       R1+1
L_msDelay0:
	MOVF       FARG_msDelay_mscnt+1, 0
	SUBWF      R1+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__msDelay34
	MOVF       FARG_msDelay_mscnt+0, 0
	SUBWF      R1+0, 0
L__msDelay34:
	BTFSC      STATUS+0, 0
	GOTO       L_msDelay1
;SmartFireAlarm.c,43 :: 		for (cnt = 0; cnt < 155; cnt++);
	CLRF       R3+0
	CLRF       R3+1
L_msDelay3:
	MOVLW      0
	SUBWF      R3+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__msDelay35
	MOVLW      155
	SUBWF      R3+0, 0
L__msDelay35:
	BTFSC      STATUS+0, 0
	GOTO       L_msDelay4
	INCF       R3+0, 1
	BTFSC      STATUS+0, 2
	INCF       R3+1, 1
	GOTO       L_msDelay3
L_msDelay4:
;SmartFireAlarm.c,42 :: 		for (ms = 0; ms < mscnt; ms++) {
	INCF       R1+0, 1
	BTFSC      STATUS+0, 2
	INCF       R1+1, 1
;SmartFireAlarm.c,44 :: 		}
	GOTO       L_msDelay0
L_msDelay1:
;SmartFireAlarm.c,45 :: 		}
L_end_msDelay:
	RETURN
; end of _msDelay

_PWM:

;SmartFireAlarm.c,48 :: 		void PWM(unsigned int p, unsigned int d){
;SmartFireAlarm.c,51 :: 		period=p;//milliseconds
	MOVF       FARG_PWM_p+0, 0
	MOVWF      _period+0
	MOVF       FARG_PWM_p+1, 0
	MOVWF      _period+1
;SmartFireAlarm.c,52 :: 		duty=(d*p)/100;
	MOVF       FARG_PWM_d+0, 0
	MOVWF      R0+0
	MOVF       FARG_PWM_d+1, 0
	MOVWF      R0+1
	MOVF       FARG_PWM_p+0, 0
	MOVWF      R4+0
	MOVF       FARG_PWM_p+1, 0
	MOVWF      R4+1
	CALL       _Mul_16X16_U+0
	MOVLW      100
	MOVWF      R4+0
	MOVLW      0
	MOVWF      R4+1
	CALL       _Div_16X16_U+0
	MOVF       R0+0, 0
	MOVWF      _duty+0
	MOVF       R0+1, 0
	MOVWF      _duty+1
;SmartFireAlarm.c,53 :: 		PORTD= 0x05;//High
	MOVLW      5
	MOVWF      PORTD+0
;SmartFireAlarm.c,54 :: 		msDelay(duty);
	MOVF       R0+0, 0
	MOVWF      FARG_msDelay_mscnt+0
	MOVF       R0+1, 0
	MOVWF      FARG_msDelay_mscnt+1
	CALL       _msDelay+0
;SmartFireAlarm.c,55 :: 		PORTD=0x00;//Low
	CLRF       PORTD+0
;SmartFireAlarm.c,56 :: 		msDelay(period-duty);
	MOVF       _duty+0, 0
	SUBWF      _period+0, 0
	MOVWF      FARG_msDelay_mscnt+0
	MOVF       _duty+1, 0
	BTFSS      STATUS+0, 0
	ADDLW      1
	SUBWF      _period+1, 0
	MOVWF      FARG_msDelay_mscnt+1
	CALL       _msDelay+0
;SmartFireAlarm.c,57 :: 		}
L_end_PWM:
	RETURN
; end of _PWM

_interrupt:
	MOVWF      R15+0
	SWAPF      STATUS+0, 0
	CLRF       STATUS+0
	MOVWF      ___saveSTATUS+0
	MOVF       PCLATH+0, 0
	MOVWF      ___savePCLATH+0
	CLRF       PCLATH+0

;SmartFireAlarm.c,62 :: 		void interrupt(){
;SmartFireAlarm.c,64 :: 		myRxBuffer = RCREG;
	MOVF       RCREG+0, 0
	MOVWF      _myRxBuffer+0
;SmartFireAlarm.c,65 :: 		myRxFlag = 1;
	MOVLW      1
	MOVWF      _myRxFlag+0
;SmartFireAlarm.c,66 :: 		if(INTCON&0x04){
	BTFSS      INTCON+0, 2
	GOTO       L_interrupt6
;SmartFireAlarm.c,67 :: 		flame = ATD_read();
	CALL       _ATD_read+0
	MOVF       R0+0, 0
	MOVWF      _flame+0
	MOVF       R0+1, 0
	MOVWF      _flame+1
;SmartFireAlarm.c,68 :: 		DelayCntr++;
	INCF       _DelayCntr+0, 1
	BTFSC      STATUS+0, 2
	INCF       _DelayCntr+1, 1
;SmartFireAlarm.c,69 :: 		DelayCntr1++;
	INCF       _DelayCntr1+0, 1
	BTFSC      STATUS+0, 2
	INCF       _DelayCntr1+1, 1
;SmartFireAlarm.c,70 :: 		if (DelayCntr1==30){
	MOVLW      0
	XORWF      _DelayCntr1+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__interrupt39
	MOVLW      30
	XORWF      _DelayCntr1+0, 0
L__interrupt39:
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt7
;SmartFireAlarm.c,71 :: 		if(flagH == 0){
	MOVF       _flagH+0, 0
	XORLW      0
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt8
;SmartFireAlarm.c,72 :: 		if(flagL==0){
	MOVF       _flagL+0, 0
	XORLW      0
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt9
;SmartFireAlarm.c,73 :: 		Lcd_Cmd(_LCD_CLEAR);               // Clear display
	MOVLW      1
	MOVWF      FARG_Lcd_Cmd_out_char+0
	CALL       _Lcd_Cmd+0
;SmartFireAlarm.c,74 :: 		Lcd_Out(1,1,txt5);                 // Write text in first row
	MOVLW      1
	MOVWF      FARG_Lcd_Out_row+0
	MOVLW      1
	MOVWF      FARG_Lcd_Out_column+0
	MOVLW      _txt5+0
	MOVWF      FARG_Lcd_Out_text+0
	CALL       _Lcd_Out+0
;SmartFireAlarm.c,75 :: 		Lcd_Out(2,8,txt6);
	MOVLW      2
	MOVWF      FARG_Lcd_Out_row+0
	MOVLW      8
	MOVWF      FARG_Lcd_Out_column+0
	MOVLW      _txt6+0
	MOVWF      FARG_Lcd_Out_text+0
	CALL       _Lcd_Out+0
;SmartFireAlarm.c,76 :: 		}
L_interrupt9:
;SmartFireAlarm.c,77 :: 		}
L_interrupt8:
;SmartFireAlarm.c,78 :: 		if(flagH==1){
	MOVF       _flagH+0, 0
	XORLW      1
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt10
;SmartFireAlarm.c,79 :: 		Lcd_Cmd(_LCD_CLEAR);               // Clear display
	MOVLW      1
	MOVWF      FARG_Lcd_Cmd_out_char+0
	CALL       _Lcd_Cmd+0
;SmartFireAlarm.c,80 :: 		Lcd_Out(1,1,txt1);                 // Write text in first row
	MOVLW      1
	MOVWF      FARG_Lcd_Out_row+0
	MOVLW      1
	MOVWF      FARG_Lcd_Out_column+0
	MOVLW      _txt1+0
	MOVWF      FARG_Lcd_Out_text+0
	CALL       _Lcd_Out+0
;SmartFireAlarm.c,81 :: 		Lcd_Out(2,3,txt2);
	MOVLW      2
	MOVWF      FARG_Lcd_Out_row+0
	MOVLW      3
	MOVWF      FARG_Lcd_Out_column+0
	MOVLW      _txt2+0
	MOVWF      FARG_Lcd_Out_text+0
	CALL       _Lcd_Out+0
;SmartFireAlarm.c,83 :: 		flagH=0;
	CLRF       _flagH+0
;SmartFireAlarm.c,85 :: 		}
	GOTO       L_interrupt11
L_interrupt10:
;SmartFireAlarm.c,86 :: 		else if(flagL==1){
	MOVF       _flagL+0, 0
	XORLW      1
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt12
;SmartFireAlarm.c,87 :: 		Lcd_Cmd(_LCD_CLEAR);               // Clear display
	MOVLW      1
	MOVWF      FARG_Lcd_Cmd_out_char+0
	CALL       _Lcd_Cmd+0
;SmartFireAlarm.c,88 :: 		Lcd_Out(1,5,txt3);                 // Write text in first row
	MOVLW      1
	MOVWF      FARG_Lcd_Out_row+0
	MOVLW      5
	MOVWF      FARG_Lcd_Out_column+0
	MOVLW      _txt3+0
	MOVWF      FARG_Lcd_Out_text+0
	CALL       _Lcd_Out+0
;SmartFireAlarm.c,89 :: 		Lcd_Out(2,3,txt4);
	MOVLW      2
	MOVWF      FARG_Lcd_Out_row+0
	MOVLW      3
	MOVWF      FARG_Lcd_Out_column+0
	MOVLW      _txt4+0
	MOVWF      FARG_Lcd_Out_text+0
	CALL       _Lcd_Out+0
;SmartFireAlarm.c,90 :: 		flagL=0;
	CLRF       _flagL+0
;SmartFireAlarm.c,91 :: 		}
L_interrupt12:
L_interrupt11:
;SmartFireAlarm.c,92 :: 		DelayCntr1=0;
	CLRF       _DelayCntr1+0
	CLRF       _DelayCntr1+1
;SmartFireAlarm.c,93 :: 		}
L_interrupt7:
;SmartFireAlarm.c,94 :: 		if(DelayCntr==153){
	MOVLW      0
	XORWF      _DelayCntr+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__interrupt40
	MOVLW      153
	XORWF      _DelayCntr+0, 0
L__interrupt40:
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt13
;SmartFireAlarm.c,97 :: 		if(detected == 1){
	MOVLW      0
	XORWF      _detected+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__interrupt41
	MOVLW      1
	XORWF      _detected+0, 0
L__interrupt41:
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt14
;SmartFireAlarm.c,101 :: 		i=0;
	CLRF       _i+0
;SmartFireAlarm.c,102 :: 		while(msg1[i]!='.'){
L_interrupt15:
	MOVF       _i+0, 0
	ADDWF      _msg1+0, 0
	MOVWF      FSR
	MOVF       INDF+0, 0
	XORLW      46
	BTFSC      STATUS+0, 2
	GOTO       L_interrupt16
;SmartFireAlarm.c,103 :: 		USART_Tx(msg1[i]);
	MOVF       _i+0, 0
	ADDWF      _msg1+0, 0
	MOVWF      FSR
	MOVF       INDF+0, 0
	MOVWF      FARG_USART_Tx+0
	CALL       _USART_Tx+0
;SmartFireAlarm.c,104 :: 		i++;  }
	INCF       _i+0, 1
	GOTO       L_interrupt15
L_interrupt16:
;SmartFireAlarm.c,105 :: 		USART_Tx('\r');
	MOVLW      13
	MOVWF      FARG_USART_Tx+0
	CALL       _USART_Tx+0
;SmartFireAlarm.c,106 :: 		USART_Tx('\n');
	MOVLW      10
	MOVWF      FARG_USART_Tx+0
	CALL       _USART_Tx+0
;SmartFireAlarm.c,107 :: 		detected=0;
	CLRF       _detected+0
	CLRF       _detected+1
;SmartFireAlarm.c,109 :: 		while(k<1000){
L_interrupt17:
	MOVLW      128
	XORWF      _k+1, 0
	MOVWF      R0+0
	MOVLW      128
	XORLW      3
	SUBWF      R0+0, 0
	BTFSS      STATUS+0, 2
	GOTO       L__interrupt42
	MOVLW      232
	SUBWF      _k+0, 0
L__interrupt42:
	BTFSC      STATUS+0, 0
	GOTO       L_interrupt18
;SmartFireAlarm.c,110 :: 		k++;
	INCF       _k+0, 1
	BTFSC      STATUS+0, 2
	INCF       _k+1, 1
;SmartFireAlarm.c,111 :: 		}
	GOTO       L_interrupt17
L_interrupt18:
;SmartFireAlarm.c,112 :: 		k=0;
	CLRF       _k+0
	CLRF       _k+1
;SmartFireAlarm.c,115 :: 		}
L_interrupt14:
;SmartFireAlarm.c,116 :: 		DelayCntr=0;
	CLRF       _DelayCntr+0
	CLRF       _DelayCntr+1
;SmartFireAlarm.c,117 :: 		}
L_interrupt13:
;SmartFireAlarm.c,120 :: 		}
L_interrupt6:
;SmartFireAlarm.c,122 :: 		INTCON=INTCON & 0xFB ;
	MOVLW      251
	ANDWF      INTCON+0, 1
;SmartFireAlarm.c,123 :: 		}// clear the RCIF
L_end_interrupt:
L__interrupt38:
	MOVF       ___savePCLATH+0, 0
	MOVWF      PCLATH+0
	SWAPF      ___saveSTATUS+0, 0
	MOVWF      STATUS+0
	SWAPF      R15+0, 1
	SWAPF      R15+0, 0
	RETFIE
; end of _interrupt

_main:

;SmartFireAlarm.c,131 :: 		void main() {
;SmartFireAlarm.c,133 :: 		TRISB = 0x00;
	CLRF       TRISB+0
;SmartFireAlarm.c,134 :: 		ATD_init();
	CALL       _ATD_init+0
;SmartFireAlarm.c,135 :: 		PORTB=0x00;
	CLRF       PORTB+0
;SmartFireAlarm.c,136 :: 		TRISD = 0x00;
	CLRF       TRISD+0
;SmartFireAlarm.c,137 :: 		PORTD=0x00;
	CLRF       PORTD+0
;SmartFireAlarm.c,138 :: 		USART_init();
	CALL       _USART_init+0
;SmartFireAlarm.c,139 :: 		INTCON=INTCON|0x20;
	BSF        INTCON+0, 5
;SmartFireAlarm.c,140 :: 		OPTION_REG=0x87;
	MOVLW      135
	MOVWF      OPTION_REG+0
;SmartFireAlarm.c,141 :: 		TMR0=0;
	CLRF       TMR0+0
;SmartFireAlarm.c,143 :: 		Lcd_Init();                        // Initialize LCD
	CALL       _Lcd_Init+0
;SmartFireAlarm.c,147 :: 		while(1){
L_main19:
;SmartFireAlarm.c,149 :: 		if(flame<400){  //high
	MOVLW      1
	SUBWF      _flame+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__main44
	MOVLW      144
	SUBWF      _flame+0, 0
L__main44:
	BTFSC      STATUS+0, 0
	GOTO       L_main21
;SmartFireAlarm.c,150 :: 		PWM(10,100)  ;
	MOVLW      10
	MOVWF      FARG_PWM_p+0
	MOVLW      0
	MOVWF      FARG_PWM_p+1
	MOVLW      100
	MOVWF      FARG_PWM_d+0
	MOVLW      0
	MOVWF      FARG_PWM_d+1
	CALL       _PWM+0
;SmartFireAlarm.c,151 :: 		flagH=1;       // Cursor off
	MOVLW      1
	MOVWF      _flagH+0
;SmartFireAlarm.c,152 :: 		detected =1;
	MOVLW      1
	MOVWF      _detected+0
	MOVLW      0
	MOVWF      _detected+1
;SmartFireAlarm.c,153 :: 		}
	GOTO       L_main22
L_main21:
;SmartFireAlarm.c,154 :: 		else if(flame >= 451 && flame <= 701){   //meduim
	MOVLW      1
	SUBWF      _flame+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__main45
	MOVLW      195
	SUBWF      _flame+0, 0
L__main45:
	BTFSS      STATUS+0, 0
	GOTO       L_main25
	MOVF       _flame+1, 0
	SUBLW      2
	BTFSS      STATUS+0, 2
	GOTO       L__main46
	MOVF       _flame+0, 0
	SUBLW      189
L__main46:
	BTFSS      STATUS+0, 0
	GOTO       L_main25
L__main32:
;SmartFireAlarm.c,155 :: 		PWM(5,60);
	MOVLW      5
	MOVWF      FARG_PWM_p+0
	MOVLW      0
	MOVWF      FARG_PWM_p+1
	MOVLW      60
	MOVWF      FARG_PWM_d+0
	MOVLW      0
	MOVWF      FARG_PWM_d+1
	CALL       _PWM+0
;SmartFireAlarm.c,156 :: 		flagL=1;
	MOVLW      1
	MOVWF      _flagL+0
;SmartFireAlarm.c,157 :: 		detected = 1;
	MOVLW      1
	MOVWF      _detected+0
	MOVLW      0
	MOVWF      _detected+1
;SmartFireAlarm.c,158 :: 		}
	GOTO       L_main26
L_main25:
;SmartFireAlarm.c,159 :: 		else if (flame>=702){
	MOVLW      2
	SUBWF      _flame+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__main47
	MOVLW      190
	SUBWF      _flame+0, 0
L__main47:
	BTFSS      STATUS+0, 0
	GOTO       L_main27
;SmartFireAlarm.c,160 :: 		detected=0;
	CLRF       _detected+0
	CLRF       _detected+1
;SmartFireAlarm.c,161 :: 		flagH =0;
	CLRF       _flagH+0
;SmartFireAlarm.c,162 :: 		flagL =0;
	CLRF       _flagL+0
;SmartFireAlarm.c,164 :: 		}
L_main27:
L_main26:
L_main22:
;SmartFireAlarm.c,165 :: 		}
	GOTO       L_main19
;SmartFireAlarm.c,167 :: 		}
L_end_main:
	GOTO       $+0
; end of _main

_ATD_init:

;SmartFireAlarm.c,170 :: 		void ATD_init(void){
;SmartFireAlarm.c,171 :: 		ADCON0 = 0x41;// ATD ON, Don't GO, CHannel 1, Fosc/16
	MOVLW      65
	MOVWF      ADCON0+0
;SmartFireAlarm.c,172 :: 		ADCON1 = 0xCE;// All channels Analog, 500 KHz, right justified
	MOVLW      206
	MOVWF      ADCON1+0
;SmartFireAlarm.c,173 :: 		TRISA = 0x01;
	MOVLW      1
	MOVWF      TRISA+0
;SmartFireAlarm.c,175 :: 		}
L_end_ATD_init:
	RETURN
; end of _ATD_init

_ATD_read:

;SmartFireAlarm.c,176 :: 		unsigned int ATD_read(void){
;SmartFireAlarm.c,177 :: 		ADCON0 = ADCON0 | 0x04;
	BSF        ADCON0+0, 2
;SmartFireAlarm.c,178 :: 		while(ADCON0 & 0x04);
L_ATD_read28:
	BTFSS      ADCON0+0, 2
	GOTO       L_ATD_read29
	GOTO       L_ATD_read28
L_ATD_read29:
;SmartFireAlarm.c,180 :: 		return((ADRESH<<8)|ADRESL);
	MOVF       ADRESH+0, 0
	MOVWF      R0+1
	CLRF       R0+0
	MOVF       ADRESL+0, 0
	IORWF      R0+0, 1
	MOVLW      0
	IORWF      R0+1, 1
;SmartFireAlarm.c,181 :: 		}
L_end_ATD_read:
	RETURN
; end of _ATD_read

_USART_init:

;SmartFireAlarm.c,183 :: 		void USART_init(void){
;SmartFireAlarm.c,184 :: 		SPBRG = 12; // 9600 bps
	MOVLW      12
	MOVWF      SPBRG+0
;SmartFireAlarm.c,185 :: 		TXSTA = 0x20;// 8-bit, Tx Enable, Asysnc, Low Speed
	MOVLW      32
	MOVWF      TXSTA+0
;SmartFireAlarm.c,186 :: 		RCSTA = 0x90;// SP Enable, 8-bi, cont. Rx
	MOVLW      144
	MOVWF      RCSTA+0
;SmartFireAlarm.c,187 :: 		TRISC = 0x80;
	MOVLW      128
	MOVWF      TRISC+0
;SmartFireAlarm.c,188 :: 		PIE1 = PIE1 | 0x20;// RCIE
	BSF        PIE1+0, 5
;SmartFireAlarm.c,189 :: 		INTCON = 0xC0;}//GIE, PEIE
	MOVLW      192
	MOVWF      INTCON+0
L_end_USART_init:
	RETURN
; end of _USART_init

_USART_Tx:

;SmartFireAlarm.c,190 :: 		void USART_Tx(unsigned char myChar){
;SmartFireAlarm.c,191 :: 		while(!(TXSTA & 0x02));
L_USART_Tx30:
	BTFSC      TXSTA+0, 1
	GOTO       L_USART_Tx31
	GOTO       L_USART_Tx30
L_USART_Tx31:
;SmartFireAlarm.c,192 :: 		TXREG = myChar;}
	MOVF       FARG_USART_Tx_myChar+0, 0
	MOVWF      TXREG+0
L_end_USART_Tx:
	RETURN
; end of _USART_Tx
