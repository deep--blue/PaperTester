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

Dim ies(), idxIes(), ie
Redim ies(0)
Redim idxIes(0)
Dim doc
Dim elm

Dim wLoc, wSvc, wEnu, wIns
Set wLoc = CreateObject("WbemScripting.SWbemLocator")
Set wSvc = wLoc.ConnectServer
Set wEnu = wSvc.InstancesOf("Win32_Process")

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
  For Each wIns in wEnu
    If Not IsEmpty(wIns.ProcessId) _
      And wIns.Description = "iexplore.exe" Then
        pId = wIns.ProcessId
    End If
  Next
  ActivateWindow pId
  ActivateLastIE = pId
End Function

'�L�[�{�[�h����
Sub KeybdEvent(bVk, bScan, dwFlags, dwExtraInfo)
  Call xls.ExecuteExcel4Macro(Replace(Replace(Replace(Replace("CALL(""user32"",""keybd_event"",""JJJJJ"", %0, %1, %2, %3)", "%0", bVk), "%1", bScan), "%2", dwFlags), "%3", dwExtraInfo))
End Sub

'�X�N���[���V���b�g
Sub ScreenShot
  Call KeybdEvent(&H2C, 0, 1, 0)
  Call KeybdEvent(&H2C, 0, 3, 0)
  WScript.Sleep(2 * 1000)
  sht.Activate
  sht.Range("A" & idxPasteSS).Select
  sht.Paste
  idxPasteSS = idxPasteSS + EXCEL_ONEPAGE_ROWS
End Sub

'�X�N���[���V���b�g�i�A�N�e�B�u��ʁj
Sub ActiveScreenShot
  Call KeybdEvent(&H12, 0, 1, 0)
  ScreenShot
  Call KeybdEvent(&H12, 0, 3, 0)
End Sub

'=====�ʏ���=====

'�y�e�X�g�d�l���Ő������ꂽ����R�}���h�������ɋL������B �z


'===== �㏈�� =====
Set wLoc = Nothing
Set wEnu = Nothing
Set wSvc = Nothing
Set wIns = Nothing
Set elm = Nothing
Set doc = Nothing
Set sht = Nothing
Set ie = Nothing
For i = LBound(ies) to UBound(ies)
  Set ies(i) = Nothing
Next
Set sht = Nothing
Set xls = Nothing
Set wsh = Nothing
Set shl = Nothing

Msgbox "����������I�����܂����B"