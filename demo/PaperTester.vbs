'=====  ���C�Z���X  =====
'The MIT License (MIT)
'
'Copyright (c) 2014 nezuq
'
'Permission is hereby granted, free of charge, to any person obtaining a copy
'of this software and associated documentation files (the "Software"), to deal
'in the Software without restriction, including without limitation the rights
'to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
'copies of the Software, and to permit persons to whom the Software is
'furnished to do so, subject to the following conditions:
'
'The above copyright notice and this permission notice shall be included in
'all copies or substantial portions of the Software.
'
'THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
'IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
'FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
'AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
'LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
'OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
'THE SOFTWARE.

'=====  �ݒ�  =====
'�ؐՋL�^�p��EXCEL�u�b�N
Dim EXCEL_EVIDENCE_BOOKPATH
EXCEL_EVIDENCE_BOOKPATH = ".\EvidenceTemplate.xlsx"

'�X�N���[���V���b�g��\��t����EXCEL�V�[�g
Dim EXCEL_SCREENSHOT_SHEETNAME
EXCEL_SCREENSHOT_SHEETNAME = "Screenshot"

'�X�N���[���V���b�g��\��t����J�n�Z��
Dim EXCEL_STARTPRINT_CELLADDRESS
EXCEL_STARTPRINT_CELLADDRESS = "B3"

'�X�N���[���V���b�g��\��t����s�Ԋu
Dim EXCEL_ONEPAGE_ROWS
EXCEL_ONEPAGE_ROWS = 62

'�X�N���[���V���b�g�p�X�N���[���̏c�������l
Dim SCROLL_ONEPAGE_ADDHEIGHT
SCROLL_ONEPAGE_ADDHEIGHT = -150

'�f�[�^�x�[�X�̒l��\��t����EXCEL�V�[�g
Dim EXCEL_DATABASE_SHEETNAME
EXCEL_DATABASE_SHEETNAME = "Database"

'�f�[�^�x�[�X�̒l��\��t����J�n�Z��
Dim EXCEL_STARTSET_CELLADDRESS
EXCEL_STARTSET_CELLADDRESS = "B4"

'�f�[�^�x�[�X�̒l��\��t����s�Ԋu
Dim EXCEL_INTERVAL_ROWS
EXCEL_INTERVAL_ROWS = 2

'�ڑ�������i�C�Ӂj
Dim fs
Set fs = CreateObject("Scripting.FileSystemObject")
Dim CONNECTION_STRING
CONNECTION_STRING = "Provider=Microsoft.ACE.OLEDB.12.0; Data Source=" & fs.GetAbsolutePathName(".\_database.xlsx") & "; Extended Properties=""Excel 8.0;HDR=Yes; [IMEX=1;]"";"

'=====  �Œ�l  =====
'�����s��؂�̃L�[���[�h
Dim OPTIONROW_SEPERATE_KEYWORD
OPTIONROW_SEPERATE_KEYWORD = " %|% "

'������؂�̃L�[���[�h
Dim OPTION_SEPERATE_KEYWORD
OPTION_SEPERATE_KEYWORD = "��"

'�v�f�w��̃L�[���[�h
Dim ELEMENT_SPECIFY_KEYWORD
ELEMENT_SPECIFY_KEYWORD = "="

'�C���f�b�N�X�w��̃L�[���[�h
Dim INDEX_SPECIFY_KEYWORD
INDEX_SPECIFY_KEYWORD = "#"

'===== �O���� =====
Dim i, j, k
Dim wsh
Set wsh = WScript.CreateObject("WScript.Shell")
Dim shl
Set shl = CreateObject("Shell.Application")
'Dim fs
'Set fs = CreateObject("Scripting.FileSystemObject")
Dim excel, wbk, shtSS, shtDB, rng
Set excel = WScript.CreateObject("Excel.Application")
excel.Application.Visible = True
excel.Application.DisplayAlerts = False
Set wbk = excel.Application.Workbooks.Open(fs.GetAbsolutePathName(EXCEL_EVIDENCE_BOOKPATH), 2, True)
Set shtSS = excel.Worksheets(EXCEL_SCREENSHOT_SHEETNAME)
Dim con
If(CONNECTION_STRING <> "") Then
  '�ڑ���������w�肵����
  Set shtDB = excel.Worksheets(EXCEL_DATABASE_SHEETNAME)
  Set con = CreateObject("ADODB.Connection")
  con.Open CONNECTION_STRING
End If

Dim ies(), idxIes(), ie
Redim ies(0)
Set ies(0) = Nothing
Redim idxIes(0)
idxIes(0) = 0
Set ie = Nothing
Dim doc, elm
Set doc = Nothing
Set elm = Nothing

Dim wLoc, wSvc, wEnu, wIns
Set wLoc = CreateObject("WbemScripting.SWbemLocator")
Set wSvc = wLoc.ConnectServer
Set wEnu = wSvc.InstancesOf("Win32_Process")

Dim cntScroll, idxPasteArea
cntScroll = 0
idxPasteArea = 0
idxSetArea = 0

'===== ���ʊ֐� =====
'IE�̑J�ڂ�҂�
Sub IEWait(ie)
  Do While ie.Busy = True Or ie.readyState <> 4
  Loop
  Wscript.Sleep 1000
  Set doc = ie.document
End Sub

'�w��E�B���h�E�������ɂ���
Sub ActivateWindow(processId)
  While not wsh.AppActivate(processId)
    Wscript.Sleep 100
  Wend
End Sub

'�Ō�ɋN������IE�������ɂ���
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

'���͂���iSendKeys/Value���ʁj
Sub Input(expOptsSet, useSendKeys)
  Dim aryExpOpts, aryOpt, expOpts, expOpt, idxSep, valInput
  aryExpOpts = Split(expOptsSet, OPTIONROW_SEPERATE_KEYWORD)
  For Each expOpts in aryExpOpts
    idxSep = InStr(expOpts, OPTION_SEPERATE_KEYWORD)
    Set elm = GetElement(Left(expOpts, idxSep - 1))
    elm.Focus
    valInput = Trim(Right(expOpts, Len(expOpts) - idxSep))
    valInput = Mid(valInput, 2, Len(valInput) - 2)
    If (useSendKeys) Then
      wsh.SendKeys valInput
    Else
      elm.Value = valInput
    End If
  Next
End Sub

'����L�[����͂���
Sub KeybdEvent(bVk, bScan, dwFlags, dwExtraInfo)
  Call excel.ExecuteExcel4Macro(Replace(Replace(Replace(Replace("CALL(""user32"",""keybd_event"",""JJJJJ"", %0, %1, %2, %3)", "%0", bVk), "%1", bScan), "%2", dwFlags), "%3", dwExtraInfo))
End Sub

'�v�f���擾����
Function GetElement(expElm)
  Dim elmTgt
  Set elmTgt = Nothing
  Dim aryExpElm, aryExpElm2
  aryExpElm = Split(expElm, ELEMENT_SPECIFY_KEYWORD)
  Dim keyElm, valElm, idxElm
  keyElm = Trim(aryExpElm(0))
  valElm = Trim(aryExpElm(1))
  If (0 < InStr(valElm, INDEX_SPECIFY_KEYWORD)) Then
    aryExpElm2 = Split(valElm, INDEX_SPECIFY_KEYWORD)
    valElm = Trim(aryExpElm2(0))
    idxElm = Trim(aryExpElm2(1))
  End If
  Select Case LCase(keyElm)
    Case "id"
      Set elmTgt = doc.getElementById(valElm)
    Case "name"
      Set elmTgt = doc.getElementsByName(valElm)(idxElm)
    Case "tag"
      Set elmTgt = doc.getElementsByTagName(valElm)(idxElm)
    Case "class"
      Set elmTgt = doc.getElementsByClassName(valElm)(idxElm)
  End Select
  Set GetElement = elmTgt
End Function

'�\�������̃X�N���[���c�����擾����
Function GetPageScrollHeight()
  GetPageScrollHeight = ie.Height + SCROLL_ONEPAGE_ADDHEIGHT
End Function

'�X�N���[������
Function Scroll(goToEnd)
  If (goToEnd) Then
    ie.Navigate "javascript:scroll(0," & ie.document.body.ScrollHeight & ")"
  Else
    ie.Navigate "javascript:scrollTo(0," & GetPageScrollHeight() & ")"
  End If
  Wscript.Sleep 1000
End Function

'���l��؂�グ����
function Ceil(Number)
  Ceil = Int(Number)
  if Ceil <> Number then
    Ceil = Ceil + 1
  end if
end function

'===== ����p�֐� =====
'InternetExplorer���J��
Sub Open()
  Set ies(0) = CreateObject("InternetExplorer.Application")
  Set ie = ies(0)
  ie.Visible = True
  idxIes(0) = ActivateLastIE
  MaximumWindow
End Sub

'InternetExplorer�����
Sub Close()
  ie.Quit
  If(0 < Ubound(ies)) Then
    ActivateParentWindow
  Else
    Set ie = Nothing
  End If
End Sub

'�S��ʕ\�����s��
Sub FullScreen()
  ie.FullScreen = True
End Sub

'�S��ʕ\�����~�߂�
Sub NormalScreen()
  ie.FullScreen = False
End Sub

'�ő剻����
Sub MaximumWindow()
  excel.ExecuteExcel4Macro "CALL(""user32"", ""ShowWindow"", ""JJJ"", " & ie.Hwnd & ", 3)"
End Sub

'�ŏ�������
Sub MinimumWindow()
  excel.ExecuteExcel4Macro "CALL(""user32"", ""ShowWindow"", ""JJJ"", " & ie.Hwnd & ", 2)"
End Sub

'�W���\���ɂ���
Sub NormalWindow()
  excel.ExecuteExcel4Macro "CALL(""user32"", ""ShowWindow"", ""JJJ"", " & ie.Hwnd & ", 1)"
End Sub

'�ҋ@����
Sub Sleep(sec)
  WScript.Sleep(sec * 1000)
End Sub

'URL�őJ�ڂ���
Sub Navigate(url)
  ie.Navigate url
  IEWait(ie)
End Sub

'�q��ʂ��A�N�e�B�u�ɂ���
Sub ActivateChildWindow()
  Redim Preserve ies(Ubound(ies) + 1)
  Redim Preserve idxIes(Ubound(idxIes) + 1)
  Set ies(Ubound(ies)) = shl.Windows(shl.Windows.Count - 1)
  Set ie = ies(Ubound(ies))
  idxIes(Ubound(idxIes)) = ActivateLastIE
  IEWait(ie)
End Sub

'�e��ʂ��A�N�e�B�u�ɂ���
Sub ActivateParentWindow()
  Redim Preserve ies(Ubound(ies) - 1)
  Redim Preserve idxIes(Ubound(idxIes) - 1)
  Set ie = ies(Ubound(ies))
  ActivateWindow idxIes(Ubound(ies))
  IEWait(ie)
End Sub

'�w��t���[���������ɂ���
Sub ActivateFrame(idxFrame)
  Set doc = ie.document.frames(idxFrame)
End Sub

'�t�H�[�J�X�𓖂Ă�
Sub Focus(expElm)
  Set elm = GetElement(expElm)
  elm.Focus
End Sub

'���͂���iSendKeys�j
Sub KeyInput(expOptsSet)
  Input expOptsSet, True
End Sub

'���͂���iValue�j
Sub ValueInput(expOptsSet)
  Input expOptsSet, False
End Sub

'�N���b�N����
Sub Click(expElm)
  Set elm = GetElement(expElm)
  elm.Focus
  elm.Click
  IEWait(ie)
End Sub

'�L�[������
Sub SendKeys(key)
  wsh.SendKeys key, True
  IEWait(ie)
End Sub

'�X�N���[���V���b�g���B��i��ʑS��, �\���ӏ��̂݁j
Sub FullScreenShot4VisibleArea(msg)
  Call KeybdEvent(&H2C, 0, 1, 0)
  Call KeybdEvent(&H2C, 0, 3, 0)
  WScript.Sleep(2 * 1000)
  shtSS.Activate
  Set rng = shtSS.Range( _
    EXCEL_STARTPRINT_CELLADDRESS _
      ).Offset(EXCEL_ONEPAGE_ROWS * idxPasteArea, 0)
  rng.Value = msg
  rng.Offset(1, 1).Select
  shtSS.Paste
  Set rng = Nothing
  idxPasteArea = idxPasteArea + 1
End Sub

'�X�N���[���V���b�g���B��i��ʑS�́j
Sub FullScreenShot(msg)
  FullScreenShot4VisibleArea msg
  cntScroll = Ceil(ie.document.body.ScrollHeight / GetPageScrollHeight())
  Dim i
  For i = 2 To cntScroll
    Scroll (i = cntScroll)
    FullScreenShot4VisibleArea ""
  Next
End Sub

'�X�N���[���V���b�g���B��i�A�N�e�B�u���, �\���ӏ��̂݁j
Sub ScreenShot4VisibleArea(msg)
  Call KeybdEvent(&H12, 0, 1, 0)
  FullScreenShot4VisibleArea msg
  Call KeybdEvent(&H12, 0, 3, 0)
End Sub

'�X�N���[���V���b�g���B��i�A�N�e�B�u��ʁj
Sub ScreenShot(msg)
  ScreenShot4VisibleArea msg
  cntScroll = Ceil(ie.document.body.ScrollHeight / GetPageScrollHeight())
  For i = 2 To cntScroll
    Scroll (i = cntScroll)
    ScreenShot4VisibleArea ""
  Next
End Sub

'SQL���𔭍s����
Sub ExecuteSQL(sql)
  Dim rs, fld
  Set rs = CreateObject("ADODB.Recordset")
  Dim cmd
  cmd = Replace(sql, OPTIONROW_SEPERATE_KEYWORD, vbCrLf)
  rs.Open cmd , con, 1, 1
  Dim cntClm
  cntClm = 1
  ' SQL�����L�^
  Set rng = shtDB.Range(EXCEL_STARTSET_CELLADDRESS)
  rng.Offset(idxSetArea, 0).Value = cmd
  idxSetArea = idxSetArea + 1
  ' �񖼂��L�^
  For each fld in rs.Fields
    rng.Offset(idxSetArea, cntClm).Value = fld.Name
    cntClm = cntClm + 1
  Next
  idxSetArea = idxSetArea + 1
  ' �l���L�^
  Do Until rs.EOF
    cntClm = 1
    For each fld in rs.Fields
      rng.Offset(idxSetArea, cntClm).Value = fld.Value
      cntClm = cntClm + 1
    Next
    idxSetArea = idxSetArea + 1
    rs.MoveNext
  Loop
  idxSetArea = idxSetArea + EXCEL_INTERVAL_ROWS
  rs.Close
  Set rng = Nothing
  Set fld = Nothing
  Set rs = Nothing
End Sub

'===== �{���� =====
'�yPaperTester.xlsx�Ő������ꂽVBScript�R�}���h�������ɓ\��t����B�z
Open
Navigate "http://bl.ocks.org/nezuQ/raw/9719897/"
FullScreenShot4VisibleArea "1"
ExecuteSQL "SELECT * FROM [Sheet1$] "

ValueInput "id=ddlEndpoint �� '1' %|% id=ddlSearchType �� '1' %|% id=txtQuery �� '���u���C�u�I' %|% id=txtPHPSessID �� ''"
FullScreenShot "2-1"
Click "tag=input#4"
ActivateChildWindow
FullScreenShot ""
ExecuteSQL "SELECT * FROM [Sheet2$] "
Close
ValueInput "id=ddlEndpoint �� '0' %|% id=ddlSearchType �� '0' %|% id=txtQuery �� '�͑����ꂭ�����' %|% id=txtPHPSessID �� ''"
FullScreenShot "2-2"
Click "tag=input#4"
ActivateChildWindow
FullScreenShot ""
ExecuteSQL "SELECT * FROM [Sheet2$] "

'===== �㏈�� =====
Set wLoc = Nothing
Set wEnu = Nothing
Set wSvc = Nothing
Set wIns = Nothing
Set elm = Nothing
Set doc = Nothing
If(Not(ie is Nothing)) Then
  ie.FullScreen = False
  Set ie = Nothing
End If
For i = LBound(ies) to UBound(ies)
  Set ies(i) = Nothing
Next
Set rng = Nothing
Set shtSS = Nothing
Set excel = Nothing
Set wsh = Nothing
Set shl = Nothing
Set fs = Nothing
Set con = Nothing

Msgbox "����������I�����܂����B"
