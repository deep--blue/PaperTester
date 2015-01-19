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

  '���،��ʂ�\��t������̍s�Ԋu
  Public AfterValidationLogRows

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
  Public SpecifyInputKey

  '�����w��̃L�[���[�h
  Public SpecifyAttributeKey

  '�C���f�b�N�X�w��̃L�[���[�h
  Public SpecifyIndexKey

  '�e�L�X�g��̃L�[���[�h
  Public TextWrapKey

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
  Private doc
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
    AfterValidationLogRows = 1
    VerticalScrollRate = 1.00
    DatabaseSheetName = "Sheet2"
    DataPrintCellAddress = "A1"
    DataIntervalRows = 2
    ConnectionString = ""
    
    '�ŗL�l�Ƀf�t�H���g�l����͂���
    OptionRowSeperateKey = " %|% "
    SpecifyInputKey = "<-"
    SpecifyAttributeKey = "="
    SpecifyIndexKey = "#"
    TextWrapKey = "'"
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
  
  '���l��؂�グ����
  Private Function Ceil(Number)
    Ceil = Int(Number)
    if Ceil <> Number then
      Ceil = Ceil + 1
    end if
  end function
  
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

  '�e�L�X�g��L�[���[�h���폜����
  Private Function Unwrap(exp)
    Dim expUnwrap
    expUnwrap = Trim(exp)
    If (Left(expUnwrap, 1) = TextWrapKey) And (Right(expUnwrap, 1) = TextWrapKey) Then
      expUnwrap = Right(expUnwrap, Len(expUnwrap) - 1)
      expUnwrap = Left(expUnwrap, Len(expUnwrap) - 1)
    End If
    Unwrap = expUnwrap
  End Function

  '�����w��\����]������
  Private Function EvalAtrSpecExp(exp)
    Dim expTrim, expValueTrim
    expTrim = Trim(exp)
    Dim aryAtrExp(2)
    aryAtrExp(0) = "value"
    aryAtrExp(1) = Unwrap(exp)
    aryAtrExp(2) = 0
    Dim idxSAKey, idxSIKey, idxTWKey, idxLastTWKey
    idxSAKey = InStr(expTrim, SpecifyAttributeKey)
    idxTWKey = InStr(expTrim, TextWrapKey)
    If ((0 < idxSAKey) And ((idxTWKey = 0) Or (idxSAKey < idxTWKey))) Then
      aryAtrExp(0) = Trim(Left(expTrim, idxSAKey - 1))
      expValueTrim = Trim(Right(expTrim, Len(expTrim) - idxSAKey - (Len(SpecifyAttributeKey) - 1)))
      idxSIKey = InStrRev(expValueTrim, SpecifyIndexKey)
      idxLastTWKey = InStrRev(expValueTrim, TextWrapKey)
      If ((0 < idxSIKey) And (idxLastTWKey < idxSIKey)) Then
        aryAtrExp(1) = Unwrap(Left(expValueTrim, idxSIKey - 1))
        aryAtrExp(2) = Trim(Right(expValueTrim, Len(expValueTrim) - idxSIKey - (Len(SpecifyIndexKey) - 1)))
      Else
        aryAtrExp(1) = Unwrap(expValueTrim)
      End If
    End If
    EvalAtrSpecExp = aryAtrExp
  End Function
  
  '���͒l�w��\����]������
  Private Function EvalInputSpecExp(exp)
    Dim aryInputExp(5), aryAtrExp
    aryInputExp(0) = ""
    aryInputExp(1) = ""
    aryInputExp(2) = ""
    aryInputExp(3) = ""
    aryInputExp(4) = ""
    aryInputExp(5) = ""
    Dim idxSIPKey
    idxSIPKey = InStr(exp, SpecifyInputKey)
    If (0 < idxSIPKey) Then
      aryAtrExp = EvalAtrSpecExp(Left(exp, idxSIPKey - 1))
      aryInputExp(0) = aryAtrExp(0)
      aryInputExp(1) = aryAtrExp(1)
      aryInputExp(2) = aryAtrExp(2)
      aryAtrExp = EvalAtrSpecExp(Right(exp, Len(exp) - idxSIPKey - (Len(SpecifyInputKey) - 1)))
      aryInputExp(3) = aryAtrExp(0)
      aryInputExp(4) = aryAtrExp(1)
      aryInputExp(5) = aryAtrExp(2)
    Else
      aryAtrExp = EvalAtrSpecExp(exp)
      aryInputExp(0) = aryAtrExp(0)
      aryInputExp(1) = aryAtrExp(1)
      aryInputExp(2) = aryAtrExp(2)
    End If
    EvalInputSpecExp = aryInputExp
  End Function

  '�v�f���擾����
  Private Function GetElement(aryExp)
    Dim elm
    Set elm = Nothing
    Select Case LCase(aryExp(0))
      Case "id"
        Set elm = doc.getElementById(aryExp(1))
      Case "name"
        Set elm = doc.getElementsByName(aryExp(1))(aryExp(2))
      Case "tag"
        Set elm = doc.getElementsByTagName(aryExp(1))(aryExp(2))
      Case "class"
        Set elm = doc.getElementsByClassName(aryExp(1))(aryExp(2))
    End Select
    Set GetElement = elm
    Set elm = Nothing
  End Function

  '���͂���iSendKeys/Value���ʁj
  Private Sub Input(exp, useSendKeys)
    Dim elm
    Dim aryExpOpts, expOpts, aryOpt
    aryExpOpts = Split(exp, OptionRowSeperateKey)
    For Each expOpts in aryExpOpts
      aryOpt = EvalInputSpecExp(expOpts)
      Set elm = GetElement(aryOpt)
      elm.Focus
      Select Case useSendKeys 
        Case 0
          elm.Value = aryOpt(4)
        Case 1
          Paste aryOpt(4)
        Case 2
          wsh.SendKeys aryOpt(4)
      End Select
    Next
    Set elm = Nothing
  End Sub
  
  '�������擾����
  Private Function GetAttribute(elm, nmeAtr)
    Dim atr, nmeAtrLCase
    nmeAtrLCase = LCase(nmeAtr)
    Select Case nmeAtrLCase 
      Case "value"
        atr = elm.Value
      Case Else
        atr = elm.getAttribute(nmeAtr, 2)
    End Select
    GetAttribute = atr
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
  
  '���؎��s���̃G���[���b�Z�[�W���擾����
  Private Function GetValidationMessage(exp, valSpec, valReal)
    Dim strResult
    If (valSpec = valReal) Then
      strResult = "OK"
    Else
      strResult = "NG"
    End If
    GetValidationMessage = "�y" & strResult & "�z" & exp & "|" & TextWrapKey & valReal & TextWrapKey
  End Function

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
  Public Sub Focus(exp)
    Dim elm
    Set elm = GetElement(EvalAtrSpecExp(exp))
    elm.Focus
    Set elm = Nothing
  End Sub

  '���͂���iValue�j
  Public Sub ValueInput(exp)
    Input exp, 0
  End Sub

  '���͂���iCopy&Paste�j
  Public Sub PasteInput(exp)
    Input exp, 1
  End Sub

  '���͂���iSendKeys�j
  Public Sub KeyInput(exp)
    Input exp, 2
  End Sub

  '�N���b�N����
  Public Sub Click(exp)
    Dim elm
    Set elm = GetElement(EvalAtrSpecExp(exp))
    elm.Focus
    elm.Click
    IEWait(ie)
    Set elm = Nothing
  End Sub

  '��������R�s�[&�y�[�X�g����B
  Public Sub Paste(str)
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
        ).Offset(idxPasteArea, 0)
    rng.Value = msg
    rng.Offset(1, 1).Select
    shtSS.Paste
    Set rng = Nothing
    idxPasteArea = idxPasteArea + ScreenshotPageRows
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
  
  '���؂���i����NG���͏������f�j
  Public Sub ValidateAttribute(exp)
    Dim msg
    msg = Record2ValidateAttribute(exp)
    If (msg <> "") Then
      Err.Raise 9999, "PaperTester", "����NG�B" & msg
    End If
  End Sub

  '���؂���i����NG���͏������s�j
  Public Function Record2ValidateAttribute(exp)
    Const keySepMsg = ", "
    Dim aryExpOpts, expOpts, msgAll
    msgAll = ""
    aryExpOpts = Split(exp, OptionRowSeperateKey)
    For Each expOpts in aryExpOpts
      Dim aryInputExp
      aryInputExp = EvalInputSpecExp(expOpts)
      Dim elm
      Set elm = GetElement(aryInputExp)
      Dim atr
      atr = GetAttribute(elm, aryInputExp(3))
      Dim msg
      msg = GetValidationMessage(expOpts, aryInputExp(4), atr)
      Dim rng
      shtSS.Activate
      Set rng = shtSS.Range( _
        ScreenshotPrintCellAddress _
          ).Offset(idxPasteArea, 0)
      rng.Offset(0, 1).Value = msg
      Set rng = Nothing
      idxPasteArea = idxPasteArea + 1
      If (aryInputExp(4) = atr) Then
        '�����Ȃ�
      Else
        msgAll = msgAll & msg & keySepMsg
      End If
    Next
    idxPasteArea = idxPasteArea + AfterValidationLogRows
    If (msgAll = "") Then
      Record2ValidateAttribute = "" 
    Else
      Record2ValidateAttribute = Left(msgAll, Len(msgAll) - Len(keySepMsg))
    End If
  End Function

  'Javascript�����s����B
  Public Sub ExecuteJS(cmd)
    ie.Navigate "javascript:" & cmd
  End Sub

  '===== �㏈�� =====
  
  '�I������
  Public Sub Terminate
    Set wLoc = Nothing
    Set wEnu = Nothing
    Set wSvc = Nothing
    Set wIns = Nothing
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
