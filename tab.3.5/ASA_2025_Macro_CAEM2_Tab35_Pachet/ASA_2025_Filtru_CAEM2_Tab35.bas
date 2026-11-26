Attribute VB_Name = "ASA_Filtru_CAEM2_Tab35"
Option Explicit

' ================================================================
' ASA 2025: filtru CAEM2 identic metodologic cu Tab.3.5.
' Intrare: workbook ASA_CAPITOLE_2025.xlsx (dezarhivat din ZIP).
' Iesire: ASA_CAPITOLE_2025_CAEM2_FILTRAT.xlsx (14 foi + audit).
'
' Sursa eligibilitatii: CAP1, CUIIO, CAEM_ACT prioritar; CAEM2 fallback.
' Cele 14 foi ale exportului contin aceleasi 16.725 intreprinderi.
' Nu se modifica formulele/valorile indicatorilor si nici RIND_CD.
' Compatible VBA Windows / macOS: nu foloseste Scripting.Dictionary.
' ================================================================

Private Const FIRST_DATA_ROW As Long = 2
Private Const BLOCK_SIZE As Long = 250

Public Sub Filtreaza_ASA_2025_CAEM2_Tab35()
    Dim wbS As Workbook, wbO As Workbook
    Dim wsS As Worksheet, wsO As Worksheet, wsRef As Worksheet
    Dim wsAudit As Worksheet, wsExcluded As Worksheet
    Dim status As Collection, excluded As Collection
    Dim baseData As Variant, keys As Variant
    Dim oldCalc As XlCalculation
    Dim oldScreen As Boolean, oldEvents As Boolean, oldAlerts As Boolean
    Dim oldStatus As Variant
    Dim refLastRow As Long, lastRow As Long, lastCol As Long
    Dim cuiioCol As Long, caemCol As Long, actualCol As Long
    Dim i As Long, c As Long, k As Long, row0 As Long, rowN As Long
    Dim firstCol As Long, outRow As Long, kept As Long, dropped As Long
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
    wsAudit.Range("A1:E1").Value = Array("Foaie sursa", "Randuri initiale", "Randuri incluse", "Randuri excluse", "CUIIO lipsa in CAP1")
    wsAudit.Range("G1:H1").Value = Array("Parametru", "Valoare")
    wsAudit.Range("G2:H2").Value = Array("CAEM actualizat", "CAEM_ACT, daca nu este gol")
    wsAudit.Range("G3:H3").Value = Array("CAEM initial (fallback)", "CAEM2")
    wsAudit.Range("G4:H4").Value = Array("Sectiuni incluse", "B,C,D,E,F,G,H,I,J,L,M,N,S")
    wsAudit.Range("G5:H5").Value = Array("Excludere explicita", "S94")
    wsAudit.Range("G6:H6").Value = Array("Sursa eligibilitate", "CAP1, dupa CUIIO")
    wsAudit.Range("G7:H7").Value = Array("Baza de calcul", "CAEM2 rev.2 - diviziuni 2 cifre")
    wsAudit.Range("G8:H8").Value = Array("Modificari indicatori", "Niciuna. Se copiaza valorile originale.")

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
            wsO.Range(wsO.Cells(1, 1), wsO.Cells(1, lastCol)).AutoFilter
            wsAudit.Cells(auditRow, 1).Resize(1, 5).Value = Array(wsS.Name, lastRow - 1, kept, dropped, missing)
            auditRow = auditRow + 1
        End If
    Next wsS

    If nSheets = 0 Then Err.Raise vbObjectError + 20, , "Nicio foaie CAP cu antetele necesare."
    wsAudit.Cells(auditRow, 1).Value = "TOTAL FOI: " & nSheets
    wsAudit.Range("G10:H10").Value = Array("CUIIO incluse", totalKept)
    wsAudit.Range("G11:H11").Value = Array("CUIIO excluse", totalExcluded)
    wsAudit.Range("G12:H12").Value = Array("CUIIO total", totalKept + totalExcluded)
    wsAudit.Range("A1:E1").Font.Bold = True
    wsAudit.Range("G1:H1").Font.Bold = True
    wsAudit.Columns("A:E").AutoFit
    wsAudit.Columns("G:G").ColumnWidth = 24
    wsAudit.Columns("H:H").ColumnWidth = 52
    wsAudit.Range("H2:H8").WrapText = True
    wsExcluded.Range("A1:E1").Font.Bold = True
    wsExcluded.Columns("A:E").AutoFit
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
           "Foi filtrate: " & nSheets, vbInformation, "ASA 2025 / Filtru CAEM2"
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
