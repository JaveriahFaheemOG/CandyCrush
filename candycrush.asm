;javeriah faheem 22i7421
;ayesha areej 22i1711
;sabreena azhar 22i1751

OUTP MACRO X
	MOV DL,X
	MOV AH,02H
	INT 21H
ENDM
.MODEL SMALL
.STACK 100h

;===DATA DECLARATION===
.DATA
 game_name db ">>>>>>CANDY CRUSH SAGA<<<<<<$"  ; Define a string variable
 welcome db "WELCOME USER $"
 welcome2 db " :)$"
 input_prompt db "ENTER PLAYER NAME : $ "
 name_prompt db "NAME : $"
 isntructions db "INSTRUCTIONS: $ "
 instruction1 db "1- Swap two adjacent random candies to match atleast 3 candies $"
 instruction2 db "2- Points associated with candies are : $"
 instruction3 db "   heart_candy(3 points)  rectangle_candy(2 points) $"
 instruction4 db "   Tri(1 point)  sqaure_candy (1 point)  diam(1 point)  $"
 instruction5 db "4- IMPORTANT!! MUST HAVE FUN :D $"
 username dw 20 dup('$') ; Buffer to store the user's name

	fname db "player.txt"
	fhandle dw ?
	random db 0
	newlinestr db 10,13, '$'
	level1 db "Level 1 :"
	level2 db "Level 2 :"
	level3 db "Level 3 :"
	level1_score dw ?
	level2_score dw ?
	level3_score dw ?
	COUNTER DB 0
	BOARD_ARRAY DB 49 DUP(0) ;7x7 array for the board
	x_cords DW 0
	y_cords DW 0
	y_axis DB 0
	VAR DW 0
	VAR2 DW 0
	MOVES DB 0
	LEVEL DB "LEVEL:$"
	LEVEL_NO DB 0
	outpscore DB "SCORE:$"
	scored DB 0
	display_moves DB "MOVES:$"
	GETX DW 0
	GETY DW 0
	selected_candy1 DB 0
	selected_candy2 DB 0
	GETX1 DW 0
	GETY1 DW 0
	NUMBER DB 0
	wrongmove DB "INVALID MOVE$"
	num_candies DB 0
	CANDYTYPE DB 0
	username_LEN DB 0
	VALID DB 0
	COMBO DB 0
	crushing db "CRUSHING$"
	exploded DB "EXPLOSION", '$'
	colorbomb db 0
	matches db 0    
	level_success DB  "      LEVEL SUCCESSFULL :D  $"
	level_success2 DB  "      MOVE TO NEXT LEVEL...$"
	level_failed DB  "      LEVEL FAILED :( TRY AGAIN $"
.CODE
;************************************************************************
;                          MAIN FUNCTION STARTS HERE
;************************************************************************
main proc
	MOV AX,@DATA
	MOV DS,AX
	
	;FILE CREATION OR OPENING
	MOV AH,3CH 		;3ch: file creation, 3eh: file closes, 3dh: file opens for reading
	MOV CL,0		;to write
	MOV DX, OFFSET FNAME
	INT 21H
	MOV FHANDLE,AX
	
	 ;mode13 graphics
	MOV AX,0013H   ;320x200 pixels and 16 colours 
	INT 10H

    MOV AH,0BH
	MOV BH,04h
	MOV BL,04h 	;background colour
	INT 10H

    ; ######page1

    ; Set Video Mode for Scroll Up Window (25 x 80) To move up # of lines from Bottom
    mov ah, 6   ; Scroll Up Window -> Function to change Background Color
    mov al, 0  ; Lines to Scroll -> AL = 0 or 25 will Scroll whole screen
    mov bh, 04h ; Left Char for Background (4 ) & Right Char for Foreground (E) 

     ;ch = left most row , cl = left most coloumn , dh = right most row , dl = right most coloumn
     ;25 rows and 80 coloumns for vidoe mode so MAX ch=0-24 and dh=24, cl=0-79 and dl =79

	mov ch, 0  ; CH Upper Row # minimum can be 0
	mov cl, 0  ; CL Left column # minimum can be 0
    mov dh, 24  ; Lower row # maximum can be 24
    mov dl, 79  ; Right column # maximum can be 79
    int 10h     

    ;Set Cursor Position for game name
    mov ah, 02h ; function to set cursor position
    mov bh, 0   ; Set 1st page number , Welcome Page of Game for example	
    mov dl, 5  ; 10 spaces from left
    mov dh, 7  ; 11th line
    int 10h     

    ;Print String
    mov dx, offset game_name 
    mov ah, 09h        
    int 21h             

    call NEXTLINE

    ;Set Cursor Position for input
    mov ah, 02h 
    mov bh, 0   	
    mov dl, 5  ;10 spaces from left
    mov dh, 13  ;13th line
    int 10h    

    ;Prompt for user input
    mov dx, offset input_prompt  
    mov ah, 09h         
    int 21h   

	MOV SI, OFFSET username		;to store player name
	.REPEAT
		INC username_LEN
		MOV AH,01
		INT 21H
		MOV AH,0
		MOV [SI],AL
		inc SI
	.UNTIL AL== 13			;takes input for player name till user presses enter key
	mov byte ptr [SI], 36		;'$' sign to make string output better

	;writing name in .file
	MOV AH,40H 		;write mode
	MOV CX,LENGTHOF username
	MOV BX,fhandle	;File handler was moved into AX as soon as file was opened
	MOV DX,OFFSET username
	INT 21H


	 displaying:
    ;next line code
    call NEXTLINE

    ;Set Cursor Position for welcome message
    mov ah, 02h ; function to set cursor position
    mov bh, 0   	
    mov dl, 5   ;5 spaces from the left
    mov dh, 15  ;displaying msg on 15th line
    int 10h     

    MOV DX, offset WELCOME	;displays WELCOME MESSAGE
	MOV AH,09H
	INT 21H

    mov ah, 09h
    mov dx, offset username
    int 21h

    MOV DX, offset WELCOME2	;displays WELCOME MESSAGE
	MOV AH,09H
	INT 21H

    ;to move on next page
    page2:
    mov ah,08h ;takes cahracter input but do not display them on the console
    int 21h
    cmp al,13 ;to match with the enter
    jne page2

	CALL instructionpage	;displays second page with rules
     MOV AH,08H  ;takes cahracter input but do not display the on the console
	 INT 21H  

		;moving to level 1 after instruction page
			MOV LEVEL_NO,1
			MOV AH,05H		;MOVE TO NEXT PAGE WITH BOARD DISPLAY
			MOV AL,03H
		
			MOV AH,0BH
			MOV BH,02H
			MOV BL,0H 	;background colour
			INT 10H
	
			MOV AH,06h	;scroll-up window
			MOV AL,0
			MOV BH,00H		;text and background colour
			MOV CH,0		;upper row number	
			MOV CL,0		;left col
			MOV DH,24
			MOV DL,79
			INT 10H
	
			CALL level1_game

			 ;MOV AX,0003H   ;320x200 pixels and 16 colours 
	INT 10H
    mov ah,05h;in video mode to select page
    mov al,07h ; for selcting page 7
    ; Call interrupt 10h (BIOS video services)

    ; Set Video Mode for Scroll Up Window (25 x 80) To move up # of lines from Bottom
    mov ah, 6   
    mov al, 0  
    mov bh, 4Eh 

	mov ch, 0  
	mov cl, 0  
    mov dh, 24  
    mov dl, 79  
    int 10h 
    ;Set Cursor Position on [page #7] for username
    mov ah, 02h 
    mov bh, 0  
    mov dl, 5  ;display msg 5 SPACES FROM LEFT
    mov dh, 5   ;display msg on LINE 5th
    int 10h    

    ;Display username
    mov dx, offset username
    mov ah, 09h
    int 21h

	;Set Cursor Position on [page #7] for scores
    mov ah, 02h 
    mov bh, 0  
    mov dl, 5  ;display msg 5 SPACES FROM LEFT
    mov dh, 7   ;display msg on LINE 7th
    int 10h    

    ;Display instructuons
    mov dx, offset level1
    mov ah, 09h
    int 21h

	;Display instructuons
    mov dx, offset level1_score
    mov ah, 09h
    int 21h

	;Set Cursor Position on [page #7] for scores
    mov ah, 02h 
    mov bh, 0  
    mov dl, 5  ;display msg 5 SPACES FROM LEFT
    mov dh, 9   ;display msg on LINE 9th
    int 10h    

    ;Display instructuons
    mov dx, offset level2
    mov ah, 09h
    int 21h

	;Display instructuons
    mov dx, offset level2_score
    mov ah, 09h
    int 21h

    ;Set Cursor Position on [page #7] for scores
    mov ah, 02h 
    mov bh, 0  
    mov dl, 5  ;display msg 5 SPACES FROM LEFT
    mov dh, 11   ;display msg on LINE 11th
    int 10h    

    ;Display instructuons
    mov dx, offset level3
    mov ah, 09h
    int 21h

	;Display instructuons
    mov dx, offset level3_score
    mov ah, 09h
    int 21h

		mov ah,08h 
		int 21h
		CALL CLS
		MOV AH,00
		MOV AL,13
		INT 10H



		 ;file closing
	MOV AH,3EH	
	MOV BX,FHANDLE
	INT 21H 
	
	MOV AH,0		;exiting video mode
	INT 16H
	MOV AH,03
	INT 10h 
	

	MOV AH,4CH
	INT 21H
main endp

;;***********************************************************************
;;                          MAIN FUNCTION ENDS HERE
;;***********************************************************************

;-> DISPLAYING INSTRUCTIONS PAGE
instructionpage proc
    
    ;setting to simple text mode
    MOV AX,0003H   ;320x200 pixels and 16 colours 
	INT 10H
    mov ah,05h;in video mode to select page
    mov al,02h ; for selcting page 2
    ; Call interrupt 10h (BIOS video services)

    ; Set Video Mode for Scroll Up Window (25 x 80) To move up # of lines from Bottom
    mov ah, 6   
    mov al, 0  
    mov bh, 4Eh 

	mov ch, 0  
	mov cl, 0  
    mov dh, 24  
    mov dl, 79  
    int 10h 
 ;Set Cursor Position on [page #2] for instructions
    mov ah, 02h 
    mov bh, 0  
    mov dl, 32  ;display msg 12 SPACES FROM LEFT
    mov dh, 6   ;display msg on LINE 6TH
    int 10h    

    ;Display instructuons
    mov dx, offset isntructions
    mov ah, 09h
    int 21h

    call NEXTLINE 

    ;Set Cursor Position on [page #2] for instructions
    mov ah, 02h 
    mov bh, 0  
    mov dl, 5  ;display msg 5 SPACES FROM LEFT
    mov dh, 8   ;display msg on LINE 10th
    int 10h    

    ;Display instructuon 1
    mov dx, offset instruction1
    mov ah, 09h
    int 21h

    call NEXTLINE ;next line

    ;Set Cursor Position on [page #2] for instructions
    mov ah, 02h 
    mov bh, 0  
    mov dl, 5  ;msg 5 spaces from left
    mov dh, 10 ;display msg on line 10th
    int 10h    

    ;Display instructuon 2
    mov dx, offset instruction2
    mov ah, 09h
    int 21h

    call NEXTLINE

    ;Set Cursor Position on [page #2] for instructions
    mov ah, 02h 
    mov bh, 0  
    mov dl, 5  ;5 SPACES FROM LEFT
    mov dh, 12   ;display msg on line 12
    int 10h    

    ;Display instructuon 3
    mov dx, offset instruction3
    mov ah, 09h
    int 21h

    call NEXTLINE

    ;Set Cursor Position on [page #2] for instructions
    mov ah, 02h 
    mov bh, 0  
    mov dl, 5  ;5 SPACES FROM LEFT
    mov dh, 14 ;LINE 14th
    int 10h    

    ;Display instructuon 4
    mov dx, offset instruction4
    mov ah, 09h
    int 21h

    call NEXTLINE

	;Set Cursor Position on [page #2] for instructions
    mov ah, 02h 
    mov bh, 0  
    mov dl, 5  ;5 SPACES FROM LEFT
    mov dh, 16 ;LINE 14th
    int 10h    

    ;Display instructuon 4
    mov dx, offset instruction5
    mov ah, 09h
    int 21h

ret
instructionpage endp

;-> NEXT LINE FUNC
NEXTLINE PROC USES AX DX
	MOV DL,10
	MOV AH,02H
	INT 21H
	MOV DL,13
	MOV AH,02H
	INT 21H
	RET	
NEXTLINE ENDP

;-> RANDOM FUNCTION
RANDO PROC USES AX BX CX DX
	 ; When you invoke interrupt 1AH with function 00h,
	 ; it returns the current system time (in clock ticks) since midnight.
    MOV AH,0
	MOV AL,0
	INT 1AH ;answer is stored in cl:dl 
	MOV random,DL
	RET
RANDO ENDP

;-> BLOCK BORDER FOR EACH CELL
BLOCK_BORDER PROC USES AX BX CX DX
	MOV AH,0CH
	MOV AL,0FH
	MOV BX,x_cords
	ADD BX,30
	MOV CX,x_cords
	.WHILE CX<=BX		;constructs two parallel horizontal nice
		MOV DX,y_cords
		INT 10H
		ADD DX,20
		INT 10H
		INC CX	
	.ENDW
	MOV BX,y_cords
	ADD BX,20
	MOV DX,y_cords
	.WHILE DX<=BX		;constructs two vertical lines
		MOV CX,x_cords
		INT 10H
		ADD CX,30
		INT 10H
		INC DX	
	.ENDW
	RET
BLOCK_BORDER ENDP



;-> GIVING VALUES TO CELLS IN BOARD, RANDOMLY
make_board PROC USES SI AX
	MOV COUNTER,0
	MOV SI,OFFSET BOARD_ARRAY	;address of board
	MOV AX,0
	.REPEAT
		CALL RANDO			
		MOV AL,COUNTER		
		XOR random,AL		;random generated number is randomized even more xor
		MOV AL,random       ;moving modified rand value to al
		MOV AH,0
		MOV BL,5		     ;taking mod of 5
		DIV BL               ;al = quotient , ah = remainder
		MOV BYTE PTR [SI],AH ;storing remainder in the board array location pointer by si (0-6)
		INC SI
		INC COUNTER
	.UNTIL COUNTER==49
	RET	
make_board ENDP

;-> GREEN SQUARE CANDY
sqaure_candy PROC USES AX BX CX DX
	MOV AH,0CH		;function call for drawing pixels
	MOV AL,02H		;green color for square candies
	MOV BH,01
	MOV BX,x_cords
	ADD BX,20		;x-axis range
	MOV CX,x_cords       ;cx->current x coordinate
	ADD CX,10
	MOV DX,Y_cords       ;dx->current y coordinate
	ADD DX,5
	MOV y_axis,DL
	ADD y_axis,10		;y-axis range
	.WHILE CX<BX        ;iterates over_again x-axis range
		MOV DX,y_cords
		ADD DX,5
		INT 10H
		.WHILE DL<y_axis		;nested loop iterates over_again y axis range
			INC DX
			INT 10H
		.ENDW
		INC CX	   ;increment in cx process continues until the square is drawn
	.ENDW
	RET
sqaure_candy ENDP

;-> YELLOW RECTANGLE CANDY
rectangle_candy PROC USES AX BX CX DX
	MOV AH,0CH		;function call for drawing pixel
	MOV AL,0EH		;yellow color
	MOV BH,01H
	MOV BX,x_cords
	ADD BX,25		;x-axis range
	MOV CX,x_cords
	ADD CX,5
	MOV DX,y_cords
	ADD DX,7
	MOV y_axis,DL
	ADD y_axis,7		;y-axis range
	.WHILE CX<BX
		MOV DX,y_cords
		ADD DX,7
		INT 10H
		.WHILE DL<y_axis		;nested loop
		INC DX
		INT 10H
		.ENDW
		INC CX	
	.ENDW
	RET
rectangle_candy ENDP

;-> RED heart_candy CANDY
heart_candy PROC USES AX BX CX DX
	
	MOV AH,0CH		;function call for drawing pixels
	MOV AL,04H		;RED colour
	MOV BH,01H
	MOV BX,0	
	MOV CX,0
	MOV DX,0
	MOV CX,x_cords
	MOV DX,y_cords
	ADD CX,11
	ADD DX,6
	INT 10H
	INC CX 
	INT 10H
	ADD CX,4
	INT 10H
	INC CX
	INT 10H
	INC DX
	MOV CX,x_cords
	ADD CX,10
	MOV BX,CX			;drawing top curves of the heart_candy
	ADD BX,9				;hard coded
	.WHILE  CX<BX
		MOV VAR,BX
		SUB VAR,CX
		.IF VAR!=5
		INT 10H
		.ENDIF
		INC CX
	.ENDW
	MOV CX,x_cords
	ADD CX, 10
	MOV BX,CX
	ADD BX,9				;drawing 2 lined rectangle
	.WHILE CX<BX
	MOV DX,y_cords
	ADD DX,8
	INT 10H
	INC DX
	INT 10H
	INC CX
	.ENDW
	INC DX					;drawing a downward triangle line by line
	MOV CX,x_cords
	ADD CX,11
	MOV BX,CX
	ADD BX,7
	.WHILE  CX<BX
		INT 10H
		INC CX
	.ENDW
	INC DX
	MOV CX,x_cords
	ADD CX,12
	MOV BX,CX
	ADD BX,5
	.WHILE  CX<BX
		INT 10H
		INC CX
	.ENDW
	INC DX
	MOV CX,x_cords
	ADD CX,13
	MOV BX,CX
	ADD BX,3
	.WHILE  CX<BX
		INT 10H
		INC CX
	.ENDW
	INC DX
	MOV CX,x_cords
	ADD CX,14
	INT 10H
	RET
heart_candy ENDP

;-> ORANGE TRIANGLE CANDY
TRIANGLE PROC USES AX BX CX DX
	MOV AX,x_cords
	MOV VAR, ax
	ADD VAR,15
	MOV BH,0
	MOV BX,0
	MOV DX,y_cords
	ADD DX,5
	MOV y_axis,DL
	ADD y_axis,9
	MOV AX,VAR
	MOV VAR2, AX
	MOV AH,0CH		;drawing pixels
	MOV AL,0CH		;orange color
	
	.REPEAT 
		MOV CX,VAR
		.WHILE CX<=WORD PTR VAR2
			INT 10H
			INC CX
		.ENDW
		DEC WORD PTR VAR			;decrementing starting point
		INC WORD PTR VAR2			;incrementing ending point
		INC DX
	.UNTIL DL==y_axis
	RET
TRIANGLE ENDP

;-> PURPLE diamound_candy CANDY
diamound_candy PROC
	mov AX, x_cords
	MOV VAR, AX
	ADD VAR,15
	MOV BH,0
	MOV BX,0
	MOV DX,y_cords
	ADD DX,5
	MOV y_axis,DL
	ADD y_axis,5		;y-axis range
	mov ax, var
	mov var2, ax
	mov ah, 0ch		;function call for drawing pixels
	mov al, 05h		;pruple colour
	
	.REPEAT 				;loop for up-right triangle
		mov cx, word ptr var
		.WHILE cx<=word ptr var2
			int 10h
			inc cx
		.ENDW
		dec word ptr var
		inc word ptr var2
		inc dx
	.UNTIL dl==y_axis
	ADD y_axis, 6
	.REPEAT 				;loop for downwards triangle
		mov cx, word ptr var
		.WHILE cx<=word ptr var2
			int 10h
			inc cx
		.ENDW
		INC word ptr var
		DEc word ptr var2
		inc dx
	.UNTIL dl==y_axis
	RET
diamound_candy ENDP

;-> BLUE BOMB
BOMB PROC USES AX BX CX DX
	MOV AH,0CH		;drawing pixels
	MOV AL,01H      ;BLUE COLOR
	MOV BH,01
	MOV BX,x_cords
	ADD BX,20		;x-axis range
	MOV CX,x_cords
	ADD CX,10
	MOV DX,y_cords
	ADD DX,5
	MOV y_axis,DL
	ADD y_axis,10			;y-axis range
	.WHILE CX<BX			;draws vertical lines
		MOV AH,0CH
		INC AL
		MOV DX,y_cords
		ADD DX,5
		INT 10H
		.WHILE DL<y_axis
		INC DX
		INT 10H
		.ENDW
		INC CX	
	.ENDW
	RET
BOMB ENDP
;***************************
;FUNCTION CALL FOR BLOCKAGE
;******************************
BLOCKAGE PROC USES AX BX CX DX
	MOV AH,0CH
	MOV AL,0fH
	MOV BX,x_cords
	ADD BX,25
	MOV CX,x_cords
	ADD CX,5
	MOV DX,y_cords
	.WHILE CX<BX			;printing diagonal left to right
		INT 10H
		INC CX
		INC DX		
	.ENDW
	MOV BX,x_cords
	ADD BX,5
	MOV CX,x_cords
	ADD CX,25
	MOV DX,y_cords
	.WHILE CX>BX			;printing diagonal righ to left
		INT 10H
		DEC CX
		INC DX		
	.ENDW
	RET
BLOCKAGE ENDP
;->highlight selected block
HIGHLIGHT PROC USES AX BX CX DX
	MOV AH,0CH
	MOV AL,0fH
	MOV BX,x_cords
	ADD BX,25
	MOV CX,x_cords
	ADD CX,2				;same as block border with different diensions
	.WHILE CX<=BX
		MOV DX,y_cords
		ADD DX,2
		INT 10H
		INC DX
		ADD DX,17
		INT 10H
		INC CX	
	.ENDW
	MOV BX,y_cords
	ADD BX,17
	MOV DX,y_cords
	ADD DX,2
	.WHILE DX<=BX
		MOV CX,x_cords
		ADD CX,2
		INT 10H
		ADD CX,25
		INT 10H
		INC DX	
	.ENDW
	RET
HIGHLIGHT ENDP

;-> LEVEL DETAILS FUNCTION
level_info PROC USES AX BX CX DX
	MOV AH,06h	;scroll-up window
	MOV AL,0
	MOV BH,00H		;text and background colour (left for background, right for foreground)
	MOV CH,0		;upper row number	
	MOV CL,0		;left col
	MOV DH,24
	MOV DL,79
	INT 10H
	
	MOV AH,02H
	MOV BH,0
	MOV DH,2	;displays message in line 8
	MOV DL,2		;starts display with a gap of 2 spaces
	INT 10H
	
	MOV DX, offset game_name	;displays gamename
	MOV AH,09H
	INT 21H
	
	MOV AH,02H
	MOV BH,0
	MOV DH,4		;displays message in line 4
	MOV DL,29		;starts display with a gap of 29 spaces
	INT 10H
	
	MOV DX, offset LEVEL	;displays the word 'LEVEL'
	MOV AH,09H
	INT 21H
	
	MOV DL, LEVEL_NO	;displays level number
	ADD DL,48
	MOV AH,02H
	INT 21H
	
	MOV AH,02H
	MOV BH,0
	MOV DH,6		;displays message in line 6
	MOV DL,29		;starts display with a gap of 29 spaces
	INT 10H
	
	MOV SI,OFFSET username
	MOV CL,0
	.WHILE CL<username_LEN
		MOV DL,BYTE PTR [SI]
		MOV AH,02H
		INT 21H
		INC SI
		INC CL
	.ENDW
	
	MOV AH,02H
	MOV BH,0
	MOV DH,8		;displays message in line 8
	MOV DL,29		;starts display with a gap of 29 spaces
	INT 10H
	
	MOV DX, offset display_moves	;displays word 'Moves'
	MOV AH,09H
	INT 21H
	
	MOV DL,MOVES	;displays moves
	MOV NUMBER,DL
	CALL DISPLAYNUM
	
	OUTP '/'
	OUTP '1'
	OUTP '5'		;total moves for each level
	
	MOV AH,02H
	MOV BH,0
	MOV DH,10		;displays message in line 10
	MOV DL,29		;starts display with a gap of 29 spaces
	INT 10H
	
	MOV DX, offset outpscore			;displays word 'score'
	MOV AH,09H
	INT 21H
	
	MOV DL,scored	;moving score to dl
	MOV NUMBER,DL
	CALL DISPLAYNUM ;displays score
	
	RET
level_info ENDP

;-> DISPLAYING THE CANDIES IN BOARD
showboard PROC USES SI  AX
	MOV COUNTER,0
	MOV SI,OFFSET BOARD_ARRAY
	MOV x_cords,10
	MOV y_cords,30
	.WHILE COUNTER<49
	 MOV al, [SI] 
		.IF AL!=5  ;blockage
	    	CALL BLOCK_BORDER 
		.ENDIF
		.IF aL==0     ;self assigned 0 for square candies
			CALL sqaure_candy
		.ELSEIF al==1 ;assigned 1 for rectangle candies
			CALL rectangle_candy
		.ELSEIF al==2 ;assigned 2 for heart_candy candies
			CALL heart_candy
		.ELSEIF al==3 ;assigned 3 for triangle candies
			CALL TRIANGLE
		.ELSEIF al==4 ;assigned 4 for diamound_candy candies
			CALL diamound_candy
		.ELSEIF al==6 ;assigned 6 for bomb
			CALL BOMB
		.ENDIF
		INC SI
		;moving to next block of the board
		ADD x_cords,30
		.IF x_cords>=220
			MOV x_cords,10
			ADD y_cords,20
		.ENDIF
		INC COUNTER
	.ENDW
	RET
showboard ENDP

;***********************************************
;FUNCTION CALL FOR INITIALIZING BOARD FOR level3_game
;************************************************
LEVEL3_BOARD PROC USES SI
	MOV SI,OFFSET BOARD_ARRAY
	MOV COUNTER,3
	ADD SI,3
	.WHILE COUNTER<=49 		;vertically putting blockage
		MOV BYTE PTR [SI],5
		ADD SI,7
		ADD COUNTER,7
	.ENDW
	MOV SI,OFFSET BOARD_ARRAY
	MOV COUNTER,21
	ADD SI,21
	.WHILE COUNTER<28
		MOV BYTE PTR [SI],5		;horizontally putting blockage
		INC SI
		INC COUNTER
	.ENDW
	RET
LEVEL3_BOARD ENDP

;**************************************************
;FUNCTION CALL FOR INITIALIZING BOARD FOR level2_game
;****************************************************
LEVEL2_BOARD PROC USES SI
	MOV SI,OFFSET BOARD_ARRAY
	MOV BYTE PTR [SI],5			;hardcoding blockage as per level 2
	ADD SI,3
	MOV BYTE PTR [SI],5
	ADD SI,3
	MOV BYTE PTR [SI],5

	INC SI
	MOV BYTE PTR [SI],5
	ADD SI,6
	MOV BYTE PTR [SI],5

	ADD SI,8
	MOV BYTE PTR [SI],5

	ADD SI,6
	MOV BYTE PTR [SI],5
	ADD SI,8
	MOV BYTE PTR [SI],5
	ADD SI,6
	MOV BYTE PTR [SI],5
	INC SI
	MOV BYTE PTR [SI],5

	MOV BYTE PTR [SI],5
	ADD SI,3
	MOV BYTE PTR [SI],5
	ADD SI,3
	MOV BYTE PTR [SI],5
	RET
LEVEL2_BOARD ENDP

;-> mouse click function
getcoordinates proc uses AX BX CX DX
	MOV AX,1		;puts cursor on the screen 
	INT 33H
	MOV CX, 20
	MOV DX, 440
	MOV AX, 7
	INT 33H
	MOV CX, 30
	MOV DX, 170
	MOV AX, 8
	INT 33H
	.REPEAT
		MOV AX,3		;gets cursor co-ordinates
		INT 33H
		MOV GETX,CX  	;moves x-coordinate into getx variable
		MOV GETY,DX 	;moves y-coordinate into gety variable
		MOV CX,0H		;ADDING DELAY
		MOV DX,0FFFFH
		MOV AH,86H
		INT 15H
	.UNTIL BL==1	;until button click detected
	MOV DX,0
	MOV AX,GETX
	MOV BX,2		;in 320x200 mode, value of cx is doubled so we halve it
	DIV BX
	MOV GETX,AX
	RET
getcoordinates endp

;-> function for multidigit num
DISPLAYNUM PROC USES AX BX CX DX
	MOV AX,0
	MOV AL,NUMBER
    MOV CX, 0
    .WHILE AX>0
        MOV DX, 0
        MOV BX, 10	;dividing by 10
        DIV BX
        PUSH DX		;pushing into stack
        INC CX
    .ENDW
    .WHILE CX!=0
        POP DX			;pops in reverse order
        ADD DX, 30h
        MOV AH, 2H;
        INT 21H
        DEC CX
    .ENDW
    RET
DISPLAYNUM ENDP

;-> getting index number of coordinates
CHECK_BLOCK PROC USES AX BX CX DX		
	MOV COUNTER,0				;translates coordinates into block
	MOV x_cords,10
	MOV CX,GETX
	.WHILE x_cords<CX			;while x is less than mouse coordinates
		INC COUNTER	        	;incrementing for index
		ADD x_cords,30
	.ENDW
	SUB x_cords,30
	MOV y_cords,20
	MOV CX,GETY			;yy-coordinate get by mouse
	MOV BX,0
	.WHILE y_cords<CX			;getting y index
		INC BX
		ADD y_cords,20
	.ENDW
	SUB y_cords,10
	CALL HIGHLIGHT		;selected block is highlighted
	MOV AX,7
	DEC BX
	MUL BX
	ADD COUNTER,AL
	DEC COUNTER
	
	RET
CHECK_BLOCK ENDP

;-> scored UPDATE FUNCTION
SCORE_UPDATE PROC USES AX BX
	MOV AX,0
	MOV AL,num_candies  ;how many candies have been matched
;	MOV DL,LEVEL_NO
	.IF CANDYTYPE==0	    	;candytype = 0 = square has 1 point
		MOV BL,1
		MUL BL
	.ELSEIF CANDYTYPE==1		;candytype = 1 = rectangle has 2 points
		MOV BL,2
		MUL BL
	.ELSEIF CANDYTYPE==2		;candytype = 2 = heart_candy has 3 points
		MOV BL,3
		MUL BL
	.ELSEIF CANDYTYPE==3		;candytype = 3 = triangle has 1 points
		MOV BL,1
		MUL BL
	.ELSEIF CANDYTYPE==4		;candytype = 4 = diamound_candy has 1 point
		MOV BL,1
		MUL BL
	.ENDIF
	ADD scored,AL
	RET
SCORE_UPDATE ENDP

;-> CHECKING MATCHES AFTER SWAPS FUNC
matches_check PROC USES SI DI AX BX CX DX
	mov matches, 0
	MOV COMBO,0
	MOV SI,OFFSET BOARD_ARRAY
	MOV COUNTER,0
	MOV AL,BYTE PTR [SI]
	MOV CANDYTYPE, AL ;the number stored on that array_index is stored in "candytype"
	MOV num_candies,1 ;candies counter
	.WHILE COUNTER <49		;checking for horizontal matches
		INC SI
		MOV AL,CANDYTYPE
		.IF [SI]==AL		;if candytype matches the number stored on next index of array then
			INC num_candies		;increment COUNTERer
		.ELSE 
			MOV CL,num_candies
			.IF num_candies>=3 && CANDYTYPE!=5  	;if 3 candies of same type have been found
				mov matches, 1
				CALL SCORE_UPDATE		;scored uppdate after crushing candy
				MOV DI,SI
				.REPEAT
					DEC DI
					MOV BYTE PTR [DI],7
					DEC num_candies
					MOV COMBO,1
				.UNTIL num_candies==0
			.ENDIF
			.IF CL==4 && LEVEL_NO !=3	;incase of 4 candies matching a color bomb is added to the board
				SUB SI,3
				MOV BYTE PTR [SI],6
				ADD SI,3
			.ENDIF
			MOV num_candies,1		;resetting COUNTER
			MOV AL,[SI]
			MOV CANDYTYPE,AL
		.ENDIF
		INC COUNTER
	.ENDW
	MOV num_candies,1
	MOV AX,0
	.WHILE AL<7
		MOV SI,OFFSET BOARD_ARRAY
		MOV DX,0
		MOV DL,AL
		ADD SI,DX
		MOV BL,BYTE PTR [SI]
		MOV CANDYTYPE,BL
		MOV AH,0
		.WHILE AH<7
			ADD SI,7
			.IF BL == BYTE PTR [SI]		;if candy matches
				INC num_candies			;increment COUNTERer
			.ELSE
				MOV CL,num_candies
				.IF num_candies>=3 && CANDYTYPE !=5			;if 3 candies of same type have been found
					mov matches, 1
					CALL SCORE_UPDATE
					MOV DI,SI
					.REPEAT
						SUB DI,7
						MOV BYTE PTR [DI],7
						MOV DL,BYTE PTR [DI]
						DEC num_candies
						MOV COMBO,1
					.UNTIL num_candies==0
				.ENDIF
				.IF CL==4 && CANDYTYPE !=5 && LEVEL_NO !=3				;incase of 4 candies matching a color bomb is added to the board
					SUB SI,21
					MOV BYTE PTR [SI],6
					ADD SI,21
				.ENDIF
				MOV num_candies,1 		;resetting COUNTER
				MOV BL,BYTE PTR [SI]
				MOV CANDYTYPE,BL
			.ENDIF
			INC AH
		.ENDW
		INC AL
	.ENDW
	RET
matches_check ENDP

;-> VALID MOVE FUNCTION ??????????????
VALIDITY PROC USES AX BX CX DX SI
	MOV AX,0
	MOV BX,0
	MOV AL,selected_candy1
	MOV BL,selected_candy2
	MOV SI,OFFSET BOARD_ARRAY	;moving address of board
	ADD SI,AX   ;pointing to selected_candy1 w stack pointer
	.IF BYTE PTR [SI]==5			;checking if either of the indices point to blockage 
		JMP INVALID1
	.ENDIF
	MOV SI,OFFSET BOARD_ARRAY
	ADD SI,BX   ;pointer to selected_candy2 w stack pointer
	.IF BYTE PTR [SI]==5
		JMP INVALID2
	.ENDIF

	;putting all the conditions to check if the move is wrongmove
	MOV COUNTER,0
	INC AX     
	.IF AX==BX ;checking if both the indexes are same after incrementing 1 in ax
		INC COUNTER
	.ENDIF
	SUB AX,2
	.IF AX==BX  ;checking if both the indexes are same after decrementing 2 from ax
		INC COUNTER 
	.ENDIF
	MOV AL,selected_candy1
	ADD AX,7
	.IF AX==BX
		INC COUNTER
	.ENDIF
	MOV AL,selected_candy1
	SUB AX,7
	.IF AX==BX
		INC COUNTER
	.ENDIF
	.IF COUNTER==0			;if counter hasnt been incremented even once move is wrongmove
		INVALID2:
		INVALID1:

		MOV AH,02H
		MOV BH,0
		MOV DH,15		;displays message in line 15
		MOV DL,28		;starts display with a gap of 29 spaces
		INT 10H
	
		MOV DX, offset wrongmove	;displays 'INVALID MOVE'
		MOV AH,09H
		INT 21H
		MOV VALID,1
	.ENDIF
	RET
VALIDITY ENDP

;-> SWAPPING FUNCTION
SWAP PROC USES SI DI AX BX
						;swaps both indices using SI and DI 
	MOV SI,OFFSET BOARD_ARRAY
	MOV BX,0
	MOV BL,selected_candy1
	ADD SI,BX   ;si pointing to selected_candy1
	MOV AL,BYTE PTR[SI] ;selected_candy1 stored in al
	MOV DI,OFFSET BOARD_ARRAY
	MOV BL,selected_candy2
	ADD DI,BX   ;di pointing to selected_candy2
	MOV AH,BYTE PTR [DI] ;selected_candy2 stored in ah
	MOV [SI],AH ;swapping positions by pointing selected_candy2 to si
	MOV [DI],AL ;swapping positions by pointing selected_candy1 to di

	RET
SWAP ENDP

;->bomb checking and explosion
check_colorbomb PROC USES SI DI BX CX 
	mov colorbomb, 0
	MOV SI,OFFSET BOARD_ARRAY
	MOV DI,OFFSET BOARD_ARRAY
	MOV BX,0
	MOV BL,selected_candy1
	ADD SI,BX
	MOV BL,selected_candy2
	ADD DI,BX
	.IF BYTE PTR [SI]==6		;checks if either of selected indexes are color bombs 
		MOV CL,BYTE PTR[DI]
		MOV CANDYTYPE,CL
		MOV BYTE PTR [SI],7
		MOV VALID,1
	.ELSEIF BYTE PTR [DI]==6		;checks if either of selected indexes are color bombs 
		MOV CL,BYTE PTR[SI]
		MOV CANDYTYPE,CL
		MOV BYTE PTR [DI],7
		MOV VALID,1
	.ELSE
		JMP over_again			;in case of no color bomb
	.ENDIF
	mov colorbomb, 1
	MOV COUNTER,0
	MOV num_candies,0
	MOV CL, CANDYTYPE
	MOV SI,OFFSET BOARD_ARRAY
	.WHILE COUNTER<49		        ;traversing through entire array
		.IF BYTE PTR[SI]==CL		;if candy is found
		    call HIGHLIGHT
			MOV BYTE PTR [SI],7		;candy popped
			INC num_candies			
		.ENDIF
		INC COUNTER
		INC SI
	.ENDW
	INC MOVES
	CALL SCORE_UPDATE		;scored is updated
	over_again:
	RET
check_colorbomb ENDP

;->putting new candies
REPOPULATE PROC USES SI
	MOV COUNTER,0
	MOV SI,OFFSET BOARD_ARRAY
	.WHILE COUNTER<49		;board is traversed
		.IF BYTE PTR [SI]==7 || BYTE PTR [SI]==5		;in case of blockage 5 or empty space 7 new candies are brought
			MOV AX,0
			CALL RANDO		;random number generated
			MOV AL,random
			XOR AL,COUNTER		;number is randomized even more
			MOV BL,5
			DIV BL
			MOV BYTE PTR [SI],AH
		.ENDIF
		INC SI
		INC COUNTER
	.ENDW
		RET
REPOPULATE ENDP

;-> bring candies
populate_candies PROC USES SI CX
	MOV SI,OFFSET BOARD_ARRAY
	MOV COUNTER,0
	.WHILE COUNTER <49			;entire array is traversed
		.IF BYTE PTR [SI]==7 && COUNTER>=7		;in case of empty space found
			MOV CL, COUNTER
			MOV selected_candy1,CL
			SUB CL,7
			MOV selected_candy2,CL
			.REPEAT				;bring to the top row
				CALL SWAP
				SUB selected_candy1,7
				SUB selected_candy2,7
			.UNTIL selected_candy1<7
		.ENDIF
		INC SI
		INC COUNTER
	.ENDW
	RET
populate_candies ENDP

;-> LEVEL 1 GAME
level1_game PROC USES AX BX CX DX
	MOV MOVES,1
	MOV scored,0
	CALL make_board

	.REPEAT
		MOV AH,00H
		MOV AL,13
		INT 10H
		CALL REPOPULATE
		MOV CH,0
		.REPEAT
				CALL matches_check
				CALL populate_candies
				CALL REPOPULATE
				INC CH
		.UNTIL COMBO==0 || CH==6
		CALL level_info
		CALL showboard
		CALL getcoordinates
		CALL CHECK_BLOCK
		MOV CL,COUNTER
		MOV selected_candy1,CL
		MOV CX,10H		;ADDING DELAY
		MOV DX,78H
		MOV AH,86H
		INT 15H
	
		CALL getcoordinates 
		CALL CHECK_BLOCK
		MOV CL,COUNTER
		MOV selected_candy2,CL 
		
		CALL VALIDITY
		CALL check_colorbomb
		.IF VALID==1
			MOV VALID,0
			JMP over_again
		.ENDIF
				
		CALL SWAP
		CALL matches_check
	
		INC MOVES
		over_again:
		CALL populate_candies
		MOV CX,10H		;ADDING DELAY
		MOV DX,78H
		MOV AH,86H
		INT 15H
		.IF colorbomb==1
			xor ax, ax
			mov ah, 2h
			mov bh, 0
			mov dh, 15
			 mov dl, 28
			 int 10h
			mov DX, offset exploded
			MOV AH,09H
			INT 21H
				MOV CX,10H		;ADDING DELAY
				MOV DX,78H
				MOV AH,86H
				INT 15H
		.ELSE
			.IF matches==1
				xor ax, ax
				mov ah, 2h
				mov bh, 0
				mov dh, 15
				mov dl, 28
				int 10h
				mov dx, offset crushing
				mov ah, 9h
				int 21h
				MOV CX,10H		;ADDING DELAY
				MOV DX,0FFFFH
				MOV AH,86H
				INT 15H
			.ENDIF
		.ENDIF
		.IF moves!=15 ;until moves are not equal to 15 keep refreshing the screen after each play
			CALL CLS
		.ENDIF
		
	.UNTIL MOVES==15

	mov ax,0
	mov al,scored
	mov level1_score,ax
	mov ax,0
	
    ;MOV AX,0003H   ;320x200 pixels and 16 colours 
	INT 10H
    mov ah,05h;in video mode to select page
    mov al,06h ; for selcting page 6
    ; Call interrupt 10h (BIOS video services)

    ; Set Video Mode for Scroll Up Window (25 x 80) To move up # of lines from Bottom
    mov ah, 6   
    mov al, 0  
    mov bh, 4Eh 

	mov ch, 0  
	mov cl, 0  
    mov dh, 24  
    mov dl, 79  
    int 10h 
    ;Set Cursor Position on [page #6] for instructions
    mov ah, 02h 
    mov bh, 0  
    mov dl, 5  ;display msg 5 SPACES FROM LEFT
    mov dh, 9   ;display msg on LINE 9th
    int 10h    

    .IF scored > 100 ;threshold to clear the level
    ;Display instructuons
    mov dx, offset level_success
    mov ah, 09h
    int 21h

	 ;Set Cursor Position on [page #6] for instructions
    mov ah, 02h 
    mov bh, 0  
    mov dl, 5  ;display msg 5 SPACES FROM LEFT
    mov dh, 11   ;display msg on LINE 9th
    int 10h    

    ;Display instructuons
    mov dx, offset level_success2
    mov ah, 09h
    int 21h
	MOV AH,08H  ;takes cahracter input but do not display the on the console
	INT 21H 

			MOV LEVEL_NO,2
			MOV AH,05H		;MOVE TO NEXT PAGE WITH BOARD DISPLAY
			MOV AL,04H
		
			MOV AH,0BH
			MOV BH,02H
			MOV BL,0H 	;background colour
			INT 10H
	
			MOV AH,06h	    ;scroll-up window
			MOV AL,0
			MOV BH,00H		;text and background colour
			MOV CH,0		;upper row number	
			MOV CL,0		;left col
			MOV DH,24
			MOV DL,79
			INT 10H
			CALL level2_game	
		.ELSE
		;Display instructuons
    mov dx, offset level_failed   ;screen displays level failed
    mov ah, 09h
    int 21h
    mov ah,08h ;takes cahracter input but do not display the on the console
    int 21h
            MOV LEVEL_NO,1
			MOV AH,05H		;MOVE TO NEXT PAGE WITH BOARD DISPLAY
			MOV AL,03H
		
			MOV AH,0BH
			MOV BH,02H
			MOV BL,0H 	;background colour
			INT 10H
	
			MOV AH,06h	;scroll-up window
			MOV AL,0
			MOV BH,00H		;text and background colour
			MOV CH,0		;upper row number	
			MOV CL,0		;left col
			MOV DH,24
			MOV DL,79
			INT 10H
			CALL level1_game
		.ENDIF	
		
	RET
	
level1_game ENDP

;-> LEVEL 2 GAME
level2_game PROC USES AX BX CX DX
	MOV MOVES,1
	MOV scored,0
	CALL make_board
	CALL LEVEL2_BOARD
	.REPEAT
	MOV AH,00H
	MOV AL,13
	INT 10H
	MOV CH,0
		.REPEAT
				CALL matches_check
				CALL populate_candies
				CALL REPOPULATE
				CALL LEVEL2_BOARD
				INC CH
		.UNTIL COMBO==0 || CH==6
	CALL level_info
	CALL showboard
	CALL getcoordinates
	CALL CHECK_BLOCK
	MOV CL,COUNTER
	MOV selected_candy1,CL
	MOV CX,5H		;ADDING DELAY
	MOV DX,0FFFFH
	MOV AH,86H
	INT 15H
	
	CALL getcoordinates
	CALL CHECK_BLOCK
	MOV CL,COUNTER
	MOV selected_candy2,CL 
	MOV CX,5H		;ADDING DELAY
	MOV DX,0FFFFH
	MOV AH,86H
	INT 15H
	CALL VALIDITY
	CALL check_colorbomb
	.IF VALID==1
		MOV VALID,0
		JMP over_again
	.ENDIF
	CALL SWAP
	CALL matches_check

	INC MOVES
	over_again:
	CALL populate_candies
	MOV CX,2H		;ADDING DELAY
	MOV DX,0FFFFH
	MOV AH,86H
	INT 15H
	.IF colorbomb==1
			xor ax, ax
			mov ah, 2h
			mov bh, 0
			mov dh, 15
			 mov dl, 28
			 int 10h
			mov DX, offset exploded
			MOV AH,09H
			INT 21H
				MOV CX,10H		;ADDING DELAY
				MOV DX,78H
				MOV AH,86H
				INT 15H
		.ELSE
			.IF matches==1
				xor ax, ax
				mov ah, 2h
				mov bh, 0
				mov dh, 15
				mov dl, 28
				int 10h
				mov dx, offset crushing
				mov ah, 9h
				int 21h
				MOV CX,10H		;ADDING DELAY
				MOV DX,78H
				MOV AH,86H
				INT 15H
			.ENDIF
		.ENDIF
	.IF moves!=15
	CALL CLS
	.ENDIF
	.UNTIL MOVES==15

	mov ax,0
	mov al,scored
	mov level2_score,ax
	mov ax,0

      ;MOV AX,0003H   ;320x200 pixels and 16 colours 
	INT 10H
    mov ah,05h;in video mode to select page
    mov al,06h ; for selcting page 6
    ; Call interrupt 10h (BIOS video services)

    ; Set Video Mode for Scroll Up Window (25 x 80) To move up # of lines from Bottom
    mov ah, 6   
    mov al, 0  
    mov bh, 4Eh 

	mov ch, 0  
	mov cl, 0  
    mov dh, 24  
    mov dl, 79  
    int 10h 
    ;Set Cursor Position on [page #6] for instructions
    mov ah, 02h 
    mov bh, 0  
    mov dl, 5  ;display msg 5 SPACES FROM LEFT
    mov dh, 9   ;display msg on LINE 9th
    int 10h    

    .IF scored > 100 ;threshold to clear the level
    ;Display instructuons
    mov dx, offset level_success
    mov ah, 09h
    int 21h
	
	 ;Set Cursor Position on [page #6] for instructions
    mov ah, 02h 
    mov bh, 0  
    mov dl, 5  ;display msg 5 SPACES FROM LEFT
    mov dh, 11   ;display msg on LINE 9th
    int 10h    

    ;Display instructuons
    mov dx, offset level_success2
    mov ah, 09h
    int 21h
	MOV AH,08H  ;takes cahracter input but do not display the on the console
	INT 21H 

			MOV LEVEL_NO,3
			MOV AH,05H		;MOVE TO NEXT PAGE WITH BOARD DISPLAY
			MOV AL,05H
		
			MOV AH,0BH
			MOV BH,02H
			MOV BL,09H 	;background colour
			INT 10H
	
			MOV AH,06h	    ;scroll-up window
			MOV AL,0
			MOV BH,09H		;text and background colour
			MOV CH,0		;upper row number	
			MOV CL,0		;left col
			MOV DH,24
			MOV DL,79
			INT 10H
			CALL level3_game	
		.ELSE
		;Display instructuons
    mov dx, offset level_failed   ;screen displays level failed
    mov ah, 09h
    int 21h
    mov ah,08h ;takes cahracter input but do not display the on the console
    int 21h
            MOV LEVEL_NO,2
			MOV AH,05H		;MOVE TO NEXT PAGE WITH BOARD DISPLAY
			MOV AL,04H
		
			MOV AH,0BH
			MOV BH,02H
			MOV BL,0H 	;background colour
			INT 10H
	
			MOV AH,06h	;scroll-up window
			MOV AL,0
			MOV BH,00H		;text and background colour
			MOV CH,0		;upper row number	
			MOV CL,0		;left col
			MOV DH,24
			MOV DL,79
			INT 10H
			CALL level2_game
		.ENDIF	
	
	RET
level2_game ENDP

;-> LEVEL 3 GAME
level3_game PROC USES AX BX CX DX
	MOV MOVES,1
	MOV scored,0
	CALL make_board
	CALL LEVEL3_BOARD
	.REPEAT
	MOV AH,00H
	MOV AL,13
	INT 10H
	MOV CH,0
		.REPEAT
				CALL matches_check
				CALL populate_candies
				CALL REPOPULATE
				CALL LEVEL3_BOARD
				INC CH
		.UNTIL COMBO==0 || CH==6
	MOV AH,06h	;scroll-up window
	MOV AL,0
	MOV BH,08H		;text and background colour (left for background, right for foreground)
	MOV CH,0		;upper row number	
	MOV CL,0		;left col
	MOV DH,24
	MOV DL,79
	INT 10H
	
	MOV AH,02H
	MOV BH,0
	MOV DH,2	;displays message in line 8
	MOV DL,2		;starts display with a gap of 2 spaces
	INT 10H
	
	MOV DX, offset game_name	;displays gamename
	MOV AH,09H
	INT 21H
	
	MOV AH,02H
	MOV BH,0
	MOV DH,4		;displays message in line 4
	MOV DL,29		;starts display with a gap of 29 spaces
	INT 10H
	
	MOV DX, offset LEVEL	;displays the word 'LEVEL'
	MOV AH,09H
	INT 21H
	
	MOV DL, LEVEL_NO	;displays level number
	ADD DL,48
	MOV AH,02H
	INT 21H
	
	MOV AH,02H
	MOV BH,0
	MOV DH,6		;displays message in line 6
	MOV DL,29		;starts display with a gap of 29 spaces
	INT 10H
	
	MOV SI,OFFSET username
	MOV CL,0
	.WHILE CL<username_LEN
		MOV DL,BYTE PTR [SI]
		MOV AH,02H
		INT 21H
		INC SI
		INC CL
	.ENDW
	
	MOV AH,02H
	MOV BH,0
	MOV DH,8		;displays message in line 8
	MOV DL,29		;starts display with a gap of 29 spaces
	INT 10H
	
	MOV DX, offset display_moves	;displays word 'Moves'
	MOV AH,09H
	INT 21H
	
	MOV DL,MOVES	;displays moves
	MOV NUMBER,DL
	CALL DISPLAYNUM
	
	OUTP '/'
	OUTP '1'
	OUTP '5'		;total moves for each level
	
	MOV AH,02H
	MOV BH,0
	MOV DH,10		;displays message in line 10
	MOV DL,29		;starts display with a gap of 29 spaces
	INT 10H
	
	MOV DX, offset outpscore			;displays word 'score'
	MOV AH,09H
	INT 21H
	
	MOV DL,scored	;moving score to dl
	MOV NUMBER,DL
	CALL DISPLAYNUM ;displays score
	CALL showboard
	CALL getcoordinates
	CALL CHECK_BLOCK
	MOV CL,COUNTER
	MOV selected_candy1,CL
	MOV CX,5H		;ADDING DELAY
	MOV DX,0FFFFH
	MOV AH,86H
	INT 15H
	
	CALL getcoordinates
	CALL CHECK_BLOCK
	MOV CL,COUNTER
	MOV selected_candy2,CL 
	MOV CX,5H		;ADDING DELAY
	MOV DX,0FFFFH
	MOV AH,86H
	INT 15H
	CALL VALIDITY
	CALL check_colorbomb
	.IF VALID==1
		MOV VALID,0
		JMP over_again
	.ENDIF
	CALL SWAP
	CALL matches_check

	INC MOVES
	over_again:
	CALL populate_candies
	MOV CX,2H		;ADDING DELAY
	MOV DX,0FFFFH
	MOV AH,86H
	INT 15H
	.IF colorbomb==1
			xor ax, ax
			mov ah, 2h
			mov bh, 0
			mov dh, 15
			 mov dl, 28
			 int 10h
			mov DX, offset exploded
			MOV AH,09H
			INT 21H
				MOV CX,10H		;ADDING DELAY
				MOV DX,78H
				MOV AH,86H
				INT 15H
		.ELSE
			.IF matches==1
				xor ax, ax
				mov ah, 2h
				mov bh, 0
				mov dh, 15
				mov dl, 28
				int 10h
				mov dx, offset crushing
				mov ah, 9h
				int 21h
				MOV CX,5H		;ADDING DELAY
				MOV DX,0FFFFH
				MOV AH,86H
				INT 15H
			.ENDIF
		.ENDIF
	.IF moves!=15
	CALL CLS
	.ENDIF
	.UNTIL MOVES==15
    
	mov ax,0
	mov al,scored
	mov level3_score,ax
	mov ax,0

     INT 10H
    mov ah,05h;in video mode to select page
    mov al,06h ; for selcting page 6
    ; Call interrupt 10h (BIOS video services)

    ; Set Video Mode for Scroll Up Window (25 x 80) To move up # of lines from Bottom
    mov ah, 6   
    mov al, 0  
    mov bh, 4Eh 

	mov ch, 0  
	mov cl, 0  
    mov dh, 24  
    mov dl, 79  
    int 10h 
    ;Set Cursor Position on [page #6] for instructions
    mov ah, 02h 
    mov bh, 0  
    mov dl, 5  ;display msg 5 SPACES FROM LEFT
    mov dh, 9   ;display msg on LINE 9th
    int 10h    

    .IF scored > 80 ;threshold to clear the level
    ;Display instructuons
    mov dx, offset level_success
    mov ah, 09h
    int 21h

	 ;Set Cursor Position on [page #6] for instructions
    mov ah, 02h 
    mov bh, 0  
    mov dl, 5  ;display msg 5 SPACES FROM LEFT
    mov dh, 11   ;display msg on LINE 9th
    int 10h    

    ;Display instructuons
    mov dx, offset level_success2
    mov ah, 09h
    int 21h
	MOV AH,08H  ;takes cahracter input but do not display the on the console
	INT 21H 

			MOV LEVEL_NO,0
			MOV AH,05H		;MOVE TO NEXT PAGE WITH BOARD DISPLAY
			MOV AL,05H
		
			MOV AH,0BH
			MOV BH,02H
			MOV BL,0H 	;background colour
			INT 10H
	
			MOV AH,06h	    ;scroll-up window
			MOV AL,0
			MOV BH,00H		;text and background colour
			MOV CH,0		;upper row number	
			MOV CL,0		;left col
			MOV DH,24
			MOV DL,79
			INT 10H
			RET
		.ELSE
		;Display instructuons
    mov dx, offset level_failed   ;screen displays level failed
    mov ah, 09h
    int 21h
    mov ah,08h ;takes cahracter input but do not display the on the console
    int 21h
            MOV LEVEL_NO,3
			MOV AH,05H		;MOVE TO NEXT PAGE WITH BOARD DISPLAY
			MOV AL,05H
		
			MOV AH,0BH
			MOV BH,02H
			MOV BL,9H 	    ;background colour
			INT 10H
	
			MOV AH,06h	    ;scroll-up window
			MOV AL,0
			MOV BH,00H		;text and background colour
			MOV CH,0		;upper row number	
			MOV CL,0		;left col
			MOV DH,24
			MOV DL,79
			INT 10H
			CALL level3_game
		.ENDIF	
	RET
level3_game ENDP

;************
;CLEAR SCREEN
;*************
CLS PROC
	MOV AL,03
	MOV AH,0
	INT 10H
	RET
CLS ENDP
END MAIN