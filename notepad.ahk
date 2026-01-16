#Persistent ; Keep script running indefinitely until explicitly stopped
SetTitleMatchMode, 2 ; Allow partial matching for window titles (helpful for targeting Notepad)

; Variable to store the last copied content
lastCopiedContent := ""

; Log file for debugging
logFile := "script_log.txt"
FileAppend, Script started at %A_Now%`n, %logFile%

; Start monitoring whether Notepad is open
Loop
{
    IfWinExist, ahk_class Notepad
    {
        FileAppend, Notepad opened at %A_Now%`n, %logFile%
        RestrictActions()  ; Start restricting when Notepad is opened
        Return  ; Exit loop when actions are restricted
    }
    ; Wait 1 second before checking again if Notepad is opened
    Sleep, 1000
}

RestrictActions()
{
    ; Hide script icon from taskbar/system tray
    Menu, Tray, Icon, , 1

    ; Automatically stop monitoring when Notepad is closed
    Loop
    {
        IfWinNotExist, ahk_class Notepad
        {
            FileAppend, Notepad closed at %A_Now%`n, script_log.txt
            ; Instead of exiting the script, just break the loop
            break
        }
        Sleep, 1000  ; Check every 1 second for Notepad closure
    }
}

; Detect and restrict paste action (Ctrl + V) for external content
#IfWinActive ahk_class Notepad

; Override Copy (Ctrl + C) to store the copied content
^c::
    Send ^c  ; Perform the copy action
    ClipWait, 1  ; Wait for the clipboard to contain data
    if !ErrorLevel {
        lastCopiedContent := Clipboard  ; Store the copied content (plain text)
        FileAppend, Last copied content updated at %A_Now%`n, script_log.txt
    }
return

; Override Paste (Ctrl + V)
^v::
    ClipWait, 1  ; Wait for the clipboard to contain data
    if ErrorLevel {
        MsgBox, Clipboard is empty. Cannot paste.
        return
    }

    ; Allow pasting if the clipboard content matches the last copied content
    if (Clipboard = lastCopiedContent) {
        Send ^v  ; Allow pasting
    } else {
        MsgBox, Pasting content from external sources is not allowed in Notepad.
        return
    }
return

; Allow normal Cut (Ctrl + X) in Notepad
^x::Send ^x

#IfWinActive ; End restriction for Notepad