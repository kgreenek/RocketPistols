.486
.model flat,stdcall
option casemap:none

WinMain proto :DWORD,:DWORD,:DWORD,:DWORD

include \masm32\include\windows.inc
include \masm32\include\user32.inc
include \masm32\include\kernel32.inc
include \masm32\include\gdi32.inc

includelib \masm32\lib\gdi32.lib
includelib \masm32\lib\user32.lib
includelib \masm32\lib\kernel32.lib

.DATA
ClassName db "WinClass",0
AppName db "RocketPistols! ..::KG::..",0
LMouseClick db 0
Play db "Play",0
Quit db "Quit",0
Menu db "MainMenu",0
About_string db "About",0
About1_string db "Version 1.0.2.1 ©2004-2005",13,10
About4_string db "Programming by Kevin Greene",13,10
About7_string db "Email me at wannaski23@gmail.com",13,10,13,10
 
About2_string db "Bitmaps by Gordon Shirts",13,10,13,10

About3_string db "Many Thanks to Iczelion tuts @",13,10
About6_string db "http://win32assembly.online.fr/",13,10,13,10

About5_string db "        Thank you for playing!",0
gamedll db "ROCKETPISTOLS.DLL",0
Controls db "          LEFT          RIGHT",13,10,13,10
Controls2 db "UP          w          up arrow",13,10
Controls3 db "DOWN    s          down arrow",13,10
Controls4 db "FIRE       f           Num 0",13,10,13,10
Controls5 db "Make sure that caps is off",13,10
Controls6 db "And NumLock is on",0
Controls7 db "Controls",0

.const
IDI_I equ 11
IDI_IS equ 12
IDC_C equ 21
IDM_PLAY equ 1
IDM_EXIT equ 2
IDM_ABOUT equ 3
IDM_CONTROLS equ 4
IDB_BACKG equ 100

.DATA?
hInstance HINSTANCE ?
CommandLine LPSTR ?
backg dd ?

.CODE
begin:
	invoke GetModuleHandle,NULL
	mov hInstance,eax
	invoke GetCommandLine
	mov CommandLine,eax
	invoke WinMain,hInstance,NULL,CommandLine,SW_SHOWDEFAULT
	invoke ExitProcess,eax

WinMain proc hInst:HINSTANCE,hPI:HINSTANCE,CmdLine:LPSTR,CmdShow:DWORD
	LOCAL wc:WNDCLASSEX
	LOCAL msg:MSG
	LOCAL hwnd:HWND
	mov wc.cbSize,SIZEOF WNDCLASSEX
	mov wc.style,CS_HREDRAW or CS_VREDRAW
	mov wc.lpfnWndProc,OFFSET WndProc
	mov wc.cbClsExtra,NULL
	mov wc.cbWndExtra,NULL
	push hInst
	pop wc.hInstance
	invoke LoadBitmap,hInstance,IDB_BACKG
	mov backg,eax
	invoke CreatePatternBrush,eax
	mov   wc.hbrBackground,eax
    	mov   wc.lpszMenuName,OFFSET Menu
    	mov   wc.lpszClassName,OFFSET ClassName
    	invoke LoadIcon,hInstance,IDI_I
   	mov   wc.hIcon,eax
	invoke LoadIcon,hInstance,IDI_IS
   	mov   wc.hIconSm,eax
    	invoke LoadCursor,hInstance,IDC_C
    	mov   wc.hCursor,eax
    	invoke RegisterClassEx, addr wc
    	invoke CreateWindowEx,NULL,ADDR ClassName,ADDR AppName,\
           WS_OVERLAPPEDWINDOW-WS_SIZEBOX-WS_MINIMIZEBOX-WS_MAXIMIZEBOX,CW_USEDEFAULT,\
           CW_USEDEFAULT,200,215,NULL,NULL,\
           hInst,NULL
    	mov   hwnd,eax
    	invoke ShowWindow, hwnd,CmdShow
    	invoke UpdateWindow, hwnd
        .WHILE TRUE
                invoke GetMessage, ADDR msg,NULL,0,0
                .BREAK .IF (!eax)
                invoke TranslateMessage, ADDR msg
                invoke DispatchMessage, ADDR msg
        .ENDW
        mov     eax,msg.wParam
        ret
WinMain endp

WndProc proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
    	LOCAL hdc:HDC
    	LOCAL ps:PAINTSTRUCT
    	LOCAL rect:RECT
    	.IF uMsg==WM_DESTROY
        	invoke PostQuitMessage,NULL
	.ELSEIF uMsg==WM_COMMAND
		mov eax,wParam
		.IF ax==IDM_PLAY
yeah:
			
			invoke LoadLibrary,ADDR gamedll
			.IF eax!=NULL
				invoke FreeLibrary,eax
			.ENDIF
			
		.ELSEIF ax==IDM_ABOUT
			invoke MessageBox,NULL,ADDR About1_string,OFFSET About_string,MB_OK
		.ELSEIF ax==IDM_CONTROLS
			invoke MessageBox,NULL,ADDR Controls,OFFSET Controls7,MB_OK
		.ELSE
			invoke SendMessage,hWnd,WM_DESTROY,NULL,NULL
		.ENDIF
    	.ELSEIF uMsg==WM_LBUTTONDOWN
		jmp yeah
	.ELSE
        	invoke DefWindowProc,hWnd,uMsg,wParam,lParam
        	ret
    	.ENDIF
    	xor   eax, eax
    	ret
WndProc endp 



end begin