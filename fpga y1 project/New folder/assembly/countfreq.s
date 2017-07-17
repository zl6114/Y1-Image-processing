; Standard definitions of Mode bits and Interrupt (I & F) flags in PSRs

Mode_USR        EQU     0x10
Mode_FIQ        EQU     0x11
Mode_IRQ        EQU     0x12
Mode_SVC        EQU     0x13
Mode_ABT        EQU     0x17
Mode_UND        EQU     0x1B
Mode_SYS        EQU     0x1F

I_Bit           EQU     0x80            ; when I bit is set, IRQ is disabled
F_Bit           EQU     0x40            ; when F bit is set, FIQ is disabled


;// <h> Stack Configuration (Stack Sizes in Bytes)
;//   <o0> Undefined Mode      <0x0-0xFFFFFFFF:8>
;//   <o1> Supervisor Mode     <0x0-0xFFFFFFFF:8>
;//   <o2> Abort Mode          <0x0-0xFFFFFFFF:8>
;//   <o3> Fast Interrupt Mode <0x0-0xFFFFFFFF:8>
;//   <o4> Interrupt Mode      <0x0-0xFFFFFFFF:8>
;//   <o5> User/System Mode    <0x0-0xFFFFFFFF:8>
;// </h>

UND_Stack_Size  EQU     0x00000000
SVC_Stack_Size  EQU     0x00000080
ABT_Stack_Size  EQU     0x00000000
FIQ_Stack_Size  EQU     0x00000000
IRQ_Stack_Size  EQU     0x00000080
USR_Stack_Size  EQU     0x00000000

ISR_Stack_Size  EQU     (UND_Stack_Size + SVC_Stack_Size + ABT_Stack_Size + \
                         FIQ_Stack_Size + IRQ_Stack_Size)

        		AREA     RESET, CODE
				ENTRY
;  Dummy Handlers are implemented as infinite loops which can be modified.

Vectors         LDR     PC, Reset_Addr         
                LDR     PC, Undef_Addr
                LDR     PC, SWI_Addr
                LDR     PC, PAbt_Addr
                LDR     PC, DAbt_Addr
                NOP                            ; Reserved Vector 
                LDR     PC, IRQ_Addr
;               LDR     PC, [PC, #-0x0FF0]     ; Vector from VicVectAddr
                LDR     PC, FIQ_Addr

ACBASE			DCD		P0COUNT
SCONTR			DCD		SIMCONTROL
DEBUGIO         DCD     DEBUG_CNT
Reset_Addr      DCD     Reset_Handler
Undef_Addr      DCD     Undef_Handler
SWI_Addr        DCD     SWI_Handler
PAbt_Addr       DCD     PAbt_Handler
DAbt_Addr       DCD     DAbt_Handler
                DCD     0                      ; Reserved Address 
FIQ_Addr        DCD     FIQ_Handler

Undef_Handler   B       Undef_Handler
SWI_Handler     B       SWI_Handler
PAbt_Handler    B       PAbt_Handler
DAbt_Handler    B       DAbt_Handler
FIQ_Handler     B       FIQ_Handler


				AREA 	ARMuser, CODE,READONLY

IRQ_Addr        DCD     ISR_FUNC1
EINT2			EQU 	16
Addr_VicIntEn	DCD		0xFFFFF010	 	; set to (1<<EINT0)
Addr_EXTMODE	DCD 	0xE01FC148   	; set to 1
Addr_PINSEL0	DCD		0xE002C000		; set to 2_1100
Addr_EXTINT		DCD		0xE01FC140

;  addresses of two registers that allow faster input

Addr_IOPIN		DCD		0xE0028000


; Initialise the Interrupt System
;  ...
ISR_FUNC1		STMED	R13!, {R0,R1}
				MOV 	R0, #(1 << 2) 	   ; bit 2 of EXTINT
				LDR 	R1,	Addr_EXTINT	   
				STR		R0, [R1]		   ; EINT2 reset interrupt
				LDMED	R13!, {R0,R1}
				B 		ISR_FUNC

Reset_Handler
; PORT0.1 1->0 triggers EINT0 IRQ interrupt
				MOV R0, #(1 << EINT2)
				LDR R1, Addr_VicIntEn
				STR R0, [R1]
				MOV R0, #(1 << 30)
				LDR R1, Addr_PINSEL0
				STR R0, [R1]
				MOV R0, #(1 << 2)
				LDR R1, Addr_EXTMODE
				STR R0, [R1]

;  Setup Stack for each mode

                LDR     R0, =Stack_Top

;  Enter Undefined Instruction Mode and set its Stack Pointer
                MSR     CPSR_c, #Mode_UND:OR:I_Bit:OR:F_Bit
                MOV     SP, R0
                SUB     R0, R0, #UND_Stack_Size

;  Enter Abort Mode and set its Stack Pointer
                MSR     CPSR_c, #Mode_ABT:OR:I_Bit:OR:F_Bit
                MOV     SP, R0
                SUB     R0, R0, #ABT_Stack_Size

;  Enter FIQ Mode and set its Stack Pointer
                MSR     CPSR_c, #Mode_FIQ:OR:I_Bit:OR:F_Bit
                MOV     SP, R0
                SUB     R0, R0, #FIQ_Stack_Size

;  Enter IRQ Mode and set its Stack Pointer
                MSR     CPSR_c, #Mode_IRQ:OR:I_Bit:OR:F_Bit
                MOV     SP, R0
                SUB     R0, R0, #IRQ_Stack_Size

;  Enter Supervisor Mode and set its Stack Pointer
                MSR     CPSR_c, #Mode_SVC:OR:F_Bit
                MOV     SP, R0
                SUB     R0, R0, #SVC_Stack_Size
				B 		START
;----------------------------DO NOT CHANGE ABOVE THIS COMMENT--------------------------------
;--------------------------------------------------------------------------------------------
;--------------------------------------------------------------------------------------------
;******************************************************************************************
; Author: Zihan Liu
; Purpose: Code to measure frequencies for 4 different Pins.
; Date: JAN 2015
; Code overview:
; This code use LDR/STR to indicate some specific number, then use BIC operation to detect 
; either there is a change between 0 to 1 or not.
; The minimun number for all the bits input period in cycles is 30 under 200000 SIM_TIME
;******************************************************************************************

;The code will count the numbers of period for 4 pins. 

;initialization for LOOP

FILTER		DCD		0x02040081		   ;parameter with bit 1 in the locations of 4 different pins

Addr_P0COUNT	DCD		P0COUNT
Addr_P1COUNT	DCD		P1COUNT
Addr_P2COUNT	DCD		P2COUNT
Addr_P3COUNT	DCD		P3COUNT
	
P1CLEAR			DCD		0XFFFC007F	   ;parameters needed for the numbers that 
P2CLEAR			DCD		0XFE03FFFF	   ;outside the range of (0~256) and a notation 
P3CLEAR 		DCD		0X01FFFFFF


START		LDR R9,			P1CLEAR	   ;load the number from P1CLEAR to R9
			LDR R10, 		P2CLEAR	   ;load the number from P2CLEAR to R10
			LDR R11,		P3CLEAR	   ;load the number from P3CLEAR to R11

			LDR R13, 		Addr_IOPIN	;load the number from Addr_IOPIN

			LDR R8, 		FILTER		;load the number from FILTER to both R8 and R1
			LDR R1, 		FILTER
	
			MOV R2, #0					;clear the register if there was some number or op-code 
			MOV R3, #0					;inside the registers 
			MOV R4, #0
			MOV R5, #0
			MOV R6, #0
			MOV R7, #0
			MOV R12,#0

; main couting loop loops forever, interrupted at end of simulation
LOOP		LDR R0, [R13]		 		;load R0 with the number inside of Mem32[R13]
			AND R0, R0, R8 				;claer the bits that we dont need use an AND operation between R0 and R8 then store the result back to R0 
			BIC R14, R0, R1				;check if there is a change between 0 and 1 for PIN1,PIN2,PIN3 and PIN4
			ADD	R2,	R2, R14				;sum up the bits that change from 0 to 1
			MOV R1, R0					;move R1 to R0 to become the Prev_Pin
			
			BIC R3, R2, #0XFFFFFFF0	 	;clear bits 4~31, leftover the counted period for PIN0 in R2 and move the number to R3
			ADD R5, R5, R3			 	;add the number in R3 to R5(Total Period for PIN0)
			AND R2, R2, #0XFFFFFF80		;reset bits 0~6(Pin0) in R2 to 0

			LDR R0, [R13]		 	 	;load R0 with the number inside of Mem32[R13]
			AND R0, R0, R8 			 	;claer the bits that we dont need use an AND operation 
			BIC R14, R0, R1				;check if there is a change between 0 and 1 for PIN0,PIN1,PIN2 and PIN3
			ADD	R2,	R2, R14			 	;sum up the bits that change from 0 to 1
			MOV R1, R0				    ;move R1 to R0 to become the Prev_Pin
			
			MOV R3, R2, LSR#7		 	;Logic shift right 7 bits to let the bits counted for PIN1 to the LSB
			BIC R3, R3, #0XFFFFFFF0	 	;clear bits 4~31, leftover the counted period for PIN1 in R3 and move the number to R3
			ADD R6, R6, R3				;add the number in R3 to R5(Total Period for PIN1)
			AND R2, R2, R9				;reset bits 7~17(Pin1) in R2 to 0

			LDR R0, [R13]		 	 	;load R0 with the number inside of Mem32[R13]
			AND R0, R0, R8 			 	;claer the bits that we dont need use an AND operation 
			BIC R14, R0, R1				;check if there is a change between 0 and 1 for PIN1,PIN2,PIN3 and PIN4
			ADD	R2,	R2, R14			 	;sum up the bits that change from 0 to 1
			MOV R1, R0				 	;move R1 to R0 to become the Prev_Pin

			MOV R3, R2, LSR#18			;Logic shift right 18 bits to let the bits counted for PIN2 to the LSB
			BIC R3, R3, #0XFFFFFFF0		;clear bits 4~31, leftover the counted period for PIN2 in R3 and move the number to R3
			ADD R7, R7, R3				;add the number in R3 to R7(Total Period for PIN2)
			AND R2, R2, R10				;reset bits 18~24(PIN2) in R2 to 0

			LDR R0, [R13]		 		 ;load R0 with the number inside of Mem32[R13]
			AND R0, R0, R8 				 ;claer the bits that we dont need use an AND operation 
			BIC R14, R0, R1				 ;check if there is a change between 0 and 1 for PIN1,PIN2,PIN3 and PIN4
			ADD	R2,	R2, R14				 ;sum up the bits that change from 0 to 1
			MOV R1, R0					 ;move R1 to R0 to become the Prev_Pin

			MOV R3, R2, LSR#25			 ;Logic shift right 25 bits to let the bits counted for PIN3 to the LSB
			BIC R3, R3, #0XFFFFFFF0		 ;clear bits 4~31, leftover the counted period for PIN3 in R3 and move the number to R3
			ADD R4, R4, R3				 ;add the number in R3 to R4(Total Period for PIN3)
			AND R2, R2, R11				 ;reset bits 25~31(PIN2) in R2 to 0
			

			CMP R12, #0					 ;Compare R12 and 0
			BEQ LOOP					 ;if equal loop

			B 	LOOP2					 ; branches to LOOP2 



ISR_FUNC		MOV  R12, #1			 ;Move R12 to 1
				SUBS pc, R14,#4			 ;When interrput happened this code move the ARM back to normal
			
			
		
LOOP2			
				LDR R0, Addr_P0COUNT	 ;load R0 with the memoery location P0COUNT
				STR R5, [R0]			 ;store R5 in mem32[R0]

			
				LDR R1,  Addr_P1COUNT	 ;load R1 with the memoery location P1COUNT
				STR R6, [R1]			 ;store R6 in mem32[R1]

			
				LDR R2, Addr_P2COUNT	 ;load R2 with the memoery location P2COUNT
				STR R7, [R2]			 ;store R7 in mem32[R2]

			
				LDR R3, Addr_P3COUNT	 ;load R3 with the memoery location P3COUNT
				STR R4, [R3]			 ;store R4 in mem32[R3]
				B 		LOOP_END		 ;Branch to the LOOP_END to end the program
 		
;--------------------------------------------------------------------------------------------
; PARAMETERS TO CONTROL SIMULATION, VALUES MAY BE CHANGED TO IMPLEMENT DIFFERENT TESTS
;--------------------------------------------------------------------------------------------
SIMCONTROL
SIM_TIME 		DCD  	200000	  ; length of simulation in cycles (100MHz clock)
P0_PERIOD		DCD   	30        ; bit 0 input period in cycles
P1_PERIOD		DCD   	31		  ; bit 7 input period in cycles
P2_PERIOD		DCD  	32		  ; bit 18 input period	in cycles
P3_PERIOD		DCD		33		  ; bit 25 input period	in cycles
;---------------------DO NOT CHANGE AFTER THIS COMMENT---------------------------------------
;--------------------------------------------------------------------------------------------
;--------------------------------------------------------------------------------------------
LOOP_END		MOV R0, #0x7f00
				LDR R0, [R0] 	; read memory location 7f00 to stop simulation
STOP			B 	STOP
;-----------------------------------------------------------------------------
 				AREA	DATA, READWRITE
SIM_OUT
P0COUNT			DCD		0
P1COUNT			DCD		0
P2COUNT			DCD		0
P3COUNT			DCD		0
;------------------------------------------------------------------------------			
                AREA    STACK, NOINIT, READWRITE, ALIGN=3
DEBUG_CNT       SPACE    16
Stack_Mem       SPACE   USR_Stack_Size
__initial_sp    SPACE   ISR_Stack_Size

Stack_Top


        		END                     ; Mark end of file

