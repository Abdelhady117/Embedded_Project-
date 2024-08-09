#line 1 "D:/Summer_Training_SFE/Projects/TrafficLight/code/code.c"
#line 33 "D:/Summer_Training_SFE/Projects/TrafficLight/code/code.c"
unsigned char current_mode = 0;

unsigned char i;


void configureINT0() {

 INTCON.GIE = 1;

 INTCON.INTE = 1;

 INTCON.INTF = 0;

 OPTION_REG.INTEDG = 1;
}


void initialize() {

 TRISB = 0x03;

 TRISC = 0x00;

 TRISD = 0x00;

 PORTC = 0x00;

 PORTD = 0x00;

  PORTB.RB2  = 1;
  PORTB.RB3  = 1;
}


void interrupt() {

 if (INTCON.INTF) {

 Delay_ms(30);

 INTCON.INTF = 0;

 current_mode = (current_mode == 0?1: 0);
 }
}


void display(unsigned char seconds) {
 if (seconds == 0) {
  PORTB.RB2  = 0;
  PORTB.RB3  = 0;
 } else {
  PORTB.RB2  = 1;
  PORTB.RB3  = 1;
 }
 unsigned char tens = seconds / 10;
 unsigned char units = seconds % 10;

 PORTC = (units & 0x0F) | ((tens & 0x0F) << 4);
}


void automatic_mode() {
  PORTD.RD0  = 1;
 for (i =  15 ; i > 0 && !current_mode; i--) {
  PORTD.RD5  = (i > 3 ? 1: 0);
  PORTD.RD4  = (i <= 3 ? 1: 0);
 display(i);
 Delay_ms(1000);
 }
  PORTD.RD0  = 0;
  PORTD.RD4  = 0;
  PORTD.RD3  = 1;
 for (i =  23 ; i > 0 && !current_mode; i--) {
  PORTD.RD2  = (i > 3 ? 1: 0);
  PORTD.RD1  = (i <= 3 ? 1: 0);
 display(i);
 Delay_ms(1000);
 }
  PORTD.RD3  = 0;
  PORTD.RD1  = 0;
}


void manual_mode() {
 if ( PORTD.RD0 ) {
 for(i =  3 ; i > 0 && current_mode; i--) {
  PORTD.RD4  = 1;
  PORTD.RD5  = 0;
 display(i);
 Delay_ms(1000);
 }

 while(current_mode &&  PORTB.RB1  == 1) {
  PORTD.RD0  = 0;
  PORTD.RD1  = 0;
  PORTD.RD2  = 1;
  PORTD.RD3  = 1;
  PORTD.RD4  = 0;
  PORTD.RD5  = 0;
 display(0);
 Delay_ms(50);
 }
 } else {
 for(i =  3 ; i > 0 && current_mode; i--) {
  PORTD.RD1  = 1;
  PORTD.RD2  = 0;
 display(i);
 Delay_ms(1000);
 }

 while(current_mode &&  PORTB.RB1  == 1) {
  PORTD.RD0  = 1;
  PORTD.RD1  = 0;
  PORTD.RD2  = 0;
  PORTD.RD3  = 0;
  PORTD.RD4  = 0;
  PORTD.RD5  = 1;
 display(0);
 Delay_ms(50);
 }
 }
}


int main() {
 initialize();
 configureINT0();
 while (1) {

 if(!current_mode) {
 automatic_mode();
 }
 else {
 manual_mode();
 }
 }
}
