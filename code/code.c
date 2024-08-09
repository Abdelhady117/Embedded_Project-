/*******************************************

 * Project_Name: Traffic_Light_Controller.c

 * Description : To design and implement a traffic light controller system using a PIC16F877A microcontroller that operates in two modes: automatic and manual.

 * Author      : Abdelhady Muhammad

 * B.N         : 36

 ******************************************/

// Define switches pin configurations

#define AUTO_MANUAL_SWITCH PORTB.RB0

#define MANUAL_SWITCH PORTB.RB1

// Define west traffic pin configurations

#define WEST_RED_LIGHT PORTD.RD0

#define WEST_YELLOW_LIGHT PORTD.RD1

#define WEST_GREEN_LIGHT PORTD.RD2

// Define south traffic pin configurations

#define SOUTH_RED_LIGHT PORTD.RD3

#define SOUTH_YELLOW_LIGHT PORTD.RD4

#define SOUTH_GREEN_LIGHT PORTD.RD5

// Define west Time Constants in ms

#define WEST_RED_TIME 15

#define WEST_YELLOW_TIME 3

#define WEST_GREEN_TIME 20

// Define south Time Constants in ms

#define SOUTH_RED_TIME 23

#define SOUTH_YELLOW_TIME 3

#define SOUTH_GREEN_TIME 12

// Define displays enables

#define UNITS_ENABLE PORTB.RB2
#define TENS_ENABLE PORTB.RB3

unsigned char current_mode = 0;

unsigned char i;

/*** INTERRUPT Configurations setup ***/

void configureINT0(){

        // Enable global interrupts

    INTCON.GIE = 1;

    // RB0/INT External interrupt enable

    INTCON.INTE = 1;

    // clear INT0 interrupt flag

    INTCON.INTF = 0;

    // Interrupt on rising edge

    OPTION_REG.INTEDG = 1;

}

/*** I/O port configurations setup ***/

void initialize() {

    //set RB0 and RB1 as input for switches

    TRISB = 0x03;

    //set PORTC as output for SOUTH 7-Segment displays

    TRISC = 0x00;

    //set PORTD as output for LEDs

    TRISD = 0x00;

    //Initialize PORTC with all SOUTH 7-Segment displays off

    PORTC = 0x00;

    //initialize PORTD with all LEDs off

    PORTD = 0x00;

    // initialize enables
    UNITS_ENABLE = 1;
    TENS_ENABLE = 1;
}

/*** Auto/Manual switch interrupt ***/

void interrupt() {

    /*** check INT0 interrupt ***/

    if (INTCON.INTF) {
          Delay_ms(30)  ;
        // clear INT0 interrupt flag

        INTCON.INTF = 0;

        // Toggle between AUTOMATIC and MANUAL modes

        current_mode = (current_mode == 0?1 :0);

    }

}

void display(unsigned char seconds) {

    unsigned char tens = seconds / 10;

    unsigned char units = seconds % 10;

    // display on the 7-Segment
    if (seconds == 0 ){
       UNITS_ENABLE = 0;
       TENS_ENABLE = 0;
    } else {
       UNITS_ENABLE = 1;
       TENS_ENABLE = 1;
    }
    PORTC = (units & 0x0F) | ((tens & 0x0F) << 4);

}

int main() {

    initialize();

    configureINT0();

        while (1) {

                /*** AUTOMATIC MODE ***/

                if(!current_mode){

                        WEST_RED_LIGHT = 1;

                        for (i = WEST_RED_TIME; i > 0 && !current_mode; i--) {

                                SOUTH_GREEN_LIGHT = (i > 3 ? 1 : 0);

                                SOUTH_YELLOW_LIGHT = (i <= 3 ? 1 : 0);

                                display(i);

                                Delay_ms(1000);

                        }

                        WEST_RED_LIGHT = 0;

                        SOUTH_YELLOW_LIGHT = 0;

                        SOUTH_RED_LIGHT = 1;

                        for (i = SOUTH_RED_TIME; i > 0 && !current_mode; i--) {

                                WEST_GREEN_LIGHT = (i > 3 ? 1 : 0);

                                WEST_YELLOW_LIGHT = (i <= 3 ? 1 : 0);

                                display(i);

                                Delay_ms(1000);

                        }

                        SOUTH_RED_LIGHT = 0;

                        WEST_YELLOW_LIGHT = 0;

                }

                /*** MANUAL MODE ***/

                else {

                        if (WEST_RED_LIGHT) {

                                for(i = SOUTH_YELLOW_TIME; i > 0 && current_mode; i--) {

                                        SOUTH_YELLOW_LIGHT = 1;

                                        SOUTH_GREEN_LIGHT = 0;

                                        display(i);

                                        Delay_ms(1000);

                                }

                                while(current_mode && MANUAL_SWITCH ==1) {

                                        WEST_RED_LIGHT = 0;

                                        WEST_YELLOW_LIGHT = 0;

                                        WEST_GREEN_LIGHT = 1;

                                        SOUTH_RED_LIGHT = 1;

                                        SOUTH_YELLOW_LIGHT = 0;

                                        SOUTH_GREEN_LIGHT = 0;

                                        display(0);

                                        Delay_ms(50);

                                }

                        } else {

                                for(i = WEST_YELLOW_TIME; i > 0 && current_mode; i--) {

                                        WEST_YELLOW_LIGHT = 1;

                                        WEST_GREEN_LIGHT = 0;

                                        display(i);

                                        Delay_ms(1000);



                                }


                                while(current_mode && MANUAL_SWITCH == 1) {

                                        WEST_RED_LIGHT = 1;

                                        WEST_YELLOW_LIGHT = 0;

                                        WEST_GREEN_LIGHT = 0;

                                        SOUTH_RED_LIGHT = 0;

                                        SOUTH_YELLOW_LIGHT = 0;

                                        SOUTH_GREEN_LIGHT = 1;

                                        display(0);

                                        Delay_ms(50);

                                }

                        }

                }

        }

}