#AutoIt3Wrapper_icon=main.ico
#include <GDIPlus.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <WinAPI.au3>
#include <Constants.au3>
#include <Misc.au3>

Global Const $settingsFile = "settings.ini"

FileInstall("cursor.png", "cursor.png")

Global $offsetX = 2
Global $offsetY = 5

Opt("TrayAutoPause", 0)
Opt("TrayMenuMode", 3)
TraySetIcon("tray-icon.ico")
$trayItemTy = TrayCreateItem("Special Thanks! Fritz Webering[fritz@webering.eu]")
$trayItemMake = TrayCreateItem("Make by El Diana[fluera1@gmail.com]")
$trayItemExit = TrayCreateItem("Exit")

_GDIPlus_Startup()
Global $hImage = _GDIPlus_ImageLoadFromFile("cursor.png")
Global $overlayWidth = _GDIPlus_ImageGetWidth($hImage)
Global $overlayHeight = _GDIPlus_ImageGetHeight($hImage)

Global $overlay = GUICreate("", $overlayWidth ,$overlayHeight,  -1, -1, BitOR($WS_POPUP,0), BitOr($WS_EX_TOPMOST, $WS_EX_TRANSPARENT, $WS_EX_LAYERED, $WS_EX_TOOLWINDOW))
SetBitmap($overlay, $hImage, 255)

Global $overlayVisible = False
Global $mouseDown = False
Global $mouseX = MouseGetPos(0), $mouseY = MouseGetPos(1)
Global $temp = 0

While True
   $gw2handle = WinGetHandle("[TITLE:Guild Wars 2; CLASS:ArenaNet_Dx_Window_Class]")
   $clientArea = _WinAPI_GetClientRect($gw2handle)
   $mouse = _WinAPI_GetMousePos()
   $mouseX = DllStructGetData($mouse, "X")
   $mouseY = DllStructGetData($mouse, "Y")
   $hwnd = _WinAPI_WindowFromPoint($mouse)
   _WinApi_ScreenToClient($hwnd, $mouse)
   If Not _IsPressed(2) Then
	  HideOverlay()
	  $temp = 0
   EndIf
   If $temp == 1 Then
	  ContinueLoop
   EndIf

   If _IsPressed(2) Then
	  $temp = 1
	  If $hwnd == $gw2handle And RectContains($clientArea, $mouse) Then
		 If Not $overlayVisible Then ShowOverlay()
			MoveOverlay($mouseX, $mouseY)
		 Else
			If $overlayVisible Then HideOverlay()
	  EndIf
   Endif

   Switch TrayGetMsg()
	  Case $trayItemTy
	  Case $trayItemMake
      Case $trayItemExit
         Exit 0
   EndSwitch
WEnd

Func MoveOverlay($x, $y)
   Global $overlay, $offsetX, $offsetY
   WinMove($overlay, "", $x - $offsetX, $y - $offsetY)
EndFunc

Func ShowOverlay()
   Global $overlay, $overlayVisible = True
   GUISetState(@SW_SHOWNOACTIVATE, $overlay)
   if _IsPressed(2) then
	  Local $mouse = MouseGetPos()
   EndIf
   MoveOverlay($mouseX, $mouseY)
EndFunc

Func HideOverlay()
   Global $overlay, $overlayVisible = False
   GUISetState(@SW_HIDE, $overlay)
EndFunc

Func RectContains($rectangle, $point)
   Local $left = DllStructGetData($rectangle, "Left")
   Local $right = DllStructGetData($rectangle, "Right")
   Local $top = DllStructGetData($rectangle, "Top")
   Local $bottom = DllStructGetData($rectangle, "Bottom")
   Local $x = DllStructGetData($point, "X")
   Local $y = DllStructGetData($point, "Y")
   Return $x >= $left And $x < $right And $y >= $top And $y < $bottom
EndFunc


; Courtesy of Pinguin94 (http://autoit.de/index.php?page=Thread&threadID=17900)
Func SetBitmap($hGUI, $hImage, $iOpacity)
   Local $hScrDC, $hMemDC, $hBitmap, $hOld, $pSize, $tSize, $pSource, $tSource, $pBlend, $tBlend
   Local Const $AC_SRC_ALPHA = 1

   $hScrDC = _WinAPI_GetDC(0)
   $hMemDC = _WinAPI_CreateCompatibleDC($hScrDC)
   $hBitmap = _GDIPlus_BitmapCreateHBITMAPFromBitmap($hImage)
   $hOld = _WinAPI_SelectObject($hMemDC, $hBitmap)
   $tSize = DllStructCreate($tagSIZE)
   $pSize = DllStructGetPtr($tSize)
   DllStructSetData($tSize, "X", _GDIPlus_ImageGetWidth($hImage))
   DllStructSetData($tSize, "Y", _GDIPlus_ImageGetHeight($hImage))
   $tSource = DllStructCreate($tagPOINT)
   $pSource = DllStructGetPtr($tSource)
   $tBlend = DllStructCreate($tagBLENDFUNCTION)
   $pBlend = DllStructGetPtr($tBlend)
   DllStructSetData($tBlend, "Alpha", $iOpacity)
   DllStructSetData($tBlend, "Format", $AC_SRC_ALPHA)
   _WinAPI_UpdateLayeredWindow($hGUI, $hScrDC, 0, $pSize, $hMemDC, $pSource, 0, $pBlend, $ULW_ALPHA)
   _WinAPI_ReleaseDC(0, $hScrDC)
   _WinAPI_SelectObject($hMemDC, $hOld)
   _WinAPI_DeleteObject($hBitmap)
   _WinAPI_DeleteDC($hMemDC)
EndFunc   ;==>SetBitmap