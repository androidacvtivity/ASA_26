Attribute VB_Name = "ASA_Filtru_CAEM2_Tab35"
Option Explicit

' ================================================================
' ASA 2025: filtru CAEM2 identic metodologic cu Tab.3.5.
' Intrare: workbook ASA_CAPITOLE_2025.xlsx (dezarhivat din ZIP).
' Iesire: ASA_CAPITOLE_2025_CAEM2_FILTRAT.xlsx (14 foi + audit).
'
' Sursa eligibilitatii: CAP1, CUIIO, CAEM_ACT prioritar; CAEM2 fallback.
' Cele 14 foi ale exportului contin aceleasi 16.725 intreprinderi.
' Nu se modifica valorile originale sau RIND_CD.
' In fisierul FILTRAT, coloanele numerice de DUPA CAEM_ACT sunt normalizate
' (text numeric -> numar), apoi se adauga la finalul FIECAREI foi:
'  1) SUMA CURENT = numai intreprinderile eligibile dupa CAEM2 actualizat;
'  2) SUMA PRECEDENT = TOATE intreprinderile din baza initiala, fara filtru.
' CUR/ PRECEDENT desemneaza filtrarea, NU anul calendaristic.
' CAEM_ACT este cod de clasificare si NU se insumeaza.
' Datele originale nu sunt modificate; cele invalide sunt raportate distinct.
' Compatible VBA Windows / macOS: nu foloseste Scripting.Dictionary.
' ================================================================

Private Const FIRST_DATA_ROW As Long = 2
Private Const BLOCK_SIZE As Long = 250

Public Sub Filtreaza_ASA_2025_CAEM2_Tab35()
    Dim wbS As Workbook, wbO As Workbook
    Dim wsS As Worksheet, wsO As Worksheet, wsRef As Worksheet
    Dim wsAudit As Worksheet, wsExcluded As Worksheet, wsNumeric As Worksheet
    Dim status As Collection, excluded As Collection
    Dim baseData As Variant, keys As Variant
    Dim oldCalc As XlCalculation
    Dim oldScreen As Boolean, oldEvents As Boolean, oldAlerts As Boolean
    Dim oldStatus As Variant
    Dim refLastRow As Long, lastRow As Long, lastCol As Long
    Dim cuiioCol As Long, caemCol As Long, actualCol As Long
    Dim i As Long, c As Long, k As Long, row0 As Long, rowN As Long
    Dim outRow As Long, kept As Long, dropped As Long
    Dim firstNumericCol As Long, currentRow As Long, previousRow As Long
    Dim currentTotal() As Double, previousTotal() As Double
    Dim invalidCurrent() As Long, invalidPrevious() As Long
    Dim numericValue As Double, checkState As Long, wasConverted As Boolean
    Dim invalidReason As String, invalidCell As String
    Dim convertedSheet As Long, invalidSheet As Long
    Dim convertedAll As Long, invalidAll As Long, numericAuditRow As Long
    Dim currentSheet As Long, auditRow As Long, missing As Long
    Dim countRows As Long, totalKept As Long, totalExcluded As Long
    Dim arrInput As Variant, arrOut As Variant, rowIndexes() As Long
    Dim curId As String, caem2 As String, caemAct As String
    Dim finalCode As String, section As String, resultStatus As Long
    Dim folder As String, outputPath As String
    Dim isReady As Boolean, nSheets As Long
    Dim msg As String

    On Error GoTo HandleError
    Set wbS = ActiveWorkbook
    If wbS Is Nothing Then Err.Raise vbObjectError + 11, , "Nu exista un fisier Excel activ."
    If Len(wbS.Path) = 0 Then
        Err.Raise vbObjectError + 12, , "Salveaza fisierul ASA_CAPITOLE_2025.xlsx intr-un folder inainte de rulare."
    End If

    On Error Resume Next
    Set wsRef = wbS.Worksheets("CAP1")
    On Error GoTo HandleError
    If wsRef Is Nothing Then
        Err.Raise vbObjectError + 13, , "Nu exista foaia CAP1. Deschide ASA_CAPITOLE_2025.xlsx din arhiva."
    End If

    cuiioCol = FindHeader(wsRef, "CUIIO")
    caemCol = FindHeader(wsRef, "CAEM2")
    actualCol = FindHeader(wsRef, "CAEM_ACT")
    If cuiioCol = 0 Or caemCol = 0 Or actualCol = 0 Then
        Err.Raise vbObjectError + 14, , "In CAP1 lipsesc CUIIO / CAEM2 / CAEM_ACT."
    End If

    oldCalc = Application.Calculation
    oldScreen = Application.ScreenUpdating
    oldEvents = Application.EnableEvents
    oldAlerts = Application.DisplayAlerts
    oldStatus = Application.StatusBar
    isReady = True
    Application.ScreenUpdating = False
    Application.EnableEvents = False
    Application.DisplayAlerts = False
    Application.Calculation = xlCalculationManual

    ' PASUL 1: stabilim eligibilitatea O SINGURA DATA pentru fiecare CUIIO.
    ' CAP1 contine aceiasi CUIIO si aceleasi coduri CAEM ca restul foilor.
    Set status = New Collection
    Set excluded = New Collection
    refLastRow = wsRef.Cells(wsRef.Rows.Count, cuiioCol).End(xlUp).Row
    If refLastRow < FIRST_DATA_ROW Then Err.Raise vbObjectError + 15, , "CAP1 nu contine date."
    Application.StatusBar = "ASA / CAEM2: identificare intreprinderi eligibile din CAP1..."
    baseData = wsRef.Range(wsRef.Cells(FIRST_DATA_ROW, 1), wsRef.Cells(refLastRow, actualCol)).Value2

    For i = 1 To UBound(baseData, 1)
        curId = CleanCUIIO(baseData(i, cuiioCol))
        If Len(curId) = 0 Then Err.Raise vbObjectError + 16, , "CUIIO gol in CAP1, randul " & CStr(i + 1)
        If StatusForCUIIO(status, curId) <> -1 Then
            Err.Raise vbObjectError + 17, , "CUIIO dublat in CAP1: " & curId
        End If

        caem2 = TrimmedText(baseData(i, caemCol))
        caemAct = TrimmedText(baseData(i, actualCol))
        If Len(caemAct) > 0 Then
            finalCode = NormalizeCAEM4(caemAct)
        Else
            finalCode = NormalizeCAEM4(caem2)
        End If
        section = CAEMSection(finalCode)

        If IsIncludedSection(section, finalCode) Then
            status.Add 1, curId
            totalKept = totalKept + 1
        Else
            status.Add 0, curId
            totalExcluded = totalExcluded + 1
            excluded.Add Array(curId, caem2, caemAct, finalCode, section)
        End If
    Next i
    Erase baseData

    ' PASUL 2: construim FISIER NOU de date, fara a altera sursa.
    Set wbO = Workbooks.Add(xlWBATWorksheet)
    Set wsAudit = wbO.Worksheets(1)
    wsAudit.Name = "CONTROL_CAEM2"
    wsAudit.Range("A1:G1").Value = Array("Foaie sursa", "Randuri initiale", "Randuri incluse", "Randuri excluse", "CUIIO lipsa in CAP1", "Text numeric corectat", "Valori invalide")
    wsAudit.Range("I1:J1").Value = Array("Parametru", "Valoare")
    wsAudit.Range("I2:J2").Value = Array("CAEM actualizat", "CAEM_ACT, daca nu este gol")
    wsAudit.Range("I3:J3").Value = Array("CAEM initial (fallback)", "CAEM2")
    wsAudit.Range("I4:J4").Value = Array("Sectiuni incluse", "B,C,D,E,F,G,H,I,J,L,M,N,S")
    wsAudit.Range("I5:J5").Value = Array("Excludere explicita", "S94")
    wsAudit.Range("I6:J6").Value = Array("Sursa eligibilitate", "CAP1, dupa CUIIO")
    wsAudit.Range("I7:J7").Value = Array("Baza de calcul", "CAEM2 rev.2 - diviziuni 2 cifre")
    wsAudit.Range("I8:J8").Value = Array("Indicatori", "Textul numeric este convertit in numar doar in fisierul NOU.")
    wsAudit.Range("I9:J9").Value = Array("Doua totaluri", "CURENT=cu filtru; PRECEDENT=fara filtru (nu ani).")

    Set wsExcluded = wbO.Worksheets.Add(After:=wsAudit)
    wsExcluded.Name = "EXCLUSE_CAEM2"
    wsExcluded.Range("A1:E1").Value = Array("CUIIO", "CAEM2 initial", "CAEM_ACT", "CAEM final", "Sectiune")
    If excluded.Count > 0 Then
        ReDim arrOut(1 To excluded.Count, 1 To 5)
        For i = 1 To excluded.Count
            keys = excluded.Item(i)
            For c = 1 To 5: arrOut(i, c) = keys(c - 1): Next c
        Next i
        wsExcluded.Range("A2").Resize(excluded.Count, 5).Value2 = arrOut
        Erase arrOut
    End If

    ' Valorile nerecunoscute ca numere sunt afisate intr-o foaie separata.
    ' In acest caz totalul coloanei vizate devine text "VERIFICA (n)",
    ' nu o suma partiala inselatoare.
    Set wsNumeric = wbO.Worksheets.Add(After:=wsExcluded)
    wsNumeric.Name = "CONTROL_NUMERIC"
    wsNumeric.Range("A1:F1").Value = Array("Foaie", "Rand sursa", "Coloana", "Indicator", "Valoare originala", "Problema")
    numericAuditRow = 2

    auditRow = 2
    For Each wsS In wbS.Worksheets
        cuiioCol = FindHeader(wsS, "CUIIO")
        caemCol = FindHeader(wsS, "CAEM2")
        actualCol = FindHeader(wsS, "CAEM_ACT")
        ' Sunt procesate exclusiv foile capitolelor care contin aceste antete.
        If cuiioCol > 0 And caemCol > 0 And actualCol > 0 Then
            nSheets = nSheets + 1
            Application.StatusBar = "ASA / CAEM2: filtrare foaie " & wsS.Name & "..."
            Set wsO = wbO.Worksheets.Add(After:=wbO.Worksheets(wbO.Worksheets.Count))
            wsO.Name = wsS.Name
            lastRow = wsS.Cells(wsS.Rows.Count, cuiioCol).End(xlUp).Row
            lastCol = wsS.Cells(1, wsS.Columns.Count).End(xlToLeft).Column
            firstNumericCol = actualCol + 1
            If firstNumericCol > lastCol Then
                Err.Raise vbObjectError + 21, , wsS.Name & ": nu sunt coloane de indicator dupa CAEM_ACT."
            End If
            ReDim currentTotal(1 To lastCol)
            ReDim previousTotal(1 To lastCol)
            ReDim invalidCurrent(1 To lastCol)
            ReDim invalidPrevious(1 To lastCol)
            convertedSheet = 0
            invalidSheet = 0

            ' Antetele se copiaza cu formatarea de baza.
            wsS.Range(wsS.Cells(1, 1), wsS.Cells(1, lastCol)).Copy Destination:=wsO.Cells(1, 1)
            wsO.Range(wsO.Cells(1, 1), wsO.Cells(1, lastCol)).Font.Bold = True
            wsO.Activate
            ActiveWindow.FreezePanes = False
            ActiveWindow.SplitRow = 1
            ActiveWindow.FreezePanes = True

            outRow = FIRST_DATA_ROW
            missing = 0
            kept = 0
            dropped = 0
            For row0 = FIRST_DATA_ROW To lastRow Step BLOCK_SIZE
                rowN = row0 + BLOCK_SIZE - 1
                If rowN > lastRow Then rowN = lastRow
                arrInput = wsS.Range(wsS.Cells(row0, 1), wsS.Cells(rowN, lastCol)).Value2
                countRows = UBound(arrInput, 1)
                ReDim rowIndexes(1 To countRows)
                k = 0
                For i = 1 To countRows
                    curId = CleanCUIIO(arrInput(i, cuiioCol))
                    resultStatus = StatusForCUIIO(status, curId)
                    If resultStatus = 1 Then
                        k = k + 1
                        rowIndexes(k) = i
                    Else
                        dropped = dropped + 1
                        If resultStatus = -1 Then missing = missing + 1
                    End If

                    ' Calculeaza PRECEDENT pe TOATE randurile sursei si
                    ' CURENT doar pe randurile eligibile. Normalizeaza orice
                    ' numar pastrat ca text (virgula/punct/spatii etc.).
                    For c = firstNumericCol To lastCol
                        invalidReason = vbNullString
                        checkState = ParseIndicatorNumeric(arrInput(i, c), numericValue, wasConverted, invalidReason)
                        Select Case checkState
                            Case 1
                                previousTotal(c) = previousTotal(c) + numericValue
                                If resultStatus = 1 Then
                                    currentTotal(c) = currentTotal(c) + numericValue
                                    If wasConverted Then arrInput(i, c) = numericValue
                                End If
                                If wasConverted And resultStatus = 1 Then
                                    convertedSheet = convertedSheet + 1
                                    convertedAll = convertedAll + 1
                                End If
                            Case -1
                                invalidPrevious(c) = invalidPrevious(c) + 1
                                If resultStatus = 1 Then invalidCurrent(c) = invalidCurrent(c) + 1
                                invalidSheet = invalidSheet + 1
                                invalidAll = invalidAll + 1
                                If numericAuditRow <= 10001 Then
                                    invalidCell = InvalidValueText(arrInput(i, c))
                                    wsNumeric.Cells(numericAuditRow, 1).Resize(1, 6).Value = _
                                        Array(wsS.Name, row0 + i - 1, ColumnLetter(c), _
                                              CStr(wsS.Cells(1, c).Value2), invalidCell, invalidReason)
                                    numericAuditRow = numericAuditRow + 1
                                End If
                            Case 0
                                ' NULL, celula goala sau un simplu '-' = fara valoare.
                        End Select
                    Next c
                Next i
                If k > 0 Then
                    ReDim arrOut(1 To k, 1 To lastCol)
                    For i = 1 To k
                        For c = 1 To lastCol
                            arrOut(i, c) = arrInput(rowIndexes(i), c)
                        Next c
                    Next i
                    wsO.Cells(outRow, 1).Resize(k, lastCol).Value2 = arrOut
                    outRow = outRow + k
                    kept = kept + k
                    Erase arrOut
                End If
                Erase arrInput
                Erase rowIndexes
            Next row0
            If missing > 0 Then
                Err.Raise vbObjectError + 18, , wsS.Name & ": " & missing & " CUIIO nu apar in CAP1. Rezultatul nu a fost salvat."
            End If
            If kept + dropped <> lastRow - 1 Then
                Err.Raise vbObjectError + 19, , "Control nereusit la " & wsS.Name
            End If
            ' Adaugam TOTALURILE dupa date, fara a le include in AutoFilter.
            currentRow = outRow
            previousRow = outRow + 1
            wsO.Cells(currentRow, 1).Value = "SUMA CURENT - CU FILTRU CAEM2"
            wsO.Cells(previousRow, 1).Value = "SUMA PRECEDENT - FARA FILTRU"
            For c = firstNumericCol To lastCol
                If invalidCurrent(c) = 0 Then
                    wsO.Cells(currentRow, c).Value2 = currentTotal(c)
                Else
                    wsO.Cells(currentRow, c).Value = "VERIFICA (" & invalidCurrent(c) & ")"
                End If
                If invalidPrevious(c) = 0 Then
                    wsO.Cells(previousRow, c).Value2 = previousTotal(c)
                Else
                    wsO.Cells(previousRow, c).Value = "VERIFICA (" & invalidPrevious(c) & ")"
                End If
            Next c
            With wsO.Range(wsO.Cells(currentRow, 1), wsO.Cells(currentRow, lastCol))
                .Font.Bold = True
                .Interior.Color = RGB(224, 243, 225)
                .NumberFormat = "#,##0.##########"
            End With
            With wsO.Range(wsO.Cells(previousRow, 1), wsO.Cells(previousRow, lastCol))
                .Font.Bold = True
                .Interior.Color = RGB(230, 236, 246)
                .NumberFormat = "#,##0.##########"
            End With
            wsO.Cells(currentRow, 1).NumberFormat = "General"
            wsO.Cells(previousRow, 1).NumberFormat = "General"
            wsO.Columns(1).ColumnWidth = 33
            If outRow > FIRST_DATA_ROW Then
                wsO.Range(wsO.Cells(1, 1), wsO.Cells(outRow - 1, lastCol)).AutoFilter
            End If
            wsAudit.Cells(auditRow, 1).Resize(1, 7).Value = _
                Array(wsS.Name, lastRow - 1, kept, dropped, missing, convertedSheet, invalidSheet)
            auditRow = auditRow + 1
        End If
    Next wsS

    If nSheets = 0 Then Err.Raise vbObjectError + 20, , "Nicio foaie CAP cu antetele necesare."
    wsAudit.Cells(auditRow, 1).Value = "TOTAL FOI: " & nSheets
    wsAudit.Range("I10:J10").Value = Array("CUIIO incluse", totalKept)
    wsAudit.Range("I11:J11").Value = Array("CUIIO excluse", totalExcluded)
    wsAudit.Range("I12:J12").Value = Array("CUIIO total", totalKept + totalExcluded)
    wsAudit.Range("I13:J13").Value = Array("Text numeric corectat", convertedAll)
    wsAudit.Range("I14:J14").Value = Array("Erori numerice", invalidAll)
    wsAudit.Range("I15:J15").Value = Array("Explicatie PRECEDENT", "Totalul tuturor randurilor originale, fara filtrare.")
    wsAudit.Range("A1:G1").Font.Bold = True
    wsAudit.Range("I1:J1").Font.Bold = True
    wsAudit.Columns("A:G").AutoFit
    wsAudit.Columns("I:I").ColumnWidth = 24
    wsAudit.Columns("J:J").ColumnWidth = 52
    wsAudit.Range("J2:J15").WrapText = True
    wsExcluded.Range("A1:E1").Font.Bold = True
    wsExcluded.Columns("A:E").AutoFit
    wsNumeric.Range("A1:F1").Font.Bold = True
    wsNumeric.Columns("A:F").AutoFit
    wsNumeric.Columns("E:E").ColumnWidth = 30
    wsNumeric.Columns("F:F").ColumnWidth = 44
    If invalidAll > numericAuditRow - 2 Then
        wsNumeric.Cells(numericAuditRow + 1, 1).Value = _
            "Nota: doar primele 10000 valori invalide sunt detaliate. Total: " & CStr(invalidAll)
    End If
    wsAudit.Activate

    folder = wbS.Path
    If Right$(folder, 1) = Application.PathSeparator Then
        outputPath = folder & "ASA_CAPITOLE_2025_CAEM2_FILTRAT.xlsx"
    Else
        outputPath = folder & Application.PathSeparator & "ASA_CAPITOLE_2025_CAEM2_FILTRAT.xlsx"
    End If
    If Len(Dir$(outputPath)) > 0 Then
        outputPath = Left$(outputPath, Len(outputPath) - 5) & "_" & Format$(Now, "yyyymmdd_hhnnss") & ".xlsx"
    End If
    wbO.SaveAs Filename:=outputPath, FileFormat:=xlOpenXMLWorkbook, CreateBackup:=False

    RestoreApplication oldCalc, oldScreen, oldEvents, oldAlerts, oldStatus
    MsgBox "Fisier creat:" & vbCrLf & outputPath & vbCrLf & vbCrLf & _
           "CUIIO incluse: " & Format$(totalKept, "#,##0") & vbCrLf & _
           "CUIIO excluse: " & Format$(totalExcluded, "#,##0") & vbCrLf & _
           "Foi filtrate: " & nSheets & vbCrLf & _
           "Text numeric corectat: " & convertedAll & vbCrLf & _
           "Valori invalide (vezi CONTROL_NUMERIC): " & invalidAll & vbCrLf & _
           "CURENT=filtrat; PRECEDENT=original, fara filtrare.", _
           vbInformation, "ASA 2025 / Filtru CAEM2 si totaluri"
    Exit Sub

HandleError:
    msg = "Eroare la filtrare: " & Err.Description
    On Error Resume Next
    If Not wbO Is Nothing Then wbO.Close SaveChanges:=False
    If isReady Then RestoreApplication oldCalc, oldScreen, oldEvents, oldAlerts, oldStatus
    MsgBox msg, vbExclamation, "ASA / Filtru CAEM2"
End Sub

Private Function FindHeader(ByVal ws As Worksheet, ByVal headerName As String) As Long
    Dim cell As Range
    Set cell = ws.Rows(1).Find(What:=headerName, LookIn:=xlValues, _
                LookAt:=xlWhole, SearchOrder:=xlByColumns, MatchCase:=False)
    If Not cell Is Nothing Then FindHeader = cell.Column
End Function

Private Function TrimmedText(ByVal v As Variant) As String
    If IsError(v) Then Exit Function
    If IsNull(v) Or IsEmpty(v) Then Exit Function
    TrimmedText = Trim$(Replace(CStr(v), ChrW$(160), " "))
End Function

Private Function CleanCUIIO(ByVal v As Variant) As String
    CleanCUIIO = TrimmedText(v)
    ' CUIIO in ASA este numeric sau text cu cifre.
    If InStr(CleanCUIIO, ".") > 0 Then
        If IsNumeric(CleanCUIIO) Then CleanCUIIO = Format$(CDbl(CleanCUIIO), "0")
    End If
End Function

Private Function NormalizeCAEM4(ByVal v As Variant) As String
    Dim code As String
    code = UCase$(TrimmedText(v))
    code = Replace(code, ".", "")
    code = Replace(code, " ", "")
    If Len(code) = 5 Then
        If Left$(code, 1) Like "[A-Z]" Then code = Mid$(code, 2)
    End If
    If Len(code) = 0 Then Exit Function
    If IsNumeric(code) And Len(code) <= 4 Then
        NormalizeCAEM4 = Right$("0000" & CStr(CLng(Val(code))), 4)
    End If
End Function

' CAEM-2 rev.2: asociere DIVIZIUNE (primele 2 cifre) -> SECTIUNE.
' Folosit pentru a reproduce filtrul din VW_CL_CAEM2 din Tab.3.5.
Private Function CAEMSection(ByVal fourDigits As String) As String
    Dim d As Long
    If Len(fourDigits) <> 4 Then Exit Function
    If Not IsNumeric(fourDigits) Then Exit Function
    d = CLng(Left$(fourDigits, 2))
    Select Case d
        Case 1 To 3: CAEMSection = "A"
        Case 5 To 9: CAEMSection = "B"
        Case 10 To 33: CAEMSection = "C"
        Case 35: CAEMSection = "D"
        Case 36 To 39: CAEMSection = "E"
        Case 41 To 43: CAEMSection = "F"
        Case 45 To 47: CAEMSection = "G"
        Case 49 To 53: CAEMSection = "H"
        Case 55 To 56: CAEMSection = "I"
        Case 58 To 63: CAEMSection = "J"
        Case 64 To 66: CAEMSection = "K"
        Case 68: CAEMSection = "L"
        Case 69 To 75: CAEMSection = "M"
        Case 77 To 82: CAEMSection = "N"
        Case 84: CAEMSection = "O"
        Case 85: CAEMSection = "P"
        Case 86 To 88: CAEMSection = "Q"
        Case 90 To 93: CAEMSection = "R"
        Case 94 To 96: CAEMSection = "S"
        Case 97 To 98: CAEMSection = "T"
        Case 99: CAEMSection = "U"
    End Select
End Function

Private Function IsIncludedSection(ByVal sec As String, ByVal caem4 As String) As Boolean
    Select Case sec
        Case "B", "C", "D", "E", "F", "G", "H", "I", "J", "L", "M", "N"
            IsIncludedSection = True
        Case "S"
            IsIncludedSection = (Left$(caem4, 2) <> "94")
    End Select
End Function

' Collection folosita in locul Scripting.Dictionary pentru Windows/Mac.
Private Function StatusForCUIIO(ByVal statuses As Collection, ByVal key As String) As Long
    On Error GoTo MissingKey
    StatusForCUIIO = CLng(statuses.Item(key))
    Exit Function
MissingKey:
    StatusForCUIIO = -1
    Err.Clear
End Function

Private Sub RestoreApplication(ByVal calc As XlCalculation, ByVal screen As Boolean, _
        ByVal eventsOn As Boolean, ByVal alertsOn As Boolean, ByVal statusBar As Variant)
    On Error Resume Next
    Application.Calculation = calc
    Application.ScreenUpdating = screen
    Application.EnableEvents = eventsOn
    Application.DisplayAlerts = alertsOn
    Application.StatusBar = statusBar
End Sub


' Returneaza: 1=valoare numerica; 0=gol / '-' ; -1=invalid.
' FARA conversie implicita prin CDbl pe stringuri: depinde de locale.
' Val() citeste numere cu punct zecimal in mod independent de locale.
Private Function ParseIndicatorNumeric(ByVal v As Variant, ByRef number As Double, _
        ByRef converted As Boolean, ByRef reason As String) As Long
    Dim s As String, sSign As String, signPart As String
    Dim dotPos As Long, commaPos As Long, dotCount As Long, commaCount As Long
    Dim negativeParens As Boolean
    Dim parsed As Double, groupPrefix As String

    number = 0#
    converted = False
    reason = vbNullString

    If IsError(v) Then
        reason = "Celula contine o eroare Excel (ex. #VALUE!, #N/A)."
        ParseIndicatorNumeric = -1
        Exit Function
    End If
    If IsEmpty(v) Or IsNull(v) Then Exit Function
    If VarType(v) = vbBoolean Or VarType(v) = vbDate Then
        reason = "Tip invalid pentru indicator numeric (boolean/data)."
        ParseIndicatorNumeric = -1
        Exit Function
    End If
    If VarType(v) <> vbString Then
        If IsNumeric(v) Then
            number = CDbl(v)
            ParseIndicatorNumeric = 1
        Else
            reason = "Tip non-numeric necunoscut."
            ParseIndicatorNumeric = -1
        End If
        Exit Function
    End If

    s = Trim$(CStr(v))
    s = Replace(s, ChrW$(160), "")   ' NBSP
    s = Replace(s, ChrW$(8239), "")  ' narrow NBSP
    s = Replace(s, vbTab, "")
    s = Replace(s, vbCr, "")
    s = Replace(s, vbLf, "")
    s = Replace(s, " ", "")       ' separatori de mii cu spatiu
    s = Replace(s, ChrW$(8722), "-")  ' semnul minus Unicode
    s = Replace(s, ChrW$(8211), "-")  ' en-dash
    s = Replace(s, ChrW$(8212), "-")  ' em-dash

    If Len(s) = 0 Or s = "-" Then Exit Function
    If Left$(s, 1) = "'" Then s = Mid$(s, 2)  ' prefix text Excel

    If Left$(s, 1) = "(" And Right$(s, 1) = ")" Then
        negativeParens = True
        s = Mid$(s, 2, Len(s) - 2)
    End If
    If Len(s) = 0 Then Exit Function
    signPart = vbNullString
    If Left$(s, 1) = "-" Or Left$(s, 1) = "+" Then
        signPart = Left$(s, 1)
        s = Mid$(s, 2)
    End If
    If negativeParens Then
        If Len(signPart) > 0 Then
            reason = "Semn de minus repetat."
            ParseIndicatorNumeric = -1
            Exit Function
        End If
        signPart = "-"
    End If

    ' Apostroful ca separator de mii: acceptam doar 1'234 sau 1'234'567.
    If InStr(s, "'") > 0 Then
        groupPrefix = Split(Split(s, ",")(0), ".")(0)
        If Not IsValidThousandsPrefix(groupPrefix, "'") Then
            reason = "Apostrof invalid ca separator de mii."
            ParseIndicatorNumeric = -1
            Exit Function
        End If
        s = Replace(s, "'", "")
    End If

    dotCount = Len(s) - Len(Replace(s, ".", ""))
    commaCount = Len(s) - Len(Replace(s, ",", ""))
    dotPos = InStrRev(s, ".")
    commaPos = InStrRev(s, ",")

    If dotCount > 0 And commaCount > 0 Then
        ' Ultimul separator este zecimal; celalalt este pentru mii.
        If dotPos > commaPos Then
            If Not IsValidThousandsPrefix(Left$(s, dotPos - 1), ",") Then
                reason = "Separatorii de mii sunt grupati incorect."
                ParseIndicatorNumeric = -1
                Exit Function
            End If
            s = Replace(s, ",", "")
        Else
            If Not IsValidThousandsPrefix(Left$(s, commaPos - 1), ".") Then
                reason = "Separatorii de mii sunt grupati incorect."
                ParseIndicatorNumeric = -1
                Exit Function
            End If
            s = Replace(s, ".", "")
            s = Replace(s, ",", ".")
        End If
    ElseIf commaCount > 1 Then
        ' 1,234,567 (mii), nu mai multe virgule zecimale.
        If Not IsGroupedThousands(s, ",") Then
            reason = "Separatoare de mii/zecimale inconsistente."
            ParseIndicatorNumeric = -1
            Exit Function
        End If
        s = Replace(s, ",", "")
    ElseIf dotCount > 1 Then
        If Not IsGroupedThousands(s, ".") Then
            reason = "Separatoare de mii/zecimale inconsistente."
            ParseIndicatorNumeric = -1
            Exit Function
        End If
        s = Replace(s, ".", "")
    ElseIf commaCount = 1 Then
        s = Replace(s, ",", ".")
    End If

    sSign = signPart & s
    If Not IsValidNumericLiteral(sSign) Then
        reason = "Textul nu reprezinta un numar valid: " & Left$(CStr(v), 90)
        ParseIndicatorNumeric = -1
        Exit Function
    End If
    On Error GoTo ParseFail
    parsed = Val(sSign)
    number = parsed
    converted = True
    ParseIndicatorNumeric = 1
    Exit Function
ParseFail:
    reason = "Nu se poate converti numarul (depasire limita)."
    ParseIndicatorNumeric = -1
    Err.Clear
End Function

Private Function IsValidThousandsPrefix(ByVal prefix As String, ByVal separator As String) As Boolean
    Dim chunks() As String, i As Long, j As Long
    chunks = Split(prefix, separator)
    If UBound(chunks) = 0 Then Exit Function
    If Len(chunks(0)) < 1 Or Len(chunks(0)) > 3 Then Exit Function
    For i = LBound(chunks) To UBound(chunks)
        If i > 0 And Len(chunks(i)) <> 3 Then Exit Function
        For j = 1 To Len(chunks(i))
            If Mid$(chunks(i), j, 1) < "0" Or Mid$(chunks(i), j, 1) > "9" Then Exit Function
        Next j
    Next i
    IsValidThousandsPrefix = True
End Function

Private Function IsGroupedThousands(ByVal s As String, ByVal separator As String) As Boolean
    Dim tokens() As String, i As Long, j As Long
    tokens = Split(s, separator)
    If UBound(tokens) < 2 Then Exit Function
    If Len(tokens(0)) < 1 Or Len(tokens(0)) > 3 Then Exit Function
    For i = LBound(tokens) To UBound(tokens)
        If i > 0 And Len(tokens(i)) <> 3 Then Exit Function
        For j = 1 To Len(tokens(i))
            If Mid$(tokens(i), j, 1) < "0" Or Mid$(tokens(i), j, 1) > "9" Then Exit Function
        Next j
    Next i
    IsGroupedThousands = True
End Function

Private Function IsValidNumericLiteral(ByVal s As String) As Boolean
    Dim i As Long, k As String, dots As Long, exponentCount As Long
    Dim mantissaDigits As Long, exponentDigits As Long, afterExponent As Boolean
    For i = 1 To Len(s)
        k = Mid$(s, i, 1)
        Select Case k
            Case "0" To "9"
                If afterExponent Then
                    exponentDigits = exponentDigits + 1
                Else
                    mantissaDigits = mantissaDigits + 1
                End If
            Case "."
                If afterExponent Then Exit Function
                dots = dots + 1
                If dots > 1 Then Exit Function
            Case "e", "E"
                If afterExponent Or mantissaDigits = 0 Then Exit Function
                afterExponent = True
                exponentCount = exponentCount + 1
            Case "+", "-"
                If i > 1 Then
                    If Not (afterExponent And (Mid$(s, i - 1, 1) = "e" Or Mid$(s, i - 1, 1) = "E")) Then Exit Function
                End If
            Case Else
                Exit Function
        End Select
    Next i
    IsValidNumericLiteral = (mantissaDigits > 0 And (Not afterExponent Or exponentDigits > 0))
End Function

Private Function InvalidValueText(ByVal v As Variant) As String
    If IsError(v) Then
        InvalidValueText = "Eroare Excel"
    ElseIf IsNull(v) Or IsEmpty(v) Then
        InvalidValueText = ""
    Else
        InvalidValueText = Left$(CStr(v), 150)
    End If
End Function

Private Function ColumnLetter(ByVal idx As Long) As String
    Dim d As Long, letter As String
    Do While idx > 0
        d = (idx - 1) Mod 26
        letter = Chr$(65 + d) & letter
        idx = (idx - 1) \ 26
    Loop
    ColumnLetter = letter
End Function
