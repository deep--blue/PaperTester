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
'�X�N���[���V���b�g��\��t����EXCEL�u�b�N
Dim EXCEL_PRINT_BOOKPATH
EXCEL_PRINT_BOOKPATH = ".\evidence.xlsx"
'�X�N���[���V���b�g��\��t����J�n�Z��
Dim EXCEL_STARTPRINT_CELLADDRESS
EXCEL_STARTPRINT_CELLADDRESS = "C4"
'�X�N���[���V���b�g��\��t����s�Ԋu
Dim EXCEL_ONEPAGE_ROWS
EXCEL_ONEPAGE_ROWS = 61

'=====  �Œ�l  =====
'�����s��؂�̃L�[���[�h
Dim OPTIONROW_SEPERATE_KEYWORD
OPTIONROW_SEPERATE_KEYWORD = "|"
'������؂�̃L�[���[�h
Dim OPTION_SEPERATE_KEYWORD
OPTION_SEPERATE_KEYWORD = ","
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
Dim fs
Set fs = CreateObject("Scripting.FileSystemObject")
Dim excel, wbk, sht, rng
Set excel = WScript.CreateObject("Excel.Application")
excel.Application.Visible = True
excel.Application.DisplayAlerts = False
Set wbk = excel.Application.Workbooks.Open(fs.GetAbsolutePathName(EXCEL_PRINT_BOOKPATH))
Set sht = excel.Worksheets(1)

Dim ies(), idxIes(), ie
Redim ies(0)
Redim idxIes(0)
Dim doc
Dim elm

Dim wLoc, wSvc, wEnu, wIns
Set wLoc = CreateObject("WbemScripting.SWbemLocator")
Set wSvc = wLoc.ConnectServer
Set wEnu = wSvc.InstancesOf("Win32_Process")

Dim cntScroll, idxPasteArea
cntScroll = 0
idxPasteArea = 0

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
  Dim aryExpOpts, aryOpt, expOpts, expOpt
  aryExpOpts = Split(expOptsSet, OPTIONROW_SEPERATE_KEYWORD)
  For Each expOpts in aryExpOpts
    aryOpt = Split(expOpts, OPTION_SEPERATE_KEYWORD)
    Set elm = GetElement(aryOpt(0))
    elm.Focus
    If (useSendKeys) Then
      wsh.SendKeys aryOpt(1)
    Else
      elm.Value = aryOpt(1)
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

'�X�N���[������
Function Scroll(goToEnd)
  If (goToEnd) Then
    ie.Navigate "javascript:scroll(0," & ie.document.body.ScrollHeight & ")"
  Else
    ie.Navigate "javascript:scrollTo(0," & ie.Height & ")"
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
  ie.FullScreen = True
  idxIes(0) = ActivateLastIE
End Sub

'InternetExplorer�����
Sub Close()
  ie.Quit
  Set ie = Nothing
End Sub

'�ő�\���ɂ���
Sub FullScreen()
  ie.FullScreen = True
End Sub

'�W���\���ɂ���
Sub NormalScreen()
  ie.FullScreen = False
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
  Redim Preserve idxIes(Ubound(ies) - 1)
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
Sub FullScreenShot4VisibleArea()
  Call KeybdEvent(&H2C, 0, 1, 0)
  Call KeybdEvent(&H2C, 0, 3, 0)
  WScript.Sleep(2 * 1000)
  sht.Activate
  Set rng = sht.Range( _
    EXCEL_STARTPRINT_CELLADDRESS _
      ).Offset(EXCEL_ONEPAGE_ROWS * idxPasteArea, 0)
  rng.Select
  sht.Paste
  Set rng = Nothing
  idxPasteArea = idxPasteArea + 1
End Sub

'�X�N���[���V���b�g���B��i��ʑS�́j
Sub FullScreenShot()
  FullScreenShot4VisibleArea
  cntScroll = Ceil(ie.document.body.ScrollHeight / ie.Height)
  Dim i
  For i = 2 To cntScroll
    Scroll (i = cntScroll)
    FullScreenShot4VisibleArea
  Next
End Sub

'�X�N���[���V���b�g���B��i�A�N�e�B�u���, �\���ӏ��̂݁j
Sub ScreenShot4VisibleArea()
  Call KeybdEvent(&H12, 0, 1, 0)
  ScreenShot
  Call KeybdEvent(&H12, 0, 3, 0)
End Sub

'�X�N���[���V���b�g���B��i�A�N�e�B�u��ʁj
Sub ScreenShot()
  ScreenShot4VisibleArea
  cntScroll = Ceil(ie.document.body.ScrollHeight / ie.Height)
  For i = 2 To cntScroll
    Scroll (i = cntScroll)
    ScreenShot4VisibleArea
  Next
End Sub

'===== �{���� =====
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
  ies(i).Quit
  Set ies(i) = Nothing
Next
Set rng = Nothing
Set sht = Nothing
Set excel = Nothing
Set wsh = Nothing
Set shl = Nothing
Set fs = Nothing

Msgbox "����������I�����܂����B"
