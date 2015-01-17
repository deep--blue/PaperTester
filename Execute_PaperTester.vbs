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
  Dim secDiff, mntDiff
  secDiff = DateDiff("s", hmsStart, hmsEnd)
  mntDiff = DateDiff("m", hmsStart, hmsEnd)
  getEndMsg = _
    "�J�n����:" & FormatDateTime(hmsStart, 4) & _
      ", �I������:" & FormatDateTime(hmsEnd, 4) & _
      ", �o�ߎ���:" & mntDiff & "��" & "�i" & secDiff & "�b�j"
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
pt.VerticalScrollRate = 0.85
pt.DatabaseSheetName = "Database"
pt.DataPrintCellAddress = "B3"
pt.DataIntervalRows = 2
pt.ConnectionString = ""

pt.Initialize

On Error Resume Next

'===== �{���� =====
'��PaperTester.xlsx�̑���R�}���h���VBScript�R�}���h�������ɓ\��t����B


'===== �㏈�� =====
On Error Goto 0
Set pt = Nothing
WScript.Echo "�y����I���z" & getEndMsg()
