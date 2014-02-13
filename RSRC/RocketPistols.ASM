.486
.model flat,stdcall
option casemap:none

include \masm32\include\windows.inc
include \masm32\include\user32.inc
include \masm32\include\kernel32.inc
include \masm32\include\gdi32.inc
include \masm32\include\shell32.inc
includelib \masm32\lib\gdi32.lib
includelib \masm32\lib\user32.lib
includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\shell32.lib

WinMain proto :DWORD,:DWORD,:DWORD,:DWORD


.data
ClassName db "WinClass",0
AppName  db "Rocket Pistols! ..::Kevin Greene::..",0
hDCtext db "DISPLAY",0

RedWin db "  Red Wins!",0

BlueWin db " Blue Wins!",0
Rfiring dd 0
Lfiring dd 0

RFlag dd 0
LFlag dd 0
cmpvar dd 1

RedY dd 240
BlueY dd 240

RCount dd 0
LCount dd 0

TmpRLife dd 615
TmpLLife dd 10
RLife dd 1
LLife dd 1
Randy dd 1
Landy dd 1

LCanFire dd TRUE
RCanFire dd TRUE

QuitFlag dd 0



.const
REDX equ 574
BLUEX equ 30
IDI_I equ 11
IDI_IS equ 12
IDC_C equ 21
IDB_RMISSILE equ 31
IDB_LMISSILE equ 32
IDB_RED equ 33
IDB_BLUE equ 34
IDB_BACKG equ 100
IDB_LBOOM equ 35
IDB_RBOOM equ 36
IDB_LFIRING equ 37
IDB_RFIRING equ 38
IDB_LLIFE equ 39
IDB_RLIFE equ 40
IDB_RBAR equ 41
IDB_LBAR equ 42

.data?
hInstance HINSTANCE ?
CommandLine LPSTR ?


;bitmaps and hMemDC's
hBm_BackG dd ?
hBackDC dd ?
hdc dd ?
hBm_RMissile dd ?
hRMissileDC dd ?
hBm_LMissile dd ?
hLMissileDC dd ?
hBm_Red dd ?
hRedDC dd ?
hBm_Blue dd ?
hBlueDC dd ?
hBm_LBoom dd ?
hLBoomDC dd ?
hBm_RBoom dd ?
hRBoomDC dd ?
hBm_LFiring dd ?
hLFiringDC dd ?
hBm_RFiring dd ?
hRFiringDC dd ?
hBm_LLife dd ?
hLLifeDC dd ?
hBm_RLife dd ?
hRLifeDC dd ?
hBm_LBar dd ?
hLBarDC dd ?
hBm_RBar dd ?
hRBarDC dd ?

;timers
hLTimer dd ?
hRTimer dd ?
hRCount dd ?
hLCount dd ?

;coord vars
LMY dd ?
RMY dd ?
LMX dd ?
LMTX dd ?
RMX dd ?
RTmp dd ?
LTmp dd ?


.code
start proc hInst:DWORD,reason:DWORD,reserved1:DWORD
	.IF reason==DLL_PROCESS_ATTACH
		push hInst
		pop hInstance
		call Gameyeah
	.ENDIF
	mov eax,TRUE
	ret
start Endp

Gameyeah proc
	LOCAL wc:WNDCLASSEX
	LOCAL msg:MSG
 	LOCAL hwnd:HWND

	mov   wc.cbSize,SIZEOF WNDCLASSEX
	mov   wc.style, CS_HREDRAW or CS_VREDRAW
	mov   wc.lpfnWndProc, OFFSET WndProc
	mov   wc.cbClsExtra,NULL
	mov   wc.cbWndExtra,NULL
	push  hInstance
	pop   wc.hInstance
	mov   wc.hbrBackground,COLOR_ACTIVECAPTION+1
	mov   wc.lpszMenuName,NULL
	mov   wc.lpszClassName,OFFSET ClassName
	invoke LoadIcon,hInstance,IDI_I
	mov   wc.hIcon,eax
	invoke LoadIcon,hInstance,IDI_IS
	mov   wc.hIconSm,eax
	invoke LoadCursor,hInstance,IDC_C
	mov   wc.hCursor,eax
	invoke RegisterClassEx, addr wc
	INVOKE	CreateWindowEx,NULL,ADDR ClassName,ADDR AppName,\
		WS_OVERLAPPEDWINDOW-WS_THICKFRAME-WS_MAXIMIZEBOX-WS_MINIMIZEBOX,\
		CW_USEDEFAULT,CW_USEDEFAULT,640,545,NULL,NULL,hInstance,NULL
	mov   hwnd,eax
	invoke ShowWindow, hwnd, SW_SHOWNORMAL
	invoke UpdateWindow, hwnd
	.WHILE TRUE
		invoke GetMessage, ADDR msg,NULL,0,0
		.BREAK .IF (!eax)
		invoke TranslateMessage, ADDR msg
		invoke DispatchMessage, ADDR msg
	.ENDW
	mov     eax,msg.wParam
	ret
Gameyeah Endp

WndProc proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
	LOCAL ps:PAINTSTRUCT

	.IF uMsg==WM_CREATE
		invoke LoadBitmap,hInstance,IDB_BACKG
		mov hBm_BackG,eax
		invoke LoadBitmap,hInstance,IDB_RMISSILE
		mov hBm_RMissile,eax
		invoke LoadBitmap,hInstance,IDB_LMISSILE
		mov hBm_LMissile,eax
		invoke LoadBitmap,hInstance,IDB_RED
		mov hBm_Red,eax
		invoke LoadBitmap,hInstance,IDB_BLUE
		mov hBm_Blue,eax
		invoke LoadBitmap,hInstance,IDB_LBOOM
		mov hBm_LBoom,eax
		invoke LoadBitmap,hInstance,IDB_RBOOM
		mov hBm_RBoom,eax
		invoke LoadBitmap,hInstance,IDB_LFIRING
		mov hBm_LFiring,eax
		invoke LoadBitmap,hInstance,IDB_RFIRING
		mov hBm_RFiring,eax		
		invoke LoadBitmap,hInstance,IDB_LLIFE
		mov hBm_LLife,eax
		invoke LoadBitmap,hInstance,IDB_RLIFE
		mov hBm_RLife,eax
		invoke LoadBitmap,hInstance,IDB_RBAR
		mov hBm_RBar,eax
		invoke LoadBitmap,hInstance,IDB_LBAR
		mov hBm_LBar,eax

		invoke GetDC,hWnd
		mov hdc,eax
		invoke CreateCompatibleDC,hdc
		mov hBackDC,eax
		invoke SelectObject,hBackDC,hBm_BackG
		invoke CreateCompatibleDC,hdc
		mov hRMissileDC,eax
		invoke SelectObject,hRMissileDC,hBm_RMissile
		invoke CreateCompatibleDC,hdc
		mov hLMissileDC,eax
		invoke SelectObject,hLMissileDC,hBm_LMissile
		invoke CreateCompatibleDC,hdc
		mov hRedDC,eax
		invoke SelectObject,hRedDC,hBm_Red
		invoke CreateCompatibleDC,hdc
		mov hBlueDC,eax
		invoke SelectObject,hBlueDC,hBm_Blue
		invoke CreateCompatibleDC,hdc
		mov hRBoomDC,eax
		invoke SelectObject,hRBoomDC,hBm_RBoom
		invoke CreateCompatibleDC,hdc
		mov hLBoomDC,eax
		invoke SelectObject,hLBoomDC,hBm_LBoom
		invoke CreateCompatibleDC,hdc
		mov hLFiringDC,eax
		invoke SelectObject,hLFiringDC,hBm_LFiring
		invoke CreateCompatibleDC,hdc
		mov hRFiringDC,eax
		invoke SelectObject,hRFiringDC,hBm_RFiring
		invoke CreateCompatibleDC,hdc
		mov hLLifeDC,eax
		invoke SelectObject,hLLifeDC,hBm_LLife
		invoke CreateCompatibleDC,hdc
		mov hRLifeDC,eax
		invoke SelectObject,hRLifeDC,hBm_RLife
		invoke CreateCompatibleDC,hdc
		mov hRBarDC,eax
		invoke SelectObject,hRBarDC,hBm_RBar
		invoke CreateCompatibleDC,hdc
		mov hLBarDC,eax
		invoke SelectObject,hLBarDC,hBm_LBar

	.ELSEIF uMsg==WM_KEYDOWN
		mov eax,lParam
    		shr eax,30
    		and eax,1          
    		.IF eax      
        		xor eax,eax
        		ret
    		.ENDIF
		cmp wParam,VK_UP
		jz Rup
		cmp wParam,VK_DOWN
		jz Rdown
	.ELSEIF uMsg==WM_CHAR
		mov eax,lParam
    		shr eax,30
    		and eax,1          
    		.IF eax      
        		xor eax,eax
        		ret
    		.ENDIF
		cmp wParam,30h
		jz Rfire
		cmp wParam,77h
		jz Lup
		cmp wParam,73h
		jz Ldown
		cmp wParam,66h
		jz Lfire
		
	.ELSEIF uMsg==WM_PAINT
draw:
		invoke BeginPaint,hWnd,ADDR ps
		invoke BitBlt,hdc,0,0,640,480,hBackDC,0,0,SRCCOPY
		.IF Landy
			mov ebx,LLife
				invoke BitBlt,hdc,0,495,160,32,hLBarDC,0,32,SRCAND
				invoke BitBlt,hdc,0,495,160,32,hLBarDC,0,0,SRCPAINT
			.WHILE cmpvar!=ebx

				invoke BitBlt,hdc,TmpLLife,500,10,10,hLLifeDC,0,10,SRCAND
				invoke BitBlt,hdc,TmpLLife,500,10,10,hLLifeDC,0,0,SRCPAINT
				add TmpLLife,15
				inc cmpvar
			.ENDW

				mov TmpLLife,10
				mov cmpvar,1
				mov Landy,FALSE
				jmp draw
		.ENDIF
		.IF Randy
			mov ebx,RLife
				invoke BitBlt,hdc,475,495,160,32,hRBarDC,0,32,SRCAND
				invoke BitBlt,hdc,475,495,160,32,hRBarDC,0,0,SRCPAINT
			.WHILE cmpvar!=ebx
				invoke BitBlt,hdc,TmpRLife,500,10,10,hRLifeDC,0,10,SRCAND
				invoke BitBlt,hdc,TmpRLife,500,10,10,hRLifeDC,0,0,SRCPAINT
				sub TmpRLife,15
				inc cmpvar
			.ENDW
				mov TmpRLife,615
				mov cmpvar,1
				mov Randy,FALSE
				jmp draw
		.ENDIF

yeah:
		.IF Lfiring
			.IF LMX!=628
				.IF LMX==66
					invoke BitBlt,hdc,0,0,640,480,hBackDC,0,0,SRCCOPY
					invoke BitBlt,hdc,REDX,RedY,36,26,hRedDC,0,26,SRCAND
					invoke BitBlt,hdc,REDX,RedY,36,26,hRedDC,0,0,SRCPAINT
				.ENDIF
				invoke BitBlt,hdc,LMX,LMY,12,3,hRMissileDC,0,3,SRCAND
				invoke BitBlt,hdc,LMX,LMY,12,3,hRMissileDC,0,0,SRCPAINT
				invoke BitBlt,hdc,BLUEX,LTmp,36,34,hRFiringDC,0,34,SRCAND
				invoke BitBlt,hdc,BLUEX,LTmp,36,34,hRFiringDC,0,0,SRCPAINT
				inc LMX
				jmp yeah
			.ELSE
				.IF LCount==0
					sub LMY,39
					mov eax,LMX
					sub eax,85
					mov LMTX,eax
					inc LCount
					invoke SetTimer,hWnd,3,500,NULL
					mov hLCount,eax
					mov LFlag,TRUE
					jmp Rcmp
				.ELSE
					mov eax,BlueY
					sub eax,8
					mov LTmp,eax
					invoke BitBlt,hdc,REDX,RedY,36,26,hRedDC,0,26,SRCAND
					invoke BitBlt,hdc,REDX,RedY,36,26,hRedDC,0,0,SRCPAINT
					invoke BitBlt,hdc,BLUEX,LTmp,36,34,hRFiringDC,0,34,SRCAND
					invoke BitBlt,hdc,BLUEX,LTmp,36,34,hRFiringDC,0,0,SRCPAINT
				.ENDIF
			.ENDIF
		
		.ELSEIF Rfiring
			.IF RMX!=0
				.IF RMX==562
					invoke BitBlt,hdc,0,0,640,480,hBackDC,0,0,SRCCOPY
					invoke BitBlt,hdc,BLUEX,BlueY,36,26,hBlueDC,0,26,SRCAND
					invoke BitBlt,hdc,BLUEX,BlueY,36,26,hBlueDC,0,0,SRCPAINT
				.ENDIF
				invoke BitBlt,hdc,RMX,RMY,12,3,hLMissileDC,0,3,SRCAND
				invoke BitBlt,hdc,RMX,RMY,12,3,hLMissileDC,0,0,SRCPAINT
				invoke BitBlt,hdc,REDX,RTmp,36,34,hLFiringDC,0,34,SRCAND
				invoke BitBlt,hdc,REDX,RTmp,36,34,hLFiringDC,0,0,SRCPAINT
				dec RMX
				jmp yeah
			.ELSE
				.IF RCount==0
					sub RMY,39
					inc RCount
					invoke SetTimer,hWnd,4,500,NULL
					mov hRCount,eax
					mov RFlag,TRUE
					jmp Lcmp
				.ELSE
					mov eax,RedY
					sub eax,8
					mov RTmp,eax
					invoke BitBlt,hdc,BLUEX,BlueY,36,26,hBlueDC,0,26,SRCAND
					invoke BitBlt,hdc,BLUEX,BlueY,36,26,hBlueDC,0,0,SRCPAINT
					invoke BitBlt,hdc,REDX,RTmp,36,34,hLFiringDC,0,34,SRCAND
					invoke BitBlt,hdc,REDX,RTmp,36,34,hLFiringDC,0,0,SRCPAINT				
				.ENDIF
			.ENDIF
		.ELSE
			invoke BitBlt,hdc,REDX,RedY,36,26,hRedDC,0,26,SRCAND
			invoke BitBlt,hdc,REDX,RedY,36,26,hRedDC,0,0,SRCPAINT
			invoke BitBlt,hdc,BLUEX,BlueY,36,26,hBlueDC,0,26,SRCAND
			invoke BitBlt,hdc,BLUEX,BlueY,36,26,hBlueDC,0,0,SRCPAINT
		.ENDIF
		
		.IF LFlag
			invoke BitBlt,hdc,LMTX,LMY,90,78,hRBoomDC,0,78,SRCAND
			invoke BitBlt,hdc,LMTX,LMY,90,78,hRBoomDC,0,0,SRCPAINT
		.ENDIF
		.IF RFlag
			invoke BitBlt,hdc,RMX,RMY,90,78,hLBoomDC,0,78,SRCAND
			invoke BitBlt,hdc,RMX,RMY,90,78,hLBoomDC,0,0,SRCPAINT
		.ENDIF

		invoke EndPaint,hWnd,ADDR ps
	.ELSEIF uMsg==WM_TIMER
		cmp wParam,1
			jz Rcanfire
		cmp wParam,2
			jz Lcanfire
		cmp wParam,3
			jz Lyeah
		cmp wParam,4
			jz Ryeah
		xor eax,eax
		ret
	.ELSEIF uMsg==WM_DESTROY
		invoke DeleteObject,hBm_RMissile
		invoke DeleteObject,hBm_LMissile
		invoke DeleteObject,hBm_Red
		invoke DeleteObject,hBm_Blue
		invoke DeleteObject,hBm_RBoom
		invoke DeleteObject,hBm_LBoom
		invoke DeleteObject,hBm_BackG
		invoke DeleteObject,hBm_LLife
		invoke DeleteObject,hBm_RLife
		invoke DeleteObject,hBm_RBar
		invoke DeleteObject,hBm_LBar
		invoke ReleaseDC,hWnd,hdc
		invoke DeleteDC,hRMissileDC
		invoke DeleteDC,hLMissileDC
		invoke DeleteDC,hRedDC
		invoke DeleteDC,hBlueDC
		invoke DeleteDC,hRBoomDC
		invoke DeleteDC,hLBoomDC
		invoke DeleteDC,hBackDC
		invoke DeleteDC,hLLifeDC
		invoke DeleteDC,hRLifeDC
		invoke DeleteDC,hRBarDC
		invoke DeleteDC,hLBarDC
		.IF QuitFlag
		invoke DestroyWindow,hWnd
		.ENDIF
		invoke PostQuitMessage,NULL
	.ELSE
		invoke DefWindowProc,hWnd,uMsg,wParam,lParam
		ret
	.ENDIF
	xor eax,eax
	ret
Rup:
	.IF RedY>0
		sub RedY,20
	.ENDIF
	jmp draw
Rdown:
	.IF RedY<405
		add RedY,20
	.ENDIF
	jmp draw
Rfire:
	.IF Rfiring==0
		.IF RCanFire
			mov Rfiring,TRUE
			mov eax,RedY
			add eax,6
			mov RMY,eax
			mov RMX,562
			mov eax,RedY
			sub eax,8
			mov RTmp,eax
			mov RCanFire,FALSE
			invoke SetTimer,hWnd,1,1500,NULL
			mov hRTimer,eax
		.ENDIF
	.ENDIF
	jmp draw
Lup:
	.IF BlueY>0
		sub BlueY,20
	.ENDIF
	jmp draw
Ldown:
	.IF BlueY<405
		add BlueY,20
	.ENDIF
	jmp draw
Lfire:
	.IF Lfiring==0
		.IF LCanFire
			mov Lfiring,TRUE
			mov eax,BlueY
			add eax,6
			mov LMY,eax
			mov LMX,66
			mov eax,BlueY
			sub eax,8
			mov LTmp,eax
			mov LCanFire,FALSE
			invoke SetTimer,hWnd,2,1500,NULL
			mov hLTimer,eax
		.ENDIF
	.ENDIF
	jmp draw
Lcanfire:
	mov LCanFire,TRUE
	invoke KillTimer,hWnd,hLTimer
	xor eax,eax
	ret
Rcanfire:
	mov RCanFire,TRUE
	invoke KillTimer,hWnd,hRTimer
	xor eax,eax
	ret
Lyeah:
	invoke KillTimer,hWnd,hLCount
	mov Lfiring,FALSE
	mov LCount,0
	mov LFlag,0
	jmp draw
Ryeah:
	invoke KillTimer,hWnd,hRCount
	mov Rfiring,FALSE
	mov RCount,0
	mov RFlag,0
	jmp draw
Lcmp:
	mov eax,BlueY
	add eax,26
	cmp eax,RMY
	jg Lcmp2
	jmp draw
Lcmp2:
	mov eax,RMY
	add eax,78
	cmp BlueY,eax
	jl Lcmp3
	jmp draw
Lcmp3:
	add LLife,1
	.IF LLife>=11
			invoke BitBlt,hdc,RMX,RMY,90,78,hLBoomDC,0,78,SRCAND
			invoke BitBlt,hdc,RMX,RMY,90,78,hLBoomDC,0,0,SRCPAINT
		mov Landy,TRUE
		invoke MessageBox,NULL,ADDR RedWin,OFFSET RedWin,MB_OK
		jmp gameover
	.ENDIF
	mov Landy,TRUE
	jmp draw
Rcmp:
	mov eax,RedY
	add eax,26
	cmp eax,LMY
	jg Rcmp2
	jmp draw
Rcmp2:
	mov eax,LMY
	add eax,78
	cmp RedY,eax
	jl Rcmp3
	jmp draw
Rcmp3:
	add RLife,1
	.IF RLife>=11
			invoke BitBlt,hdc,LMTX,LMY,90,78,hRBoomDC,0,78,SRCAND
			invoke BitBlt,hdc,LMTX,LMY,90,78,hRBoomDC,0,0,SRCPAINT
		mov Randy,TRUE
		invoke MessageBox,NULL,ADDR BlueWin,OFFSET BlueWin,MB_OK
		jmp gameover
	.ENDIF
	mov Randy,TRUE
	jmp draw
gameover:
	mov QuitFlag,TRUE
	invoke SendMessage,hWnd,WM_DESTROY,NULL,NULL
	xor eax,eax
	ret	
WndProc endp

end start
