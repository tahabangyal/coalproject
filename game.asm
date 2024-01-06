[org 0x0100] ; This is origin of the code where to start in the memory

jmp start ; This will go to the jump to the start label

waitOfStart:
 db 1 ; This is variables for game state
 
startkey:
 db 1
 
startMessege:
 db 'press a key to start' ; Press any key to start the game
 
borderC:
 db '*' ; This is border character
 
array1:
 db 'level:' ; This is string for level
 
array2:
 db 'score:' ; This string for score
 
array3:
 db 'lives:' ; This is string for lives
 
level:
 db 1 ; This is current level
 
score:
 db 0 ; This is current score
 
lives:
 db 3 ; This is remaining lives
 
oldisr:
 dd 0 ; This is old interrupt service routine address
 
ball:
 db 'O' ; This is ball character
 
bxpos:
 db 15 ; This is ball x position
 
bypos:
 db 39 ; This is ball y position
 
right:
 db 1 ; This is flag for ball moving right

space:
 db ' ' ; This is space character

tile:
 db 0 ; This is tile character
 
left:
 db 0 ; This is flag for ball moving left
 
roof:
 db 0 ; This is flag for ball hitting the roof
 
board:
 dw 3584 ; This board
 
boardposx:
 dw 22 ; This is new addition - board x position
 
boardposy:
 dw 32 ; This is new addition - board y position
 
boardy:
 db 0 ; This is board y offset
 
boardarr:
 times 14 dw 0x0020 ; This is strings used to print and remove board using biosprint
 
boardspace:
 times 1 dw 0x0020
 
brickarr:
 times 14 dw 0x0020 ; This is brick string printed using biosprint
 
brickshow:
 db 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1 ; This is flag to show or hide the bricks
 
brickstart:
 db 4,22,42,62 ; This is starting position of bricks
 
brickend:
 db 17,35,55,75 ; This is ending position of bricks
 
brickrow:
 db 4,6,8,10 ; This is row of bricks
 
tickcount:
 db 0 ; This is tick count for game timing
 
GameOver:
 db 0 ; This is flag for game over
 
brickCOLOR:
 db 0x60,0x20,0x30,0x40 ; This is colors of bricks
 
brickNumbers:
 db 4,8,12,16 ; This is number of bricks per level
 
brickCounter:
 db 0 ; This is counter for bricks
 
changeLevel:
 db 1 ; This is flag to change level
 
GameOverMessage:
 db 'Game Over' ; This is game over message
 
changeFactors:
 db 1,0 ; This is factors for changing level
 
addORsub:
 db 1,2 ; This is operation to add or subtract 0 is for subtaction, 1 is for addition, 2 is for doing nothing

; This is subroutine to print a string
PrintString:
    push bp            ; This saves the base pointer
    mov bp, sp         ; Thus sets up the base pointer

    pusha              ; This saves general-purpose registers or put all registers in the stack
    push es            ; This saves extra segment register
    push di            ; This saves destination index register

    mov al, 80         ; This sets up a constant 80 columns per row
    mul byte [bp+10]   ; This multiplies the specified row by 80
    add ax, [bp+12]    ; This adds the specified column offset
    shl ax, 1          ; This multiplies by 2 each character takes 2 bytes
    mov di, ax         ; This stores the result in destination index register

    mov ax, 0xb800     ; This sets up the video memory segment address
    mov es, ax         ; This loads the segment into the extra segment register

    mov ah, [bp+8]     ; This sets up the attribute color oof the string
    mov si, [bp+4]     ; This loads the offset of the string into source index register
    mov cx, [bp+6]     ; This loads the length of the string into the count register

    cld                ; This clears the direction flag to move forward in the string

next:
    lodsb      ; This loads the next byte from the string into AL
    stosw      ;This stores the word in AX at the destination index, updating DI
    loop next  ; This continues the loop until the entire string is processed
    pop di     ; This restores destination index register
    pop es     ; This restores extra segment register
    popa       ; This restores general-purpose registers
    pop bp     ; This restores the base pointer
    ret 10     ; This returns, removing parameters from the stack

; This subroutine to print a number
printnum:
    push bp
    mov bp, sp
    push es
    push ax
    push bx
    push cx
    push dx
    push di
    mov ax, 0xb800 ; this is moving value 0xb800 to ax which is for accessing text mode video memory
    mov es, ax ; This is to point es to video base
    mov ax, [bp+4] ; This is to load number in ax
    mov bx, 10 ; This is to use base 10 for division
    mov cx, 0 ; This is to initialize count of digits
 
nextdigit:
    mov dx, 0 ; This is zero upper half of dividend
    div bx ; This is divide by 10
    add dl, 0x30 ; This is to convert digit into ascii value
    push dx ; This is to save ascii value on stack
    inc cx ; This is to increment count of values
    cmp ax, 0 ; This is the quotient zero
    jnz nextdigit ; This is if no, divide it again
 mov di, [bp+6] ; This loads the value at the memory location specified by base pointer + 6 into the destination index register

nextpos:
    pop dx ; This is to remove a digit from the stack
    mov dh, 0x07 ; This is to use normal attribute and sets the high most significant byte of the dx register to the value 0x07
    mov [es:di], dx ; This prints char on screen
    add di, 2 ; This moves to next screen location
    loop nextpos ; This repeats for all digits on stack
    pop di
    pop dx
    pop cx
    pop bx
    pop ax
    pop es
    pop bp
    ret 4

; This subroutine to print the ball
Printball:
    push bp            ; This save the base pointer
    mov bp, sp         ; This sets up the base pointer
    push ax            ; This saves the general-purpose registers
    push bx
    push cx
    push dx
    push si
    push di
    push es
    push 7             ; This is attribute for printing the ball color
    mov ax, 0          ; This is to initialize the ax register
    mov al, [bxpos]    ; This is to load the x position of the ball into al
    push ax            ; This is to push the x position onto the stack
    mov al, [bypos]    ; This is to load the y position of the ball into al
    push ax            ; This is to push the y position onto the stack
    push 1             ; This is to length of the ball string
    push ball          ; This is the string containing the ball character
    call biosprint     ; This calls the biosprint subroutine to print the ball
    pop es             ; This restore registers and pointers
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    pop bp             ; This restores the base pointer
    ret               ; This returns from the subroutine

; Subroutine to clear the screen
clrscr:
    push bp            ; Save the base pointer
    mov bp, sp         ; Set up the base pointer
    push ax            ; Save general-purpose registers
    push bx
    push cx
    push dx
    push si
    push di
    push es
    mov ax, 0xb800     ; Set up the video memory segment address
    mov es, ax         ; Load the segment into the extra segment register
    mov di, 0          ; Initialize the destination index to 0
 
loop1:
    mov ax, 0x0720     ; This is to set the black background attribute 0x07, ASCII code 0x20 for space
    mov [es:di], ax    ; This is to store the word in AX at the destination index
    add di, 2          ; This is to move to the next screen location (each character occupies 2 bytes)
    cmp di, 4000       ; This is to compare destination index to the total size of the screen (80 columns * 25 rows * 2 bytes per character)
    jne loop1          ; This is to jump back to the loop if the entire screen is not cleared
    pop es             ; This is to restore registers and pointers
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    pop bp             ; This is to restore the base pointer
    ret               ; This is to return from the subroutine

; Subroutine to print the border
border:
    push bp            ; This saves the base pointer
    mov bp, sp         ; This sets up the base pointer
    push ax            ; This saves general-purpose registers
    push bx
    push cx
    push dx
    push si
    push di
    push es
    push 0xb800        ; This is video memory segment address
    pop es             ; This sets es to video memory segment
    mov al, [borderC]  ; This loads the border character into al
    mov ah, 0x07       ; This set attribute for the border color
    mov cx, 80         ; This is number of columns in the border
    xor di, di         ; This clears the destination index
    rep stosw          ; This repeat Store Word operation to fill the line with the border character and attribute
    mov cx, 25         ; This is number of rows in the border
    mov di, 160        ; This moves to the second line
 
left1:
    mov [es:di], ax    ; This stores the border character and attribute in the left column
    add di, 160        ; This move to the next line
    loop left1         ; This repeat for the entire left side
    mov di, 318        ; This moves to the second-to-last line
    mov cx, 25         ; This is for mumber of rows in the border
 
right1:
    mov [es:di], ax    ; This is to store the border character and attribute in the right column
    add di, 160        ; This is to move to the next line
    loop right1        ; This is to repeat for the entire right side
    pop es             ; This is to restore registers and pointers
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    pop bp             ; This is to restore the base pointer
    ret               ; This is to return from the subroutine

; Subroutine to print a string using BIOS
biosprint:
    push bp            ; This saves the base pointer
    mov bp, sp         ; This sets up the base pointer
    push ax            ; This saves general-purpose registers
    push bx
    push cx
    push dx
    push si
    push di
    push es            ; This saves extra segment register

    mov ah, 0x13        ; This sets up BIOS video service - print string
    mov al, 0          ; This is Subservice 01 – update cursor
    mov cx, [bp+12]    ; This loads normal attribute
    mov bh, 0          ; This sets output on page 0
    mov bl, cl         ; This copys columns to bl
    mov cx, 0          ; This clear cx
    mov cx, [bp+10]    ; This load row
    mov dh, cl         ; This copy columns to dh
    mov cx, 0          ; This clear cx
    mov cx, [bp+8]     ; This load columns
    mov dl, cl         ; This copy columns to dl
    mov cx, 0          ; This clear cx
    mov cx, [bp+6]     ; This load length of string
    push cs            ; This push code segment
    pop es             ; This pop into extra segment register
    mov bp, [bp+4]     ; This loads offset of string
    int 0x10           ; This calls BIOS video service

    pop es             ; This restores extra segment register
    pop di             ; This restores registers and pointers
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    pop bp             ; This restores the base pointer
    ret 10             ; This returns, removing parameters from the stack

; This is Subroutine to print bricks
brickprint:
    push bp            ; Save the base pointer
    mov bp, sp         ; Set up the base pointer
    push ax            ; Save general-purpose registers
    push bx
    push cx
    push dx
    push si
    push di
    push es

    push word [bp+8]   ; Push length
    push word [bp+6]   ; Push row
    push word [bp+4]   ; Push col
    push 14            ; Push size of array
    push brickarr      ; Push brick array
    call biosprint     ; Call biosprint subroutine to print bricks

    pop es             ; Restore registers and pointers
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    pop bp             ; Restore the base pointer
    ret 6              ; Return, removing parameters from the stack

; Subroutine to erase a brick
eraseBRICK:
    push bp            ; Save the base pointer
    mov bp, sp         ; Set up the base pointer
    push ax            ; Save general-purpose registers
    push bx
    push cx
    push dx
    push si
    push di
    push es

    push 0x07          ; Push attribute for erasing brick
    push word [bp+6]   ; Push row
    push word [bp+4]   ; Push col
    push 14            ; Push size of array
    push boardspace    ; Push boardspace array
    call biosprint     ; Call biosprint subroutine to erase brick

    pop es             ; Restore registers and pointers
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    pop bp             ; Restore the base pointer
    ret 4              ; This returns, removing parameters from the stack

; Subroutine to print game-related information
print:
    call border

    push bp
    mov bp, sp
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push es
    mov ax, 0xb800
    mov es, ax
    mov di, 3892 ; starting position for printing information

    ; printing level
    push 7
    push 24
    push 20
    push 6
    push array1
    call biosprint

    mov al, [level]
    add al, 0x30 ; numeric value changed to ascii
    mov ah, 0x02  ; Set AH to 0x02 for character output    mov [es:di], ax
    add di, 20

    ; printing score
    push 7
    push 24
    push 30
    push 6
    push array2
    call biosprint

    mov ah, 0
    mov al, [score]
    push di
    push ax
    call printnum
    add di, 20

    ; printing lives
    push 7
    push 24
    push 40
    push 6
    push array3
    call biosprint

    ; printing board
    push 0x10
    push word [boardposx]
    push word [boardposy]
    push 14
    push boardarr
    call biosprint

    ; print lives
    mov al, [lives]
    add al, 0x30
    mov ah, 0x02
    mov [es:di], ax

    mov ax, 0
    mov bp, 0
    mov bl, [level]
    mov si, 0

; printing bricks
LeveLLOOP:
    mov cx, 4
    mov di, 0
 
BrickLoop:
    cmp byte [brickshow+si], 0
    je DONTprintBRICK
    mov al, [brickCOLOR+bp]
    push ax
    mov al, [brickrow+bp]
    push ax
    mov al, [brickstart+di]
    push ax
    call brickprint
 
DONTprintBRICK:
    inc di
    inc si
    loop BrickLoop

    dec bl
    inc bp
    cmp bl, 0
    jne LeveLLOOP

    pop es
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    pop bp
    ret

RetainBricks:
 push bp
 mov bp,sp
 push ax
 push bx
 push cx
 push dx
 push si
 push di
 push es

 mov cx,16
 mov di,0
 
RetainBricksLoop:
 mov byte[brickshow+di],1
 inc di
 loop RetainBricksLoop

 pop es
 pop di
 pop si
 pop dx
 pop cx
 pop bx
 pop ax
 pop bp

 ret

BRICKremovals:
 push bp
 mov bp,sp
 push ax
 push bx
 push cx
 push dx
 push si
 push di
 push es

 mov di,0
 mov ax,0
 mov dx,0
 mov si,[bp+6]
 mov cx,4

removalsL1:
 mov dx,[bp+4]
 mov al,[brickstart+di]
 mov bl,[brickstart+di]
 mov bh,[brickend+di]
 
 cmp byte[brickshow+si],1
 je leftS
 jmp BRICKremovalsEXIT1

leftS:   ;;right side
 cmp byte[bxpos],dl
 jne rightS

 add bh,1
 cmp byte[bypos],bh
 jne rightS
 cmp byte[addORsub+1],0
 jne rightS
 mov byte[addORsub+1],1
 mov byte[brickshow+si],0
 mov dx,[bp+4]
 push dx
 push ax
 call eraseBRICK
 add byte[score],5
 inc byte[brickCounter]

 jmp BRICKremovalsEXIT

rightS:
 mov dx,[bp+4]
 mov bh,[brickend+di]
 cmp byte[bxpos],dl
 jne upS

 sub bl,1
 cmp byte[bypos],bl
 jne upS
 cmp byte[addORsub+1],1
 jne upS
 mov byte[addORsub+1],0
 mov byte[brickshow+si],0
 mov dx,[bp+4]
 push dx
 push ax
 call eraseBRICK
 add byte[score],5
 inc byte[brickCounter]

 jmp BRICKremovalsEXIT

upS:
 mov dx,[bp+4]
 mov bl,[brickstart+di]
 dec dl
 cmp byte[bxpos],dl
 jne downS
 cmp byte[addORsub],1
 jne downS
 
upSCOL1:
 cmp byte[bypos],bl
 jb upSCOL2
 cmp byte[bypos],bh

 jna upSCHANGES
 
upSCOL2:
 dec bl
 cmp byte[bypos],bl
 jb upSCOL3
 cmp byte[addORsub+1],1
 jne upSCOL3
 cmp byte[bypos],bh

 jna upSCHANGES
 
upSCOL3:
 inc bl
 inc bh
 cmp byte[bypos],bl
 jb downS
 cmp byte[bypos],bh
 ja downS
 cmp byte[addORsub+1],0
 jne downS
 
upSCHANGES:
 mov byte[addORsub],0
 mov byte[brickshow+si],0
 mov dx,[bp+4]
 push dx
 push ax
 call eraseBRICK
 inc byte[brickCounter]

 add byte[score],5
 jmp BRICKremovalsEXIT

downS:
 mov bl,[brickstart+di]
 mov bh,[brickend+di]
 mov dx,[bp+4]
 inc dl
 cmp byte[bxpos],dl
 jne BRICKremovalsEXIT1
 cmp byte[addORsub],0
 jne BRICKremovalsEXIT1
 
downSCOL1:
 cmp byte[bypos],bl
 jb downSCOL2
 cmp byte[bypos],bh
 jna downchanges
 
downSCOL2:
 dec bl
 cmp byte[bypos],bl
 jb downSCOL3
 cmp byte[addORsub+1],1
 jne downSCOL3
 cmp byte[bypos],bh
 jna downchanges
 
downSCOL3:
 inc bl
 inc bh
 cmp byte[bypos],bl
 jb BRICKremovalsEXIT1
 cmp byte[bypos],bh
 ja BRICKremovalsEXIT1
 cmp byte[addORsub+1],0
 jne BRICKremovalsEXIT1
 
downchanges:
 mov byte[addORsub],1
 mov byte[brickshow+si],0
 mov dl,[bp+4]
 push dx
 push ax
 call eraseBRICK
 inc byte[brickCounter]
 add byte[score],5
 jmp BRICKremovalsEXIT

BRICKremovalsEXIT1:
 inc di
 inc si
 dec cx
 cmp cx,0
 je BRICKremovalsEXIT
 jmp removalsL1

;loop removalsL1
BRICKremovalsEXIT:
 mov ax,0

 mov dl,[level]
 mov al,0
 
calculatebrickNumbers:
 add al,4
 dec dl
 cmp dl,0
 jne calculatebrickNumbers

 cmp byte[brickCounter],al
 jne EXitSimplely
 add byte[level],1

 mov byte[brickCounter],0
 mov byte[lives],3
 call RetainBricks
 mov byte[changeLevel],1
 mov byte[waitOfStart],1
 mov byte[startkey],1
 mov byte[bxpos],15
 mov byte[bypos],39
 mov word[boardposy],32
 mov byte[addORsub+1],2
 mov byte[addORsub],1
 mov byte[changeFactors],1
 mov byte[changeFactors+1],0
 call clrscr
 cmp byte[level],5
 jne EXitSimplely
 mov byte[changeLevel],0
 mov byte[GameOver],1
 
EXitSimplely:
 pop es
 pop di
 pop si
 pop dx
 pop cx
 pop bx
 pop ax
 pop bp

 ret 4

kbisr:
 push ax
 push bx
 push cx
 push dx
 
 in al,0x60
 cmp byte[changeLevel],1
 je exit1
 cmp byte[waitOfStart],1
 je FirstExit1
 cmp byte[startkey],1
 je FirstKey1

 cmp al,0x4b
 jne nextcmp

 cmp word[boardposy],1        ;left border condition
 je exit1

 push 0x07
 push word[boardposx]
 mov dx,[boardposy]
 add dx,13                 ;printing space to erase end of board using biosprint
 push dx
 push 1
 push boardspace
 call biosprint
 mov dx,[boardposy]
 dec dl
 cmp byte[bxpos],22
 jne gonow1
 cmp byte[bypos],dl
 jne gonow1
 cmp byte[addORsub+1],2
 jne gonow1
 mov byte[bxpos],23

gonow1:
 sub word[boardposy],1      ;changing board y position by 1
 call print
 jmp exit

FirstExit1:
 jmp FirstExit
 
FirstKey1:
 jmp FirstKey
 
exit1:
 jmp exit

nextcmp:
 cmp al,0x4d
 jne exit

 cmp word[boardposy],65   ;right border condition 65+14 = 79 as boardposy starts from 65 and is 14 bytes/words long
 je exit
 push 0x07             ; printing space to erase start of board using biosprint
 push word[boardposx]
 mov dx,[boardposy]
 push dx
 push 1
 push boardspace
 call biosprint

 mov dx,[boardposy]
 add dl,14
 cmp byte[bxpos],22
 jne gonow2
 cmp byte[bypos],dl
 jne gonow2
 cmp byte[addORsub+1],2
 jne gonow2
 mov byte[bxpos],23

gonow2:
 add word[boardposy],1      ;changing board y position by 1
 call print
 jmp exit

FirstExit:
 mov byte[waitOfStart],0
 jmp exit

FirstKey:
 call clrscr
 call print
 mov byte[startkey],0

exit:
 pop dx
 pop cx
 pop bx
 pop ax
 jmp far [cs:oldisr]

uball:
 push ax
 push dx
 push cx
 mov dx,0

;ball is not in range - lost
uballcmp0:
 cmp byte[bxpos],22
 jne uballcmp1
 
cmp01:
 mov dx,[boardposy]
 dec dl
 cmp dl,[bypos]
 jne cmp02
 cmp byte[addORsub+1],1
 jne cmp02
 mov byte[addORsub+1],0
 jmp uballExit
 
cmp02:
 mov dx,0
 mov dx,[boardposy]
 add dl,14
 cmp dl,[bypos]
 jne uballcmp1
 cmp byte[addORsub+1],0
 jne uballcmp1
 mov byte[addORsub+1],1
 jmp uballExit

uballcmp1:
 cmp byte[bxpos],23
 jnae cornerCASES
 mov byte[waitOfStart],1
 mov byte[startkey],1
 mov byte[bxpos],15
 mov byte[bypos],39
 mov byte[addORsub+1],2
 mov byte[addORsub],1
 mov byte[changeFactors],1
 mov byte[changeFactors+1],0
 sub byte[lives],1
 cmp byte[lives],0
 jne NEXT1
 mov byte[GameOver],1
 jmp uballExit

NEXT1:
 jmp uballExit

cornerCASES:

c1:
 cmp byte[bxpos],1
 jne c2
 cmp byte[bypos],1
 jne c2
 mov byte[addORsub],1
 mov byte[addORsub+1],1
 jmp uballExit
 
c2:
 cmp byte[bxpos],21
 jne c3
 cmp byte[bypos],1
 jne c3
 mov dx,0
 mov dx,[boardposy]
 cmp dl,1
 jne c3
 mov byte[addORsub],0
 mov byte[addORsub+1],0
 jmp uballExit
 
c3:
 cmp byte[bxpos],1
 jne c4
 cmp byte[bypos],78
 jne c4
 mov byte[addORsub],1
 mov byte[addORsub+1],0
 jmp uballExit
 
c4:
 cmp byte[bxpos],21
 jne uballcmp2
 cmp byte[bypos],78
 jne uballcmp2
 cmp byte[boardposy],65
 jne uballcmp2
 mov byte[addORsub],0
 mov byte[addORsub+1],0
 jmp uballExit
 
uballcmp2:  ;this touches the right wall
 cmp byte[bypos],78
 jb uballcmp3

 mov byte[addORsub+1],0
 jmp uballExit

uballcmp3 ;this touches the left wall
 cmp byte[bypos],1
 jg uballcmp4

 mov byte[addORsub+1],1
 jmp uballExit

uballcmp4: ;This touches the upper wall
 cmp byte[bxpos],1
 jnle uballcmp5

 mov byte[addORsub],1
 jmp uballExit

uballcmp5:  
 cmp byte[bxpos],21
 jne uballExit2
 
BOARDcmp1: ;most left board
 mov ax,[boardposy]
 mov ah,0
 cmp byte[addORsub],1
 jne cmp001
 cmp byte[addORsub+1],1
 jne cmp001
 mov dl,[bypos]
 cmp dl,al
 jae cmp001
 
 add dl,[changeFactors+1]
 cmp dl,al
 jae task1
 
cmp001:
 cmp [bypos],al
 je task1
 add al,1
 cmp [bypos],al
 je task1
 add al ,1
 cmp [bypos],al
 je task1
 jmp BOARDcmp2
 
task1:
 mov byte[addORsub],0
 mov byte[addORsub+1],0
 mov byte[changeFactors+1],1
 jmp uballExit

uballExit2:
 jmp uballExit
 
BOARDcmp2:  ; centre
 add al ,1
 cmp [bypos],al
 jb uballExit
 add al ,7
 cmp [bypos],al
 ja BOARDcmp3
 
task2:
 mov byte[addORsub],0

 jmp uballExit
 
BOARDcmp3:
 add al,1
 cmp [bypos],al
 je task3
 add al,1
 cmp [bypos],al
 je task3
 add al ,1
 cmp [bypos],al
 je task3

 cmp byte[addORsub],1
 jne uballExit
 cmp byte[addORsub+1],0
 jne uballExit
 mov dl,[bypos]
 cmp dl,al
 jbe uballExit
 sub dl,[changeFactors+1]
 cmp dl,al
 jbe task3

 jmp uballExit
 
task3:
 mov byte[addORsub],0
 mov byte[addORsub+1],1
 mov byte[changeFactors+1],1
 
uballExit:
 call ApplyBAllCHanges
 
uballExitANDdont:
 pop cx
 pop dx
 pop ax
 ret

ApplyBAllCHanges:
 push ax
 mov ax,0
 cmp byte[addORsub],1
 jne ROWCMP2
 mov al,[changeFactors]
 add [bxpos],al

 jmp colcmp1
 
ROWCMP2:
 mov al,[changeFactors]
 sub [bxpos],al
 
colcmp1:
 cmp byte[addORsub+1],0
 jne colCMP2
 mov al,[changeFactors+1]
 sub [bypos],al
 cmp byte[bypos],1
 jnl ApplyBAllCHangesEXIT
 mov byte[bypos],1
 jmp ApplyBAllCHangesEXIT
 
colCMP2:
 cmp byte[addORsub+1],1
 jne ApplyBAllCHangesEXIT
 mov al,[changeFactors+1]
 add [bypos],al
 cmp byte[bypos],78
 jna ApplyBAllCHangesEXIT
 mov byte[bypos],78

ApplyBAllCHangesEXIT:
 pop ax

 ret

BRICKremovalsLevel:
 push ax
 push cx
 push di
 push bx
 push si
 push dx

 mov ax,0
 mov al,4
 mov cx,0
 mov cl,[level]
 mov bx,0
 
BRICKremovalsLevelLOOP:
 push bx
 push ax
 call BRICKremovals
 add al,2

 add bx,4
 loop BRICKremovalsLevelLOOP

 pop dx
 pop si
 pop bx
 pop di
 pop cx
 pop ax

 ret

timer:
 push ax
 push cx
 push di
 push bx

 cmp byte[GameOver],1
 je GameOverExit1
 cmp byte[changeLevel],1
 je GototimerExit2
 cmp byte[level],5
 je GameOverExit1
 cmp byte[waitOfStart],1
 je GototimerExit1
 
 cmp byte[tickcount],1
 jb skipTimer
 call print
 push 7
 push word[bxpos]
 push word[bypos]
 push 1
 push space
 call biosprint
 cmp byte[startkey],1
 je GototimerExit
 call uball
 call Printball
 call BRICKremovalsLevel

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 mov byte[tickcount],0
 jmp timerExit
 
GototimerExit2:
 jmp timerExit2
 
skipTimer:
 add byte[tickcount],1
 jmp timerExit
 
GototimerExit1:
 jmp timerExit1
 
GameOverExit1:
 call RetainBricks
 mov byte[waitOfStart],1
 mov byte[startkey],1
 mov byte[GameOver],0
 mov byte[lives],3
 mov byte[changeLevel],0
 mov word[boardposy],32
 cmp byte[level],5
 je SkipTHISshi
 mov al,byte[brickCounter]
 mov bl,5
 mul bl
 sub byte[score],al
 mov byte[brickCounter],0
 jmp GototimerExit
 
SkipTHISshi:
 mov byte[brickCounter],0
 mov byte[score],0
 mov byte[level],1
 call clrscr
 
GototimerExit:
 push 7
 push 15
 push 35
 push 9
 push GameOverMessage
 call biosprint

 jmp timerExit
 
timerExit1:
 push 7
 push 17
 push 30
 push 20
 push startMessege
 call biosprint
 jmp timerExit

timerExit2:
 push 0x30
 push 13
 push 34
 push 6
 push array1
 call biosprint
 mov ax,34
 mov bl,80
 mul bl
 add ax,13
 mov bl,12
 mul bl
 add ax,86
 push ax
 mov ax,0
 mov al,[level]
 push ax
 call printnum
 
 cmp byte[tickcount],20
 jne timerExit3
 mov byte[changeLevel],0
 mov byte[tickcount],0
 call clrscr
 jmp timerExit
 
timerExit3:
 add byte[tickcount],1
 jmp timerExit
 
timerExit:
 mov al, 0x20
 out 0x20, al ; end of interrupt
 pop bx
 pop di
 pop cx
 pop ax
 iret ; return from interrupt

start:
 call clrscr
 mov ax,25;col of welcome message
 push ax
 mov ax,10;row of welcome message
 push ax
 mov ax,4;color of welcome message
 push ax
 mov ax,29; lenght of welcome
 push ax
 mov ax,welcome;msg to print
 push ax
 call PrintString
 mov ax,26 ;;; this is column of command 1
 push ax
 mov ax,13 ;; this is row of command 1
 push ax
 mov ax,2 ;;; color of command 1
 push ax
 mov ax,30 ;;; length of command 1
 push ax
 mov ax,command1
 push ax
 call PrintString
 mov ax,22 ; column of command 2 
 push ax
 mov ax,15 ;; row of command 2
 push ax
 mov ax,5 ;; color of command 2
 push ax
 mov ax,38;;;; this is message lenght in command 2 
 push ax
 mov ax,command2
 push ax
 call PrintString
 mov ax,25 ;; column of command 3
 push ax
 mov ax,17 ;;; row of command 3
 push ax
 mov ax,3 ;;; color of command 3
 push ax
 mov ax,32 ;;;; this is lenght of command 3
 push ax
 mov ax,command3
 push ax
 call PrintString
 mov ax,18; column of command 4
 push ax
 mov ax,20;row of command 4
 push ax
 mov ax,9;color
 push ax
 mov ax,58; this is lenght of command 4
 push ax
 mov ax,command4 ;message to print
 push ax
 call PrintString
 
_wait:
 xor ax, ax
    int 0x16
 
continue:
 mov ax,0
 mov es,ax
 mov ax,[es:9*4]
 mov bx,[es:9*4+2]
 mov [oldisr],ax
 mov [oldisr+2],bx

cli
 mov word[es:8*4],timer
 mov [es:8*4+2],cs
 sti
 
cli
 mov word[es:9*4],kbisr
 mov [es:9*4+2],cs
 sti
 
l1:
 jmp l1
 
 cli
 mov ax,[oldisr]
 mov bx,[oldisr+2]
 mov word[es:9*4],ax
 mov [es:9*4+2],bx
 sti

 mov ax,0x4c00
 int 0x21
 
;----------------------;;;;TITLE PAGE;;;;----------------------
welcome: db 'Welcome to Brick Breaker Game',0
command1: db "Use arrow keys to move around",0
command2: db "The game will be over if lives finish",0
command3: db "Press any key to start the game",0
command4: db "Taha Abdullah (000- 0000) and Abdullah Hissan (000- 0000)", 0
 call clrscr
