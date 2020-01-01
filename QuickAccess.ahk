SendMode Input
#SingleInstance Force
SetWorkingDir %A_ScriptDir%
CoordMode, Mouse, Screen

;====================================
;Quick Access Menu
;====================================
;This script creates a quick access wheel in Windows using Autohotkey, 
;that allows the user to use one hotkey to activate a number of other scripts or execute other actions within autohotkey
;The key the script listens for by default is 'F24' but this is modifiable by
;editing the two lines below that reference 'F24' to be whatever key you choose.
;
;=====User Changeable Variables======
ChNum := 6				;Amount of quick access options to display [1-(Technically as many as you want)] *Note: As the amount of choices increases it will become harder for the user to accurately choose an option, and the text may automatically shorten itself
global windowDia := 200			;Diameter of quick access menu
global dzPercent := 0.2			;Percent of quick access menu to be dead zone, where no option is chosen. [0-1] *Note: Since this script calculates which option is chosen irrelevant to the visual size of the wheel a value of 1 does not prevent the script from functioning correctly
global Color:="000000"			;Color of menu and dead zone. Valid entries are 6-digit hex strings or the color names specified here [https://www.autohotkey.com/docs/commands/Progress.htm#colors] contained within quotes
global FontSize := 12			;Font size of menu
global FontColor := "white"		;Font color. Valid entries are 6-digit hex strings or the color names specified here [https://www.autohotkey.com/docs/commands/Progress.htm#colors] contained within quotes
global TransparencyWheel := 175		;Transparency of menu [0(Transparent)-255(Opaque)]
global TransparencyDZ := 150		;Transparency of dead zone [0(Transparent)-255(Opaque)]
global inlayDist := 10			;The distance from the edge of the wheel where the option number is displayed
global PI:=3.1415			;Pi, do not change
global Choice := -1			;Do not change

Functions:				;Functions to be executed, add else if statements and populate as needed. There is no need to remove unused else if statements.
if(Choice == 0){
Send, #b {Right} {Space} ; Basic script to open the eject USB menu
}else if(Choice == 1){

}else if(Choice == 2){

}else if(Choice == 3){

}else if(Choice == 4){

}else if(Choice == 5){ 
Reload			; Reload this script
}else if(Choice == 6){

}
return

;====================================
; Code
;====================================

F24::													;HOTKEY: Edit this line to change the hotkey
Gui, DeadZone:Destroy											;Remove possible existing gui elements
Gui, Wheel:Destroy

MouseGetPos, InitMouseX, InitMouseY									;Find and calculate initial variables
windowRad := windowDia/2
dzDia := windowDia*dzPercent
dzRad := dzDia/2

Gui DeadZone:New											;DeadZone is an area in the circle that does not trigger a choice, to help avoid misclicks
Gui DeadZone:+LastFound +AlwaysOnTop -Caption +ToolWindow
Gui, DeadZone:Color, %Color%
WinSet, Transparent, %TransparencyDZ%
WinSet, Region, 0-0 W%dzDia% H%dzDia% E

Gui Wheel:New
Gui Wheel:+LastFound +AlwaysOnTop -Caption +ToolWindow  						;Wheel is the main gui element the user sees
Gui, Wheel:Color, %Color%
Gui, Wheel:Font, S%FontSize% C%FontColor%
WinSet, Transparent, %TransparencyWheel%
WinSet, Region, 0-0 W%windowDia% H%windowDia% E

Iter := 0												;Iterate around the wheel and put text with the number of the choice at the correct angle and distance
Loop %ChNum%
{
	Gui, Wheel:Add, Text, vControl%Iter%, %Iter%
	YCompLength := Cos((Iter + 0.5) * (360 / ChNum) * (PI / 180)) * (windowRad-inlayDist)		;Calculate the Y position where the text should be
	YCompLength := windowRad - YCompLength
	XCompLength := Sin((Iter + 0.5) * (360 / ChNum) * (PI / 180)) * (windowRad-inlayDist)		;Calculate the X position where the text should be
	XCompLength := windowRad + XCompLength
	GuiControlGet, Control%Iter%Data, Wheel:Pos, Control%Iter% 									;Get control information about the text that was just created
	GuiControl, Move, Control%Iter%, % "X" . (XCompLength - (Control%Iter%DataW/2)) . " Y" . YCompLength - (Control%Iter%DataH/2)	;Using the information from the last statement, place the text so it is centered on the calculated position
	Iter++
}
Gui, DeadZone:Show, % "X" . InitMouseX-dzRad . " Y" . InitMouseY-dzRad . " NoActivate " . "W" . dzDia . " H" . dzDia			;Display deadzone
Gui, Wheel:Show, % "X" . InitMouseX-windowRad . " Y" . InitMouseY-windowRad . " NoActivate " . "W" . windowDia . " H" . windowDia	;Display wheel

KeyWait, F24												;HOTKEY: Edit this line to change the hotkey
Gui, Wheel:Destroy											;Wait until the activating button is released, then destroy the displayed gui's
Gui, DeadZone:Destroy

Choice := GetChoice(InitMouseX, InitMouseY, ChNum)							;Call GetChoice
Gosub Functions												;Jump to the Functions label
return

GetChoice(InitMouseX, InitMouseY, ChNum)
{
	dzRad := windowDia*dzPercent/2
	MouseGetPos, CurrMouseX, CurrMouseY
	if(Abs(InitMouseX - CurrMouseX) < dzRad && Abs(InitMouseY - CurrMouseY) < dzRad)		;If the mouse is within the deadzone, exit function and return -1
		return -1
	CurrMouseX -= InitMouseX
	CurrMouseY -= InitMouseY
	CurrMouseX *= -1
	CurrMouseY *= -1
	ThetaDeg := ACos(CurrMouseX/(CurrMouseX**2 + CurrMouseY**2)**0.5) * 180 / PI			;Find degree of the mouse from the original mouse position
	ThetaDeg := Mod((((CurrMouseY > 0) ? (ThetaDeg) : (360 - ThetaDeg)) + 270), 360) 		; Convert 180 deg to 360, rotate to orientate 0 deg up
	return Round(ThetaDeg // (360/ChNum))								;Return which choice slice the mouse is located within
}
	