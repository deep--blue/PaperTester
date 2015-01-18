Option Explicit

'===== ���C�Z���X =====
'PaperTester
'Copyright (c) 2014 nezuq
'This software is released under the MIT License.
'https://github.com/nezuQ/PaperTester/blob/master/LICENSE.txt

'===== �O���� =====
Dim hmsStart
hmsStart = Now
Dim fso
Set fso = WScript.CreateObject("Scripting.FileSystemObject")
Execute fso.OpenTextFile(".\PaperTester.vbs", 1, False).ReadAll()
Set fso = Nothing
Dim pt
Set pt = New PaperTester

'�I�����b�Z�[�W�̎擾
Private Function getEndMsg()
  Dim hmsEnd
  hmsEnd = Now
  Dim mntDiff
  mntDiff = DateDiff("n", hmsStart, hmsEnd)
  getEndMsg = _
    "�J�n����=" & FormatDateTime(hmsStart, 4) & _
      ", �I������=" & FormatDateTime(hmsEnd, 4) & _
      ", �o�ߎ���=" & mntDiff & "��" 
End Function

'��O����
Private Sub onErrorExit(msg)
  Dim msgErr
  If (Err.Number <> 0) Then
    msgErr = _
      "�y�ُ�I���z" & getEndMsg() & vbCrLf _
      & "��O�ԍ� : " & Err.Number & vbCrLf _
      & "��O���� : " & Err.Description & vbCrLf _
      & "�ǉ����� : " & msg
    pt.Terminate
    WScript.Echo msgErr
    WScript.Quit
  End If
End Sub

'===== �ݒ�l =====
pt.EvidenceBookPath = ".\EvidenceTemplate.xlsx"
pt.ScreenshotSheetName = "Screenshot"
pt.ScreenshotPrintCellAddress = "B3"
pt.ScreenshotPageRows = 62
pt.AfterValidationLogRows = 2
pt.VerticalScrollRate = 0.80
pt.DatabaseSheetName = "Database"
pt.DataPrintCellAddress = "B3"
pt.DataIntervalRows = 2
Dim fs
Set fs = CreateObject("Scripting.FileSystemObject")
pt.ConnectionString = "Provider=Microsoft.ACE.OLEDB.12.0; Data Source=" & fs.GetAbsolutePathName(".\_database.xlsx") & "; Extended Properties=""Excel 8.0;HDR=Yes; [IMEX=1;]"";"
Set fs = Nothing

pt.Initialize

On Error Resume Next

'===== �{���� =====
'��PaperTester.xlsx�̑���R�}���h���VBScript�R�}���h�������ɓ\��t����B

pt.Open : onErrorExit "�e�X�g�P�[�X = 1, Excel�s = 2"
pt.Navigate "http://bl.ocks.org/nezuQ/raw/9719897/" : onErrorExit "�e�X�g�P�[�X = 1, Excel�s = 3"
pt.MaximumWindow : onErrorExit "�e�X�g�P�[�X = 1, Excel�s = 4"
pt.FullScreenShot4VisibleArea "1" : onErrorExit "�e�X�g�P�[�X = 1, Excel�s = 5"
pt.Record2ValidateAttribute "id=ddlEndpoint <- '0' %|% id=txtQuery <- '���������� '" : onErrorExit "�e�X�g�P�[�X = 1, Excel�s = 6"
pt.ExecuteSQL "SELECT * FROM [Sheet1$] " : onErrorExit "�e�X�g�P�[�X = , Excel�s = 7"

pt.KeyInput "id=txtQuery <- '{DEL 19}'" : onErrorExit "�e�X�g�P�[�X = 2-1, Excel�s = 9"
pt.PasteInput "id=txtQuery <- '���u���C�u�I ' %|% id=txtPHPSessID <- '0'" : onErrorExit "�e�X�g�P�[�X = 2-1, Excel�s = 10"
pt.FullScreenShot "2-1" : onErrorExit "�e�X�g�P�[�X = 2-1, Excel�s = 11"
pt.Click "tag=input#4" : onErrorExit "�e�X�g�P�[�X = 2-1, Excel�s = 12"
pt.ActivateChildWindow : onErrorExit "�e�X�g�P�[�X = 2-1, Excel�s = 13"
pt.FullScreenShot "" : onErrorExit "�e�X�g�P�[�X = 2-1, Excel�s = 14"
pt.ExecuteSQL "SELECT * FROM [Sheet2$] " : onErrorExit "�e�X�g�P�[�X = 2-1, Excel�s = 15"
pt.Close : onErrorExit "�e�X�g�P�[�X = 2-1, Excel�s = 16"
pt.ValueInput "id=ddlEndpoint <- '1' %|% id=ddlSearchType <- '1' %|% id=txtQuery <- '�͑����ꂭ�����' %|% id=txtPHPSessID <- ''" : onErrorExit "�e�X�g�P�[�X = 2-2, Excel�s = 17"
pt.FullScreenShot "2-2" : onErrorExit "�e�X�g�P�[�X = 2-2, Excel�s = 18"
pt.Click "tag=input#4" : onErrorExit "�e�X�g�P�[�X = 2-2, Excel�s = 19"
pt.ActivateChildWindow : onErrorExit "�e�X�g�P�[�X = 2-2, Excel�s = 20"
pt.FullScreenShot "" : onErrorExit "�e�X�g�P�[�X = 2-2, Excel�s = 21"
pt.ExecuteSQL "SELECT * FROM [Sheet1$] WHERE ��1 = 2" : onErrorExit "�e�X�g�P�[�X = 2-2, Excel�s = 22"

'===== �㏈�� =====
On Error Goto 0
Set pt = Nothing
WScript.Echo "�y����I���z" & getEndMsg()
