#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.

; Modifiers
; ! = alt
; + = shift
; ^ = ctrl
; # = Winkey

Capslock::Esc ; Capslock -> Escape

; Changing workspaces - Ctrl+Alt+H/J/K/L, Ctrl+Alt+Shift+H/J/K/L
^!l::
Send, {Ctrl down}{LWin down}{Right}{LWin up}{Ctrl up}
return

^!h::
Send, {Ctrl down}{LWin down}{Left}{LWin up}{Ctrl up}
return

; Move window workspaces (requires MoveToDesktop)
^!+l::
Send, {Alt down}{LWin down}{Right}{LWin up}{Alt up}
return

^!+h::
Send, {Alt down}{LWin down}{Left}{LWin up}{Alt up}
return

; Maximizing/Restoring window - Super+J/K
#k::
Send, {LWin down}{Up}{LWin up}
return

#j::
Send, {LWin down}{Down}{LWin up}
return

; Move window to right/left - Super+H/L
#l::
Send, {LWin down}{Right}{LWin up}
return

#h::
Send, {LWin down}{Left}{LWin up}
return

; Move window across monitors - Shift+Super+H/J/K/L
+#h::
Send, {Shift Down}{LWin down}{Left}{LWin up}{Shift up}
return

+#j::
Send, {Shift Down}{LWin down}{Down}{LWin up}{Shift up}
return

+#k::
Send, {Shift Down}{LWin down}{Up}{LWin up}{Shift up}
return

+#l::
Send, {Shift Down}{LWin down}{Right}{LWin up}{Shift up}
return

; Open alacritty with ctrl+alt+t
^!t::
Run, %A_ProgramFiles%\Alacritty\alacritty.exe
return
