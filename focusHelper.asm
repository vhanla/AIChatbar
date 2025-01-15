format PE GUI 4.0
entry start

include 'win32a.inc'

section '.code' code readable executable
start:
    ; Allow any process to set the foreground window
    push -1                    ; ASFW_ANY
    call [AllowSetForegroundWindow]

    ; Find the window by class name and window name
    push wndName               ; Window name 'AI Launcher'
    push wndClassName          ; Class name 'AIChatbarWnd'
    call [FindWindowA]
    test eax, eax              ; Check if the window handle is valid
    jz exit                    ; Exit if no window found

    ; Call SwitchToThisWindow
    push 1                     ; fUnknown parameter (TRUE)
    push eax                   ; hWnd (window handle)
    call [SwitchToThisWindow]

exit:
    ; Exit the program
    push 0
    call [ExitProcess]

section '.data' data readable writeable
wndClassName db 'AIChatbarWnd', 0
wndName db 'AI Launcher', 0

section '.idata' import data readable writeable
library kernel32, 'kernel32.dll', user32, 'user32.dll'

import kernel32, ExitProcess, 'ExitProcess'
import user32, FindWindowA, 'FindWindowA', AllowSetForegroundWindow, 'AllowSetForegroundWindow', SwitchToThisWindow, 'SwitchToThisWindow'
