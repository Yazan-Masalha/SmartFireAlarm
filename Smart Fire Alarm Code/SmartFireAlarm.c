unsigned int flame=0;
unsigned int period, duty;
unsigned int speed;
unsigned char myRxBuffer,i;
unsigned char flagH=0, flagL=0;
int k=0;
unsigned char myRxFlag=0;
unsigned char *msg1="A fire is detected.";
unsigned int detected = 0;
unsigned int DelayCntr=0;
unsigned int DelayCntr1=0;
//Lcd code
sbit LCD_RS at RB4_bit;
sbit LCD_EN at RB5_bit;
sbit LCD_D4 at RB0_bit;
sbit LCD_D5 at RB1_bit;
sbit LCD_D6 at RB2_bit;
sbit LCD_D7 at RB3_bit;

sbit LCD_RS_Direction at TRISB4_bit;
sbit LCD_EN_Direction at TRISB5_bit;
sbit LCD_D4_Direction at TRISB0_bit;
sbit LCD_D5_Direction at TRISB1_bit;
sbit LCD_D6_Direction at TRISB2_bit;
sbit LCD_D7_Direction at TRISB3_bit;
// End LCD module connections

char txt1[] = "THERE IS A FIRE";
char txt2[] = "PLEASE LEAVE ";
char txt3[] = "WARNING: ";
char txt4[] = "BE CAREFUL";
char txt5[] = "SMART FIRE ALARM";
char txt6[] = ":)";


void ATD_init(void);
 void msDelay(unsigned int mscnt);
unsigned int ATD_read();
   void msDelay(unsigned int mscnt) {
 unsigned int ms;
 unsigned int cnt;
 for (ms = 0; ms < mscnt; ms++) {
 for (cnt = 0; cnt < 155; cnt++);
 }
}


void PWM(unsigned int p, unsigned int d){
// period in milliseconds, d 1-100 %
//This will have the PWM Signal Out on PORTB1-7, so do the necessary initializations in the main.
period=p;//milliseconds
duty=(d*p)/100;
PORTD= 0x05;//High
msDelay(duty);
PORTD=0x00;//Low
msDelay(period-duty);
}
void USART_init(void);
void USART_Tx(unsigned char);


void interrupt(){

myRxBuffer = RCREG;
myRxFlag = 1;
   if(INTCON&0x04){
      flame = ATD_read();
    DelayCntr++;
    DelayCntr1++;
    if (DelayCntr1==30){
      if(flagH == 0){
      if(flagL==0){
      Lcd_Cmd(_LCD_CLEAR);               // Clear display
        Lcd_Out(1,1,txt5);                 // Write text in first row
        Lcd_Out(2,8,txt6);
      }
      }
      if(flagH==1){
        Lcd_Cmd(_LCD_CLEAR);               // Clear display
        Lcd_Out(1,1,txt1);                 // Write text in first row
        Lcd_Out(2,3,txt2);

      flagH=0;

      }
      else if(flagL==1){
      Lcd_Cmd(_LCD_CLEAR);               // Clear display
      Lcd_Out(1,5,txt3);                 // Write text in first row
      Lcd_Out(2,3,txt4);
         flagL=0;
      }
      DelayCntr1=0;
      }
    if(DelayCntr==153){


    if(detected == 1){
     //myRxBuffer = RCREG;
     //myRxFlag = 1;

     i=0;
     while(msg1[i]!='.'){
     USART_Tx(msg1[i]);
     i++;  }
     USART_Tx('\r');
     USART_Tx('\n');
     detected=0;

  while(k<1000){
     k++;
  }
  k=0;
/* Lcd_Cmd(_LCD_CLEAR);               // Clear display
Lcd_Cmd(_LCD_CURSOR_OFF);*/
     }
          DelayCntr=0;
    }


 }

   INTCON=INTCON & 0xFB ;
}// clear the RCIF







void main() {

  TRISB = 0x00;
  ATD_init();
  PORTB=0x00;
  TRISD = 0x00;
  PORTD=0x00;
  USART_init();
  INTCON=INTCON|0x20;
  OPTION_REG=0x87;
  TMR0=0;

    Lcd_Init();                        // Initialize LCD



while(1){

if(flame<400){  //high
PWM(10,100)  ;
flagH=1;       // Cursor off
detected =1;
}
else if(flame >= 451 && flame <= 701){   //meduim
PWM(5,60);
 flagL=1;
detected = 1;
}
 else if (flame>=702){
  detected=0;
  flagH =0;
  flagL =0;

 }
}

}


void ATD_init(void){
 ADCON0 = 0x41;// ATD ON, Don't GO, CHannel 1, Fosc/16
 ADCON1 = 0xCE;// All channels Analog, 500 KHz, right justified
 TRISA = 0x01;

}
unsigned int ATD_read(void){
 ADCON0 = ADCON0 | 0x04;
 while(ADCON0 & 0x04);

 return((ADRESH<<8)|ADRESL);
}

 void USART_init(void){
   SPBRG = 12; // 9600 bps
   TXSTA = 0x20;// 8-bit, Tx Enable, Asysnc, Low Speed
   RCSTA = 0x90;// SP Enable, 8-bi, cont. Rx
   TRISC = 0x80;
   PIE1 = PIE1 | 0x20;// RCIE
   INTCON = 0xC0;}//GIE, PEIE
void USART_Tx(unsigned char myChar){
     while(!(TXSTA & 0x02));
     TXREG = myChar;}