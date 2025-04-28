            ORG     0000H
            LJMP    MAIN

INIT_PORTS:
            MOV     P0,#0FFH
            MOV     P1,#0FFH
            MOV     P2,#0FFH
            MOV     P3,#0FFH
            RET

INIT_LCD:
            MOV     P2,#038H
            ACALL   COMMAND_DELAY
            MOV     P2,#00CH
            ACALL   COMMAND_DELAY
            MOV     P2,#006H
            ACALL   COMMAND_DELAY
            MOV     P2,#001H
            ACALL   COMMAND_DELAY
            RET

COMMAND_DELAY:
            MOV     R2,#0FFH
DR1:        NOP
            DJNZ    R2,DR1
            RET

CLEAR_LCD:
            CLR     P3.4
            CLR     P3.5
            SETB    P3.6
            MOV     P2,#01H
            ACALL   COMMAND_DELAY
            CLR     P3.6
            RET

DISPLAY_CHAR_LCD:
            SETB    P3.4
            CLR     P3.5
            SETB    P3.6
            MOV     P2,A
            ACALL   COMMAND_DELAY
            CLR     P3.6
            RET

DISPLAY_STRING_LCD:
            MOV     A,#00H
DS_LOOP:    MOVC    A,@A+DPTR
            JZ      DS_DONE
            ACALL   DISPLAY_CHAR_LCD
            INC     DPTR
            SJMP    DS_LOOP
DS_DONE:    RET

ROTATE_MOTOR:
            SETB    P3.0
            ACALL   MOTOR_DELAY
            CLR     P3.0
            SETB    P3.1
            ACALL   MOTOR_DELAY
            CLR     P3.1
            RET

MOTOR_DELAY:
            MOV     R3,#0FFH
DL1:        MOV     R2,#0FFH
DL2:        ACALL   COMMAND_DELAY
            DJNZ    R2,DL2
            DJNZ    R3,DL1
            RET

GET_KEYPAD_VALUE:
            MOV     P1,#0FFH
            CLR     P1.0
            MOV     A,P1
            ANL     A,#F0H
            CJNE    A,#F0H,DR1
            SETB    P1.0
            CLR     P1.1
            MOV     A,P1
            ANL     A,#F0H
            CJNE    A,#F0H,DR2
            SETB    P1.1
            CLR     P1.2
            MOV     A,P1
            ANL     A,#F0H
            CJNE    A,#F0H,DR3
            SETB    P1.2
            CLR     P1.3
            MOV     A,P1
            ANL     A,#F0H
            CJNE    A,#F0H,DR4
            SETB    P1.3
            MOV     A,#00H
            RET
DR1:        JNB     P1.4,KP1
            JNB     P1.5,KP2
            JNB     P1.6,KP3
            JNB     P1.7,KPA
            SETB    P1.0
            RET
KP1:        MOV     A,#31H
            SETB    P1.0
            RET
KP2:        MOV     A,#32H
            SETB    P1.0
            RET
KP3:        MOV     A,#33H
            SETB    P1.0
            RET
KPA:        MOV     A,#41H
            SETB    P1.0
            RET
DR2:        JNB     P1.4,KP4
            JNB     P1.5,KP5
            JNB     P1.6,KP6
            JNB     P1.7,KPB
            SETB    P1.1
            RET
KP4:        MOV     A,#34H
            SETB    P1.1
            RET
KP5:        MOV     A,#35H
            SETB    P1.1
            RET
KP6:        MOV     A,#36H
            SETB    P1.1
            RET
KPB:        MOV     A,#42H
            SETB    P1.1
            RET
DR3:        JNB     P1.4,KP7
            JNB     P1.5,KP8
            JNB     P1.6,KP9
            JNB     P1.7,KPC
            SETB    P1.2
            RET
KP7:        MOV     A,#37H
            SETB    P1.2
            RET
KP8:        MOV     A,#38H
            SETB    P1.2
            RET
KP9:        MOV     A,#39H
            SETB    P1.2
            RET
KPC:        MOV     A,#43H
            SETB    P1.2
            RET
DR4:        JNB     P1.4,KPSTAR
            JNB     P1.5,KP0
            JNB     P1.6,KPHASH
            JNB     P1.7,KPD
            SETB    P1.3
            RET
KPSTAR:     MOV     A,#2AH
            SETB    P1.3
            RET
KP0:        MOV     A,#30H
            SETB    P1.3
            RET
KPHASH:     MOV     A,#23H
            SETB    P1.3
            RET
KPD:        MOV     A,#44H
            SETB    P1.3
            RET

GET_PASSWORD:
            ACALL   GET_KEYPAD_VALUE
            MOV     R0,A
            ACALL   GET_KEYPAD_VALUE
            MOV     R1,A
            ACALL   GET_KEYPAD_VALUE
            MOV     R2,A
            ACALL   GET_KEYPAD_VALUE
            MOV     R3,A
            RET

CHECK_PASSWORD:
            MOV     A,R0
            CJNE    A,#31H,WRONG_PASSWORD
            MOV     A,R1
            CJNE    A,#31H,WRONG_PASSWORD
            MOV     A,R2
            CJNE    A,#31H,WRONG_PASSWORD
            MOV     A,R3
            CJNE    A,#30H,WRONG_PASSWORD
            RET
WRONG_PASSWORD:
            RET

MAIN:
            CALL    INIT_PORTS
            CALL    INIT_LCD
PASSWORD_ENTRY_LOOP:
            CALL    GET_PASSWORD
            CALL    CHECK_PASSWORD
            JZ      PASSWORD_CORRECT
            SJMP    PASSWORD_INCORRECT
PASSWORD_CORRECT:
            CALL    CLEAR_LCD
            MOV     DPTR,#DOOR_OPEN_MSG
            CALL    DISPLAY_STRING_LCD
            CALL    ROTATE_MOTOR
            SJMP    MAIN
PASSWORD_INCORRECT:
            CALL    CLEAR_LCD
            MOV     DPTR,#WRONG_MSG
            CALL    DISPLAY_STRING_LCD
            CALL    MOTOR_DELAY
            SJMP    PASSWORD_ENTRY_LOOP

DOOR_OPEN_MSG: DB      'Door Opening',0
WRONG_MSG:     DB      'Wrong Password',0

            END
