[BITS 16]
[ORG 0000h]

mov 	ax, es
mov 	ds, ax 


;SCREEN REGION
xor 	ax, ax
mov 	al, 4        
mov 	[ds:3000h], al

;OBJECT POSITION
xor 	ax, ax
mov 	ax, 100  
mov 	[ds:3001h], ax

;WIDTH/LARGURA
xor 	ax, ax
mov 	ax, 200    ;[X]
mov 	[ds:3003h], ax

;HEIGHT/ALTURA
xor 	ax, ax
mov 	ax, 192    ;[Y]
mov 	[ds:3005h], ax

;LENGTH/COMPRIMENTO
xor 	ax, ax
mov 	ax, 30    ;[Z]
mov 	[ds:3009h], ax

;SIZE LINE REGION
xor 	ax, ax
mov 	ax, 64
mov  	[ds:3007h], ax

;SIZE LINE REGION 3D
xor 	ax, ax
mov 	ax, 30
mov  	[ds:300Bh], ax

;COLOR CODE LINES
xor 	ax, ax
mov 	al, 1Fh   ;Initial : white
mov 	[ds:3010h], al
xor 	ax, ax

;COLOR CODE AREA
xor 	ax, ax
mov 	al, 20h   ;Initial : Green
mov 	[ds:3011h], al
xor 	ax, ax

;SAVED REGION PAINT
xor 	ax, ax
mov 	ax, 0   
mov 	[ds:3012h], ax
xor 	ax, ax

;SAVED REGION PAINT 1
xor 	ax, ax
mov 	ax, 0   
mov 	[ds:3014h], ax
xor 	ax, ax

;SAVE ATUAL COLOR LINE
xor 	ax, ax
mov 	al, 0   
mov 	[ds:3016h], al
xor 	ax, ax

;SAVE ATUAL COLOR AREA
xor 	ax, ax
mov 	al, 0   
mov 	[ds:3017h], al
xor 	ax, ax

;ATUAL REGION
xor 	ax, ax        
mov 	[ds:3018h], ax   ;possivel alteracao
xor 	ax, ax

jmp 	__Start__



__Start__:	
	call 	__Set_Video_Mode
	call 	__Get_Info_Mode
	call 	__Set_Buffer_Video
	jmp 	__Paint_Quad_Ext

__Paint_Quad_Ext:
	call  	__Init_Quad
	call 	__Init_Quad_3D.ANG1
	jmp 	__Paint_Quad_Int
	
__Paint_Quad_Int:
	call 	__Paint_Front
	call 	__Paint_Up
	call 	__Paint_Side
	jmp 	__Wait_Key
	
;Set video mode
__Set_Video_Mode:
	mov 	ax, 4f02h	
	mov 	bx, 105h
	int 	10h
	xor 	bx, bx
	ret

;Get video mode info
__Get_Info_Mode:
	mov 	ax, 4f01h
	mov 	cx, 105h
	mov 	di, ModeInfo 
	int 	10h
	ret

;Initialize in Address 0A000:0000h and Screen Region
__Set_Buffer_Video:
	mov 	ax, WORD [ds:ModeInfo + 08h]
	mov 	es, ax 
	xor 	cx, cx
	ret

;Paint lines in Quadrilater
__Init_Quad:
	xor 	cx, cx
	xor 	dx, dx
	mov 	dx, [ds:3000h]  ;SCREEN REGION
	call 	__Set_Region_Inc
	call 	__Set_Color_Line
	xor 	di, di
	add 	di, WORD[ds:3001h]   ;OBJECT POSITION
	jmp		_Quad_Up
_Quad_Up:
	stosb
	inc 	cx
	cmp 	cx, WORD[ds:3003h]   ;WIDTH
	jne 	_Quad_Up
	xor 	cx, cx
	jmp 	_Quad_Right
_Quad_Right:
	call 	__Line_Down
	mov 	[es:di], al
	inc 	bx
	inc 	cx
	cmp 	cx, WORD[ds:3007h]    ;SIZE LINE REGION
	jne 	_Quad_Right
	xor 	cx, cx
	mov		cx, bx
	xor 	bx, bx
	mov 	bx, WORD[ds:3007h]
	cmp 	bx, 64
	jb 		_Region_Seted_Inc
	call 	__Set_Region_Inc
	call 	__Set_Color_Line
	jmp 	_Region_Seted_Inc
_Region_Seted_Inc:
	xor 	bx, bx
	mov 	bx, cx
	xor 	cx, cx
	cmp 	bx, WORD[ds:3005h]   ;HEIGHT
	jne 	_Quad_Right
	xor 	bx, bx
	xor 	cx, cx
	jmp 	_Quad_Down
_Quad_Down:
	mov 	[es:di], al
	dec 	di
	inc 	cx
	cmp 	cx, WORD[ds:3003h] 		;WIDTH
	jne 	_Quad_Down
	xor 	cx, cx
	xor 	bx, bx
	sub 	dx, 2
	call 	__Set_Region_Dec
	call 	__Set_Color_Line
	jmp     _Quad_Left
_Quad_Left:
	call 	__Line_Up
	mov 	[es:di], al
	inc 	bx
	inc 	cx
	cmp 	cx, WORD[ds:3007h]    ;SIZE LINE REGION
	jne 	_Quad_Left
	xor 	cx, cx
	mov		cx, bx
	xor 	bx, bx
	mov 	bx, WORD[ds:3007h]
	cmp 	bx, 64
	jb 		_Region_Seted_Dec
	call 	__Set_Region_Dec
	call 	__Set_Color_Line
	jmp 	_Region_Seted_Dec
_Region_Seted_Dec:
	xor 	bx, bx
	mov 	bx, cx
	xor 	cx, cx
	cmp 	bx, WORD[ds:3005h]   ;HEIGHT
	jne 	_Quad_Left
	xor 	bx, bx
	xor 	cx, cx
	jmp 	Ret.Quad
Ret.Quad:
	ret
	
;Paint lines in quadrilater 3D
__Init_Quad_3D.ANG1:
	jmp 	_UpZ.Left_3D
_UpZ.Left_3D:
	call 	__Line_Up
	inc 	di
	mov 	[es:di], al
	inc 	bx
	inc 	cx
	cmp 	cx, WORD[ds:300Bh]    ;SIZE LINE REGION 3D
	jne 	_UpZ.Left_3D
	xor 	cx, cx
	mov		cx, bx
	xor 	bx, bx
	mov 	bx, WORD[ds:300Bh]
	cmp 	bx, 64
	jb 		_Region_Seted_Dec_3D
	call 	__Set_Region_Dec
	call 	__Set_Color_Line
	jmp 	_Region_Seted_Dec_3D
	_Region_Seted_Dec_3D:
	xor 	bx, bx
	mov 	bx, cx
	xor 	cx, cx
	cmp 	bx, WORD[ds:3009h]   ;LENGTH
	jne 	_UpZ.Left_3D
	xor 	bx, bx
	xor 	cx, cx
	call 	__Set_Color_Line
	jmp 	_UpZ.Up_3D
_UpZ.Up_3D:
	stosb
	inc 	cx
	cmp 	cx, WORD[ds:3003h]   ;WIDTH
	jne 	_UpZ.Up_3D
	xor 	cx, cx
	xor 	bx, bx
	jmp 	_UpZ.Right_3D
_UpZ.Right_3D:
	call 	__Line_Down
	dec 	di
	mov 	[es:di], al
	inc 	bx
	inc 	cx
	cmp 	cx, WORD[ds:300Bh]    ;SIZE LINE REGION 3D
	jne 	_UpZ.Right_3D
	xor 	cx, cx
	mov		cx, bx
	xor 	bx, bx
	mov 	bx, WORD[ds:300Bh]
	cmp 	bx, 64
	jb 		_Region_Seted_Inc_3D
	call 	__Set_Region_Inc
	call 	__Set_Color_Line
	jmp 	_Region_Seted_Inc_3D
	_Region_Seted_Inc_3D:
	xor 	bx, bx
	mov 	bx, cx
	xor 	cx, cx
	cmp 	bx, WORD[ds:3009h]   ;LENGTH
	jne 	_UpZ.Right_3D
	xor 	bx, bx
	xor 	cx, cx
	call 	__Set_Color_Line
	jmp 	_RightZ
	
_RightZ:
	mov 	dx, [ds:3000h]  ;SCREEN REGION
	call 	__Set_Region_Inc
	call 	__Set_Color_Line
	jmp 	_RightZ.Left_3D
_RightZ.Left_3D:
	call 	__Line_Down
	mov 	[es:di], al
	inc 	bx
	inc 	cx
	cmp 	cx, WORD[ds:3007h]    ;SIZE LINE REGION
	jne 	_RightZ.Left_3D
	xor 	cx, cx
	mov		cx, bx
	xor 	bx, bx
	mov 	bx, WORD[ds:3007h]
	cmp 	bx, 64
	jb 		_Region_Seted_Inc_L3D
	call 	__Set_Region_Inc
	call 	__Set_Color_Line
	jmp 	_Region_Seted_Inc_L3D
	_Region_Seted_Inc_L3D:
	xor 	bx, bx
	mov 	bx, cx
	xor 	cx, cx
	cmp 	bx, WORD[ds:3005h]   ;HEIGHT
	jne 	_RightZ.Left_3D
	xor 	bx, bx
	xor 	cx, cx
	mov 	[es:di], al
	dec 	dx
	dec 	dx
	call 	__Set_Region_Dec
	call 	__Set_Color_Line
	jmp 	_RightZ.Down_3D
_RightZ.Down_3D:
	call 	__Line_Up
	inc 	di
	mov 	[es:di], al
	inc 	bx
	inc 	cx
	cmp 	cx, WORD[ds:300Bh]    ;SIZE LINE REGION 3D
	jne 	_RightZ.Down_3D
	xor 	cx, cx
	mov		cx, bx
	xor 	bx, bx
	mov 	bx, WORD[ds:300Bh]
	cmp 	bx, 64
	jb 		_Region_Seted_Dec_D3D
	call 	__Set_Region_Dec
	call 	__Set_Color_Line
	jmp 	_Region_Seted_Dec_D3D
	_Region_Seted_Dec_D3D:
	xor 	bx, bx
	mov 	bx, cx
	xor 	cx, cx
	cmp 	bx, WORD[ds:3009h]   ;LENGTH 30
	jne 	_RightZ.Down_3D
	;xor 	bx, bx
	mov 	cx, bx
	jmp 	_RightZ.Right_3D
_RightZ.Right_3D:
	call 	__Line_Up
	mov 	[es:di], al
	inc 	bx
	inc 	cx
	cmp 	cx, WORD[ds:3007h]    ;SIZE LINE REGION
	jne 	_RightZ.Right_3D
	xor 	cx, cx
	mov 	cx, bx
	call 	__Set_Region_Dec
	call 	__Set_Color_Line
	mov 	bx, cx
	xor 	cx, cx
	cmp 	bx, WORD[ds:3005h]
	jne 	_RightZ.Right_3D
	xor 	bx, bx
	xor 	cx, cx
	jmp 	_Right_Rest
_Right_Rest:
	call 	__Line_Up
	mov 	[es:di], al
	inc 	cx
	cmp 	cx, WORD[ds:300Bh]
	jne 	_Right_Rest
	xor 	cx, cx
	jmp 	Ret.3D.ANG1
Ret.3D.ANG1:
	ret
	
__Paint_Front:
	mov 	cx, 63
	mov 	[ds:3007h], cx
	xor 	cx, cx
	xor 	bx, bx
	mov 	dx, [ds:3000h]  ;SCREEN REGION
	call 	__Set_Region_Inc
	call 	__Set_Color_Area
	xor 	di, di
	add 	di, WORD[ds:3001h]   ;OBJECT POSITION
	add 	di, 1024
	inc 	di
	mov 	al, [ds:3011h]
	mov 	[ds:3014h], bx
	xor 	dx, dx
	mov 	dx, WORD[ds:3003h]
	dec 	dx
	jmp 	_Paint
_Paint:
	stosb
	inc 	bx
	cmp 	bx, dx ;WORD[ds:3003h]
	jne 	_Paint
	sub 	di, bx
	add 	di, 1024
	xor 	bx, bx
	mov 	bx, WORD[ds:3014h]
	inc 	bx
	inc 	cx
	mov 	[ds:3014h], bx
	xor 	dx, dx
	mov 	dx, WORD[ds:3005h]
	dec 	dx
	cmp 	cx, dx  ;WORD[ds:3005h]
	je 		Ret.PaintFront
	cmp 	bx, WORD[ds:3007h]
	jne 	_ZeroBX
	jmp 	_Change_Region
	_ZeroBX:
		xor 	bx, bx
		xor 	dx, dx
		mov 	dx, WORD[ds:3003h]
		dec 	dx
		jmp 	_Paint
	_Change_Region:
		xor 	bx, bx
		xor 	dx, dx
		mov 	dx, WORD[ds:3018h]  ;possivel alteracao
		call 	__Set_Region_Inc
		call 	__Set_Color_Area
		mov 	[ds:3014h], bx
		mov 	bx, 64
		mov 	[ds:3007h], bx
		xor 	bx, bx
		xor 	dx, dx
		mov 	dx, WORD[ds:3003h]
		dec 	dx
		jmp 	_Paint
	Ret.PaintFront:
		xor 	bx, bx
		xor 	cx, cx
		xor 	dx, dx
		ret
	
__Paint_Up:
	xor 	cx, cx
	xor 	bx, bx
	mov 	dx, [ds:3000h]
	dec 	dx
	call 	__Set_Region_Dec
	call 	__Set_Color_Area
	xor 	di, di
	add 	di, WORD[ds:3001h]
	call 	__Line_Up
	add 	di, 2
	mov 	al, [ds:3011h]
	mov 	[ds:3014h], di
	xor 	dx, dx
	mov 	dx, WORD[ds:300Bh]
	dec 	dx
	jmp 	_Paint1
	_Paint1:
		stosb
		call 	__Line_Up
		inc 	cx
		cmp 	cx, dx  ;WORD[ds:300Bh]
		jne 	_Paint1
		xor 	cx, cx
		mov 	di, WORD[ds:3014h]
		inc 	di
		mov 	[ds:3014h], di
		xor 	dx, dx
		mov 	dx, WORD[ds:3003h]  ;200
		dec 	dx                  ;199
		inc 	bx
		cmp 	bx, dx
		jne 	_ZeroDX
		jmp 	Ret.PaintUp
	_ZeroDX:
		xor 	dx, dx
		mov 	dx, WORD[ds:300Bh]
		dec 	dx
		jmp 	_Paint1
	Ret.PaintUp:
		xor 	cx, cx
		xor 	bx, bx
		;mov 	[ds:3014h], bx
		ret
	
__Paint_Side:
	call 	__Set_Color_Area
	add 	di, 1
	mov 	[ds:3014h], di
	xor 	dx, dx
	xor 	bx, bx
	mov 	dx, WORD[ds:300Bh]
	sub 	dx, 2
	jmp 	_Paint2
	_Paint2:
		stosb
		call 	__Line_Up
		inc 	cx
		cmp 	cx, dx
		jne 	_Paint2
		xor 	cx, cx
		mov 	di, WORD[ds:3014h]
		inc 	di
		mov 	[ds:3014h], di
		dec 	dx
		inc 	bx
		cmp 	bx, 28
		jne 	_Paint2
		xor 	bx, bx
		xor 	cx, cx
		xor 	dx, dx
		mov 	dx, [ds:3000h]
		call 	__Set_Region_Inc
		call 	__Set_Color_Area
		sub 	di, 29
		call 	__Line_Down
		mov 	[ds:3014h], bx
		jmp 	_Paint3
	_Paint3:
		stosb
		inc 	cx
		cmp 	cx, 29
		jne 	_Paint3
		xor 	cx, cx
		sub 	di, 29
		call 	__Line_Down
		inc 	bx
		cmp 	bx, WORD[ds:3007h]
		jne 	_Paint3
		add 	[ds:3014h], bx
		xor 	bx, bx
		xor 	cx, cx
		mov 	cx, WORD[ds:3014h]
		cmp 	cx, 128
		jne 	_ZeroCX1
		xor 	bx, bx
		xor 	cx, cx
		call 	__Set_Region_Inc
		call 	__Set_Color_Area
		xor 	dx, dx
		xor 	cx, cx
		mov 	dx, 29
		jmp 	_Paint4
		_ZeroCX1:
			call 	__Set_Region_Inc
			call 	__Set_Color_Area
			xor 	cx, cx
			jmp 	_Paint3
	_Paint4:
		stosb
		inc 	cx
		cmp 	cx, dx	
		jne 	_Paint4
		xor 	cx, cx
		sub 	di, dx
		call 	__Line_Down
		inc 	bx
		call 	__Compare_BX
		cmp 	bx, 63
		jne 	_Paint4
		jmp 	Ret.PaintSide
	Ret.PaintSide:
		xor 	cx, cx
		xor 	bx, bx
		xor 	dx, dx
		mov 	[ds:3014h], bx
		ret
		
__Compare_BX:
	cmp 	bx, 34
	ja		_DecDX
	jmp 	Ret.CompareBX
	_DecDX:
		dec 	dx
		jmp 	Ret.CompareBX
Ret.CompareBX:
	ret
;Change Screen Region
__Set_Region_Inc: 
	mov 	ax, 4f05h
	mov 	bh, 0
	mov 	bl, 0
	int 	10h
	inc 	dx
	mov 	[ds:3018h], dx
	ret
	
__Set_Region_Dec: 
	mov 	ax, 4f05h
	mov 	bh, 0
	mov 	bl, 0
	int 	10h
	dec 	dx
	mov 	[ds:3018h], dx
	ret

;Change Object Color		
__Set_Color_Line:
	mov 	al, [ds:3010h]
	jmp 	Ret.SetColorLine
Ret.SetColorLine:
	ret
	
__Set_Color_Area:
	mov 	al, [ds:3011h]
	jmp 	Ret.SetColorArea
Ret.SetColorArea:
	ret
	
;Break Line Down
__Line_Down:
	add 	di, 1024
	ret
	
;Break Line Up
__Line_Up:
	sub 	di, 1024
	ret

__Wait_Key:
	xor 	ax, ax
	int 	16h
	cmp 	al, '+'
	je 		_Inc_Color_Line
	cmp 	al, '-'
	je 		_Dec_Color_Line
	cmp 	al, '*'
	je 		_Inc_Color_Area
	cmp 	al, '/'
	je 		_Dec_Color_Area
	cmp 	ah, 4Dh
	je 		_Mov_Right
	cmp 	ah, 4Bh
	je 		_Mov_Left
	cmp 	ah, 48h
	je 		_Mov_Up
	cmp 	ah, 50h
	je 		_Mov_Down
	cmp 	al, 4
	je 		_Copy_Quad
	cmp 	al, 'q'
	je 		_Change_Width
	jmp 	__Wait_Key
_Inc_Color_Line:
	mov 	al, [ds:3010h]
	inc 	al
	mov 	[ds:3010h], al
	jmp 	__Paint_Quad_Ext
_Dec_Color_Line:
	mov 	al, [ds:3010h]
	dec 	al
	mov 	[ds:3010h], al
	jmp 	__Paint_Quad_Ext
_Inc_Color_Area:
	mov 	al, [ds:3011h]
	inc 	al
	mov 	[ds:3011h], al
	jmp 	__Paint_Quad_Int
_Dec_Color_Area:
	mov 	al, [ds:3011h]
	dec 	al
	mov 	[ds:3011h], al
	jmp 	__Paint_Quad_Int
_Copy_Quad:
	xor 	ax, ax
	xor 	cx, cx
	mov 	ax, WORD[ds:3001h]
	mov 	cx, WORD[ds:3003h]
	add 	ax, cx
	mov 	cx, WORD[ds:3009h]
	add 	ax, cx
	add 	ax, 70
	mov 	[ds:3001h], ax
	jmp 	__Paint_Quad_Ext
_Mov_Right:
	call 	__Erase_Color
	call 	__Repaint_Quad
	xor 	ax, ax
	mov 	ax, WORD[ds:3001h]
	add 	ax, 8
	mov 	[ds:3001h], ax
	xor 	ax, ax
	call 	__Reput_Color
	call 	__Repaint_Quad
	jmp 	__Wait_Key

_Mov_Left:
	call 	__Erase_Color
	call 	__Repaint_Quad
	xor 	ax, ax
	mov 	ax, WORD[ds:3001h]
	sub 	ax, 8
	mov 	[ds:3001h], ax
	xor 	ax, ax
	call 	__Reput_Color
	call 	__Repaint_Quad
	jmp 	__Wait_Key
_Mov_Up:
	call 	__Erase_Color
	call 	__Repaint_Quad
	xor 	ax, ax
	mov 	al, [ds:3000h]
	dec 	al
	mov 	[ds:3000h], al
	xor 	ax, ax
	call 	__Reput_Color
	call 	__Repaint_Quad
	jmp 	__Wait_Key
_Mov_Down:
	call 	__Erase_Color
	call 	__Repaint_Quad
	xor 	ax, ax
	mov 	al, [ds:3000h]
	inc 	al
	mov 	[ds:3000h], al
	xor 	ax, ax
	call 	__Reput_Color
	call 	__Repaint_Quad
	jmp 	__Wait_Key
	
_Change_Width:
	xor 	ax, ax
	int 	16h
	cmp 	ah, 4Dh
	je 		_Inc_Width
	cmp 	ah, 4Bh
	je 		_Dec_Width
	cmp 	al, 'q'
	jne	 	_Change_Width
	jmp 	__Wait_Key
	

_Inc_Width:
	call 	__Erase_Color
	call 	__Repaint_Quad
	xor 	ax, ax
	mov 	ax, WORD[ds:3003h]
	add 	ax, 8
	mov 	[ds:3003h], ax
	xor 	ax, ax
	call 	__Reput_Color
	call 	__Repaint_Quad
	jmp 	_Change_Width
_Dec_Width:	
	call 	__Erase_Color
	call 	__Repaint_Quad
	xor 	ax, ax
	mov 	ax, WORD[ds:3003h]
	sub 	ax, 8
	mov 	[ds:3003h], ax
	xor 	ax, ax
	call 	__Reput_Color
	call 	__Repaint_Quad
	jmp 	_Change_Width
	
__Repaint_Quad:
	call  	__Init_Quad
	call 	__Init_Quad_3D.ANG1
	call 	__Paint_Front
	call 	__Paint_Up
	call 	__Paint_Side
ret

__Erase_Color:
	mov 	al, [ds:3010h]
	mov 	[ds:3016h], al
	mov 	al, [ds:3011h]
	mov 	[ds:3017h], al
	mov 	al, 00h
	mov 	[ds:3010h], al
	mov 	al, 00h
	mov 	[ds:3011h], al
ret
	
__Reput_Color:
	mov 	al, [ds:3017h]
	mov 	[ds:3011h], al
	mov 	al, [ds:3016h]
	mov 	[ds:3010h], al
ret

;--------------------------------------
;		DATAS REFERENCE MEMORY

ModeInfo    TIMES 256 db 0

;--------------------------------------