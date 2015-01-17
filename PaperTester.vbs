Option Explicit

'===== ���C�Z���X =====
'PaperTester
'Copyright (c) 2014 nezuq
'This software is released under the MIT License.
'https://github.com/nezuQ/PaperTester/blob/master/LICENSE.txt

Class PaperTester

  '===== �ݒ�l =====
  
  '�ؐՋL�^�pEXCEL�u�b�N�̃p�X
  Public EvidenceBookPath

  '�X�N���[���V���b�g��\��t����EXCEL�V�[�g
  Public ScreenshotSheetName

  '�X�N���[���V���b�g��\��t����J�n�Z��
  Public ScreenshotPrintCellAddress

  '�X�N���[���V���b�g��\��t����s�Ԋu
  Public ScreenshotPageRows

  '�X�N���[�����̑Ή�ʂł̏c����
  Public VerticalScrollRate

  '�f�[�^�x�[�X�̒l��\��t����EXCEL�V�[�g
  Public DatabaseSheetName

  '�f�[�^�x�[�X�̒l��\��t����J�n�Z��
  Public DataPrintCellAddress

  '�f�[�^�x�[�X�̒l��\��t����s�Ԋu
  Public DataIntervalRows

  '�ڑ�������
  Public ConnectionString

  '===== �Œ�l =====
  
  '�����s��؂�̃L�[���[�h
  Public OptionRowSeperateKey

  '���͒l�w��̃L�[���[�h
  Public SpecifyInputValueKey

  '�v�f�w��̃L�[���[�h
  Public SpecifyElementKey

  '�C���f�b�N�X�w��̃L�[���[�h
  Public SpecifyIndexKey

  '��ʂ̃A�N�e�B�x�[�V���������̍ő�ҋ@�b
  Public WindowActivationMaxWaitSeconds

  '�y�[�W�J�ڎ��s���̃��t���b�V�������Ԋu
  Public RefreshIntervalSeconds

  '===== �O���� =====
  
  Private i, j, k
  Private wsh, shl, fs
  Private excel, wbk, shtSS, shtDB, rng
  Private con
  Private ies(), idxIes(), ie
  Private doc, elm
  Private wLoc, wSvc, wEnu, wIns
  Private idxPasteArea, idxSetArea
  
  '�I�u�W�F�N�g�쐬�C�x���g
  Private Sub Class_Initialize
    Set wsh = WScript.CreateObject("WScript.Shell")
    Set shl = CreateObject("Shell.Application")
    Set fs = CreateObject("Scripting.FileSystemObject")
    Set excel = WScript.CreateObject("Excel.Application")
    excel.Application.DisplayAlerts = False

    Redim ies(0)
    Set ies(0) = Nothing
    Redim idxIes(0)
    idxIes(0) = 0
    Set ie = Nothing
    Set doc = Nothing
    Set elm = Nothing

    Set wLoc = CreateObject("WbemScripting.SWbemLocator")
    Set wSvc = wLoc.ConnectServer
    Set wEnu = wSvc.InstancesOf("Win32_Process")

    idxPasteArea = 0
    idxSetArea = 0
    
    '�ݒ�l�Ƀf�t�H���g�l����͂���
    EvidenceBookPath = ""
    ScreenshotSheetName = "Sheet1"
    ScreenshotPrintCellAddress = "A1"
    ScreenshotPageRows = 62
    VerticalScrollRate = 1.00
    DatabaseSheetName = "Sheet2"
    DataPrintCellAddress = "A1"
    DataIntervalRows = 2
    ConnectionString = ""
    
    '�ŗL�l�Ƀf�t�H���g�l����͂���
    OptionRowSeperateKey = " %|% "
    SpecifyInputValueKey = "<-"
    SpecifyElementKey = "="
    SpecifyIndexKey = "#"
    WindowActivationMaxWaitSeconds = 3
    RefreshIntervalSeconds = 30
  End Sub
  
  '����������
  Public Sub Initialize()
    If (EvidenceBookPath <> "") Then
      '�ؐՋL�^�pEXCEL�u�b�N�̃p�X���w�肳��Ă��鎞
      excel.Application.Visible = True
      Set wbk = excel.Application.Workbooks.Open(fs.GetAbsolutePathName(EvidenceBookPath), 2, True)
      Set shtSS = excel.Worksheets(ScreenshotSheetName)
      If (ConnectionString <> "") Then
        '�ڑ������񂪎w�肳��Ă��鎞
        Set shtDB = excel.Worksheets(DatabaseSheetName)
        Set con = CreateObject("ADODB.Connection")
        con.Open ConnectionString
      End If
    End If
  End Sub

  '===== ���ʊ֐� =====
  
  'IE�̑J�ڂ�҂�
  Private Sub IEWait(ie)
    Dim hmsLimit
    hmsLimit = Now + TimeSerial(0, 0, RefreshIntervalSeconds)
    Do While (ie.Busy = True Or ie.readyState <> 4)
      Wscript.Sleep 100
      If (hmsLimit < Now) Then
        ie.Refresh
        hmsLimit = Now + TimeSerial(0, 0, RefreshIntervalSeconds)
      End If
    Loop
    hmsLimit = Now + TimeSerial(0, 0, RefreshIntervalSeconds)
    Do Until (ie.document.ReadyState = "complete")
      Wscript.Sleep 100
      If (hmsLimit < Now) Then
        ie.Refresh
        hmsLimit = Now + TimeSerial(0, 0, RefreshIntervalSeconds)
      End If
    Loop
    Set doc = ie.document
  End Sub

  '�w��E�B���h�E���A�N�e�B�u�ɂ���
  Private Sub ActivateWindow(processId)
    Dim cnt, maxCnt
    maxCnt = WindowActivationMaxWaitSeconds * 10
    cnt = 1
    Do While not wsh.AppActivate(processId)
      If (maxCnt <= cnt) Then Exit Do
      cnt = cnt + 1
      Wscript.Sleep 100
    Loop
  End Sub

  'IE���A�N�e�B�u�ɂ���
  Private Function ActivateIE(isFirst)
    Dim pId
    pId = -1
    For Each wIns in wEnu
      If (Not IsEmpty(wIns.ProcessId)) _
        And (wIns.Description = "iexplore.exe") Then
        pId = wIns.ProcessId
        If (isFirst) Then Exit For
      End If
    Next
    ActivateWindow pId
    ActivateIE = pId
  End Function

  '���͂���iSendKeys/Value���ʁj
  Private Sub Input(expOptsSet, useSendKeys)
    Dim aryExpOpts, aryOpt, expOpts, expOpt, idxSep, lenSep, valInput
    aryExpOpts = Split(expOptsSet, OptionRowSeperateKey)
    For Each expOpts in aryExpOpts
      idxSep = InStr(expOpts, SpecifyInputValueKey)
      lenSep = Len(SpecifyInputValueKey)
      Set elm = GetElement(Left(expOpts, idxSep - 1))
      elm.Focus
      valInput = Trim(Right(expOpts, Len(expOpts) - idxSep - (lenSep - 1)))
      valInput = Mid(valInput, 2, Len(valInput) - 2)
      Select Case useSendKeys 
        Case 0
          elm.Value = valInput
        Case 1
          CopyAndPaste valInput
        Case 2
          wsh.SendKeys valInput
      End Select
    Next
  End Sub

  '����L�[����͂���
  Private Sub KeybdEvent(bVk, bScan, dwFlags, dwExtraInfo)
    Call excel.ExecuteExcel4Macro(Replace(Replace(Replace(Replace("CALL(""user32"",""keybd_event"",""JJJJJ"", %0, %1, %2, %3)", "%0", bVk), "%1", bScan), "%2", dwFlags), "%3", dwExtraInfo))
  End Sub

  '��������N���b�v�{�[�h�ɋL�^����
  Private Sub CopyText(str)
    Dim cmd
    cmd = "cmd /c ""echo " & str & "| clip"""
    wsh.Run cmd, 0
  End Sub

  '�v�f���擾����
  Private Function GetElement(expElm)
    Dim elmTgt
    Set elmTgt = Nothing
    Dim aryExpElm, aryExpElm2
    aryExpElm = Split(expElm, SpecifyElementKey)
    Dim keyElm, valElm, idxElm
    keyElm = Trim(aryExpElm(0))
    valElm = Trim(aryExpElm(1))
    If (0 < InStr(valElm, SpecifyIndexKey)) Then
      aryExpElm2 = Split(valElm, SpecifyIndexKey)
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
  Private Function Scroll(numHeight)
    Dim numNextHeight
    numNextHeight = numHeight
    If (ie.document.body.ScrollHeight < numNextHeight) Then
      numNextHeight = ie.document.body.ScrollHeight
    End If
    ie.Navigate "javascript:scroll(0, " & numNextHeight & ")"
    Wscript.Sleep 1000
    Scroll = numNextHeight
  End Function

  '���l��؂�グ����
  Private Function Ceil(Number)
    Ceil = Int(Number)
    if Ceil <> Number then
      Ceil = Ceil + 1
    end if
  end function

  '�J��Ԃ��X�N���[���V���b�g���B��
  Private Sub RepeatScreenShot(isFull, msg)
    '1���ڂ̃X�N���[���V���b�g���B��
    If (isFull) Then
      FullScreenShot4VisibleArea msg
    Else
      ScreenShot4VisibleArea msg
    End If
    '�c������X�N���[���V���b�g�񐔂��Z�o����
    Dim cntPage, numHeight, numPageHeight
    numHeight = 0
    numPageHeight = ie.Height * VerticalScrollRate
    If (numPageHeight < ie.document.body.ScrollHeight) Then
      cntPage = Ceil(ie.document.body.ScrollHeight / numPageHeight)
    Else
      cntPage = 1
    End If
    '2���ڈȍ~�̃X�N���[���V���b�g���B��
    numHeight = numPageHeight
    Dim i
    For i = 2 To cntPage
      Scroll (numHeight)
      If (isFull) Then
        FullScreenShot4VisibleArea ""
      Else
        ScreenShot4VisibleArea ""
      End If
      numHeight = numHeight + numPageHeight
    Next
  End Sub

  '===== ����p�֐� =====
  
  'InternetExplorer���J��
  Public Sub Open()
    Set ies(0) = CreateObject("InternetExplorer.Application")
    Set ie = ies(0)
    ie.Visible = True
    idxIes(0) = ActivateIE(False)
  End Sub

  'InternetExplorer���擾����
  Public Sub GetIE(isFirst)
    Dim win
    For Each win In shl.Windows
      If TypeName(win.document) = "HTMLDocument" Then
        'HTMLDocument�^�̏ꍇ
        Set ies(0) = win
        Set ie = ies(0)
        If (isFirst) Then Exit For
      End If
    Next
    ie.Visible = True
    idxIes(0) = ActivateIE(isFirst)
  End Sub

  'InternetExplorer�����
  Public Sub Close()
    ie.Quit
    If (0 < Ubound(ies)) Then
      ActivateParentWindow
    Else
      Set ie = Nothing
    End If
  End Sub

  '�߂�
  Public Sub GoBack()
    ie.GoBack
  End Sub

  '�S��ʕ\�����s��
  Public Sub FullScreen()
    ie.FullScreen = True
  End Sub

  '�S��ʕ\�����~�߂�
  Sub NormalScreen()
    ie.FullScreen = False
  End Sub

  '�ő剻����
  Public Sub MaximumWindow()
    excel.ExecuteExcel4Macro "CALL(""user32"", ""ShowWindow"", ""JJJ"", " & ie.Hwnd & ", 3)"
  End Sub

  '�ŏ�������
  Public Sub MinimumWindow()
    excel.ExecuteExcel4Macro "CALL(""user32"", ""ShowWindow"", ""JJJ"", " & ie.Hwnd & ", 2)"
  End Sub

  '�W���\���ɂ���
  Public Sub NormalWindow()
    excel.ExecuteExcel4Macro "CALL(""user32"", ""ShowWindow"", ""JJJ"", " & ie.Hwnd & ", 1)"
  End Sub

  '�ҋ@����
  Public Sub Sleep(sec)
    WScript.Sleep(sec * 1000)
  End Sub

  'URL�őJ�ڂ���
  Public Sub Navigate(url)
    ie.Navigate url
    IEWait(ie)
  End Sub

  '�q��ʂ��A�N�e�B�u�ɂ���
  Public Sub ActivateChildWindow()
    Redim Preserve ies(Ubound(ies) + 1)
    Redim Preserve idxIes(Ubound(idxIes) + 1)
    WScript.Sleep 1000
    Set ies(Ubound(ies)) = shl.Windows(shl.Windows.Count - 1)
    Set ie = ies(Ubound(ies))
    idxIes(Ubound(idxIes)) = ActivateIE(False)
    IEWait(ie)
  End Sub

  '�e��ʂ��A�N�e�B�u�ɂ���
  Public Sub ActivateParentWindow()
    Redim Preserve ies(Ubound(ies) - 1)
    Redim Preserve idxIes(Ubound(idxIes) - 1)
    Set ie = ies(Ubound(ies))
    ActivateWindow idxIes(Ubound(ies))
    IEWait(ie)
  End Sub

  '�w��t���[�����A�N�e�B�u�ɂ���
  Public Sub ActivateFrame(idxFrame)
    Set doc = doc.frames(idxFrame).document
  End Sub

  '���h�L�������g���A�N�e�B�u�ɂ���
  Public Sub ActivateDocument()
    Set doc = ie.document
  End Sub

  '�t�H�[�J�X�𓖂Ă�
  Public Sub Focus(expElm)
    Set elm = GetElement(expElm)
    elm.Focus
  End Sub

  '���͂���iValue�j
  Public Sub ValueInput(expOptsSet)
    Input expOptsSet, 0
  End Sub

  '���͂���iCopy&Paste�j
  Public Sub PasteInput(expOptsSet)
    Input expOptsSet, 1
  End Sub

  '���͂���iSendKeys�j
  Public Sub KeyInput(expOptsSet)
    Input expOptsSet, 2
  End Sub

  '�N���b�N����
  Public Sub Click(expElm)
    Set elm = GetElement(expElm)
    elm.Focus
    elm.Click
    IEWait(ie)
  End Sub

  '��������R�s�[&�y�[�X�g����B
  Public Sub CopyAndPaste(str)
    CopyText str
    Wscript.Sleep 750
    wsh.SendKeys "^(v)", True
    Wscript.Sleep 750
  End Sub

  '�L�[������
  Public Sub SendKeys(key)
    wsh.SendKeys key, True
  End Sub

  '�X�N���[���V���b�g���B��i��ʑS��, �\���ӏ��̂݁j
  Public Sub FullScreenShot4VisibleArea(msg)
    WScript.Sleep 1000
    Call KeybdEvent(&H2C, 0, 1, 0)
    Call KeybdEvent(&H2C, 0, 3, 0)
    WScript.Sleep 1000
    shtSS.Activate
    Set rng = shtSS.Range( _
      ScreenshotPrintCellAddress _
        ).Offset(ScreenshotPageRows * idxPasteArea, 0)
    rng.Value = msg
    rng.Offset(1, 1).Select
    shtSS.Paste
    Set rng = Nothing
    idxPasteArea = idxPasteArea + 1
  End Sub

  '�X�N���[���V���b�g���B��i��ʑS�́j
  Public Sub FullScreenShot(msg)
    RepeatScreenShot True, msg
  End Sub

  '�X�N���[���V���b�g���B��i�A�N�e�B�u���, �\���ӏ��̂݁j
  Public Sub ScreenShot4VisibleArea(msg)
    Call KeybdEvent(&H12, 0, 1, 0)
    FullScreenShot4VisibleArea msg
    Call KeybdEvent(&H12, 0, 3, 0)
  End Sub

  '�X�N���[���V���b�g���B��i�A�N�e�B�u��ʁj
  Public Sub ScreenShot(msg)
    RepeatScreenShot False, msg
  End Sub

  'SQL���𔭍s����
  Public Sub ExecuteSQL(sql)
    Dim rs, fld
    Set rs = CreateObject("ADODB.Recordset")
    Dim cmd
    cmd = Replace(sql, OptionRowSeperateKey, vbCrLf)
    rs.Open cmd , con, 1, 1
    Dim cntClm
    cntClm = 1
    ' SQL�����L�^
    Set rng = shtDB.Range(DataPrintCellAddress)
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
    idxSetArea = idxSetArea + DataIntervalRows
    rs.Close
    Set rng = Nothing
    Set fld = Nothing
    Set rs = Nothing
  End Sub

  '===== �㏈�� =====
  
  '�I������
  Public Sub Terminate
    Set wLoc = Nothing
    Set wEnu = Nothing
    Set wSvc = Nothing
    Set wIns = Nothing
    Set elm = Nothing
    Set doc = Nothing
    If (Not(ie is Nothing)) Then
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
  End Sub

  '�I�u�W�F�N�g�j�����̃C�x���g
  Private Sub Class_Terminate
    Terminate
  End Sub
End Class
