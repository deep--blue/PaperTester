'=====  �ݒ�  =====
'�X�N���[���V���b�g��EXCEL�֓\��t����s�Ԋu
Dim EXCEL_ONEPAGE_ROWS
EXCEL_ONEPAGE_ROWS = 61

'===== �O���� =====
Dim i, j, k
Dim wsh
Set wsh = WScript.CreateObject("WScript.Shell")
Dim shl
Set shl = CreateObject("Shell.Application")
Dim xls, sht
Set xls = WScript.CreateObject("Excel.Application")
xls.Application.Visible = True
xls.Application.DisplayAlerts = False
xls.Application.Workbooks.Add
Set sht = xls.Worksheets(1)

Dim ie
Dim doc
Dim elm

Dim idxPasteSS
idxPasteSS = 1

'IE�̑J�ڑ҂�
Sub IEWait(ie)
  Do While ie.Busy = True Or ie.readyState <> 4
  Loop
  Set doc = ie.document
End Sub

'�w��E�B���h�E�̃A�N�e�B�u��
Sub ActivateWindow(processId)
  While not wsh.AppActivate(processId) 
    Wscript.Sleep 100 
  Wend 
End Sub

'�Ō�ɋN������IE�̃A�N�e�B�u��
Function ActivateLastIE()
  Dim pId
  pId = -1
  Dim wLoc, wSvc, wEnu, wIns
  Set wLoc = CreateObject("WbemScripting.SWbemLocator")
  Set wSvc = wLoc.ConnectServer
  Set wEnu = wSvc.InstancesOf("Win32_Process")
  For Each wIns in wEnu
    If Not IsEmpty(wIns.ProcessId) _
      And wIns.Description = "iexplore.exe" Then
        pId = wIns.ProcessId
    End If
  Next
  ActivateWindow pId
  Set wEnu = Nothing
  Set wIns = Nothing
  Set wSvc = Nothing
  Set wLoc = Nothing
  ActivateLastIE = pId
End Function

'��ʃT�C�Y�ύX
Sub ShowWindow(hwindow, cmdshow)
  xls.ExecuteExcel4Macro "CALL(""user32"", ""ShowWindow"", ""JJJ"", " & hwindow & ", " & cmdshow & ")"
End Sub

'�L�[�{�[�h����
Sub KeybdEvent(bVk, bScan, dwFlags, dwExtraInfo)
  xls.ExecuteExcel4Macro "CALL(""user32"",""keybd_event"",""JJJJJ"", " & bVk & ", " & bScan & ", " & dwFlags & ", " & dwExtraInfo & ")"
End Sub

'�X�N���[���V���b�g
Sub ScreenShot
  Call KeybdEvent(&H2C, 0, 1, 0)
  Call KeybdEvent(&H2C, 0, 3, 0)
  WScript.Sleep(3 * 1000)
  sht.Activate
  sht.Range("A" & idxPasteSS).Select
  sht.Paste
  wsh.Run "cmd.exe /c echo. >NUL  | clip", 0, True
  idxPasteSS = idxPasteSS + EXCEL_ONEPAGE_ROWS
End Sub

'�X�N���[���V���b�g�i�A�N�e�B�u��ʁj
Sub ActiveScreenShot
  'TODO:Alt+PrintScreen���@�\���Ȃ��B
  Call KeybdEvent(&H12, 0, 1, 0)
  ScreenShot
  Call KeybdEvent(&H12, 0, 3, 0)
End Sub

'=====�ʏ���=====
Set ie = CreateObject("InternetExplorer.Application")
ie.Visible = True
ActivateLastIE

ShowWindow ie.Hwnd, 3

ie.Navigate "http://bl.ocks.org/nezuQ/raw/9719897/"
IEWait(ie)

ScreenShot


Set elm = doc.getElementById("ddlSearchType")

elm.selectedIndex = 1

Set elm = doc.getElementById("txtPHPSessID")

elm.Value = "0"

Set elm = doc.getElementsByTagName("input")(5)

elm.Click
IEWait(ie)

Set ie = shl.Windows(shl.Windows.Count - 1)
ActivateLastIE
IEWait(ie)

WScript.Sleep(3 * 1000)

ScreenShot

ie.Quit
Set ie = Nothing

Set ie = shl.Windows(shl.Windows.Count - 1)
ActivateLastIE
IEWait(ie)

ie.Quit
Set ie = Nothing



'===== �㏈�� =====
Set elm = Nothing
Set doc = Nothing
Set sht = Nothing
Set ie = Nothing
Set sht = Nothing
Set xls = Nothing
Set wsh = Nothing
Set shl = Nothing

Msgbox "����������I�����܂����B"