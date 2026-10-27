Attribute VB_Name = "ASA_Tab_2_3_1"
Option Explicit

' ASA 2025 / Tab.2.3.1. Import this module into ASA_2025_CAPITOLE.xlsm.
' Run Genereaza_Tab_2_3_1. No external references are required.
' Missing RIND_400_COL2 is interpreted as zero (as confirmed).

Private Const OUTPUT_NAME As String = "Tab_2_3_1"
Private Const CATALOG_NAME As String = "CAEM2_CATALOG"
' TOTAL is a synthetic reporting row, NOT a required CAEM2 activity/class.
' Its internal key is "00000" and its displayed value in Tab.2.3.1 is 0.
Private Const TOTAL_CAEM2_CODE As String = "00000"

Public Sub Genereaza_Tab_2_3_1()
    Dim wb As Workbook, wsCat As Worksheet, wsOut As Worksheet
    Dim byCode As Object, byNumber As Object, selected As Object, missingIndicators As Object, hasData As Object
    Dim codes() As String, labels() As String, chain() As String
    Dim values() As Double, countCatalog As Long, i As Long, j As Long
    Dim raw As Variant, code As String, key As String, chosen As String
    Dim segments As Variant, segment As Variant, index As Long
    Dim caem As String, updated As String, staff As Double, sr As String
    Dim inCount As Long, missingCount As Long, noCodeCount As Long, filteredOut As Long
    Dim oldCalc As XlCalculation, startTime As Double

    On Error GoTo Fail
    startTime = Timer
    Set wb = ThisWorkbook
    oldCalc = Application.Calculation
    Application.ScreenUpdating = False
    Application.EnableEvents = False
    Application.Calculation = xlCalculationManual

    Set wsCat = FindOrImportCatalog(wb)
    If wsCat Is Nothing Then Err.Raise vbObjectError + 101, , "Catalogul CAEM2 nu a fost ales."

    Set byCode = CreateObject("Scripting.Dictionary")
    Set byNumber = CreateObject("Scripting.Dictionary")
    byCode.CompareMode = vbTextCompare
    byNumber.CompareMode = vbTextCompare
    raw = wsCat.Range("A1:G" & wsCat.Cells(wsCat.Rows.Count, 1).End(xlUp).Row).Value2
    ' SQL uses the catalog twice: C matches CAEM_FINAL to a code, while CC
    ' enumerates all ancestors in C.FULL_CODE. PRIM is selected in SQL but is
    ' NOT a WHERE condition: PRIM=1 are terminal classes, PRIM=0 are groups.
    ' Both kinds must therefore remain available in byCode and the hierarchy.
    ' Create TOTAL first, regardless of whether the external catalog has it.
    ' Leave one spare index for this synthetic aggregate.
    ReDim codes(1 To UBound(raw, 1) + 1)
    ReDim labels(1 To UBound(raw, 1) + 1)
    ReDim chain(1 To UBound(raw, 1) + 1)
    ReDim values(1 To UBound(raw, 1) + 1, 1 To 46)
    countCatalog = 1
    codes(1) = TOTAL_CAEM2_CODE
    labels(1) = "TOTAL PE ACTIVITATI"
    chain(1) = TOTAL_CAEM2_CODE & ";"
    byCode.Add TOTAL_CAEM2_CODE, 1

    For i = 2 To UBound(raw, 1)
        code = Trim$(CStr(raw(i, 1)))
        ' Ignore any existing catalog TOTAL or numeric-zero placeholder.
        If Len(code) > 0 And code <> TOTAL_CAEM2_CODE And code <> "0" Then
            countCatalog = countCatalog + 1
            codes(countCatalog) = code
            labels(countCatalog) = CStr(raw(i, 2))
            chain(countCatalog) = CStr(raw(i, 5))
            byCode(code) = countCatalog
            If Len(code) = 5 And Right$(code, 4) <> "0000" Then
                byNumber(Mid$(code, 2, 4)) = code
            End If
        End If
    Next i

    ' First decide once per company, from Sheet 5 (CAP IV, row 400, col 2).
    Set selected = CreateObject("Scripting.Dictionary")
    Set missingIndicators = CreateObject("Scripting.Dictionary")
    selected.CompareMode = vbTextCompare
    raw = wb.Worksheets("Sheet 5").Range("A1:L" & wb.Worksheets("Sheet 5").Cells(Rows.Count, 2).End(xlUp).Row).Value2
    AssertColumn raw, 2, "CUIIO"
    AssertColumn raw, 9, "CAP_SR"
    AssertColumn raw, 10, "CAEM_ACT"
    AssertColumn raw, 12, "RIND_400_COL2"

    For i = 2 To UBound(raw, 1)
        sr = Trim$(CStr(raw(i, 9)))
        If sr = "1" Or sr = "5" Or sr = "6" Then
            staff = NumberOrZero(raw(i, 12))
            If staff >= 0 And staff <= 249 Then
                caem = UCase$(Trim$(CStr(raw(i, 8))))
                updated = UCase$(Trim$(CStr(raw(i, 10))))
                If updated <> "" Then
                    If Len(updated) = 5 Then
                        chosen = updated
                    ElseIf byNumber.Exists(updated) Then
                        chosen = byNumber(updated)
                    Else
                        chosen = ""
                    End If
                Else
                    chosen = caem
                End If
                If Len(chosen) > 0 And byCode.Exists(chosen) And IsEligibleActivityCode(chosen) Then
                    key = CompanyKey(raw, i)
                    If Not selected.Exists(key) Then
                        selected.Add key, chain(byCode(chosen))
                        inCount = inCount + 1
                        If IsEmpty(raw(i, 12)) Or Trim$(CStr(raw(i, 12))) = "" Then missingCount = missingCount + 1
                    End If
                Else
                    noCodeCount = noCodeCount + 1
                End If
            End If
        End If
    Next i
    Erase raw

    ' VW_DATA_ALL contains only reported chapter rows. The wide workbook also
    ' has placeholder companies with every Chapter I/II cell empty. Exclude them
    ' from COUNT(DISTINCT CUIIO), exactly as in the SQL inner join.
    Set hasData = CreateObject("Scripting.Dictionary")
    hasData.CompareMode = vbTextCompare
    MarkReportedCompanies wb.Worksheets("Sheet 1"), selected, hasData
    MarkReportedCompanies wb.Worksheets("Sheet 2"), selected, hasData
    For Each segment In selected.Keys
        If Not hasData.Exists(CStr(segment)) Then
            selected.Remove CStr(segment)
            filteredOut = filteredOut + 1
        End If
    Next segment
    inCount = selected.Count

    ' COL1 is COUNT(DISTINCT CUIIO), rolled up along the CAEM2 catalog tree.
    For Each segment In selected.Keys
        segments = Split(CStr(selected(segment)), ";")
        For j = LBound(segments) To UBound(segments)
            code = CStr(segments(j))
            If byCode.Exists(code) Then
                index = byCode(code)
                values(index, 1) = values(index, 1) + 1
            End If
        Next j
    Next segment

    ' The 45 additive indicators are taken from Chapters I and II.
    ' Source column names map 1:1 to the CASE WHEN ... SUM(D.COL1) in SQL.
    AccumulateSheet wb.Worksheets("Sheet 1"), selected, byCode, values, missingIndicators, 2, 15
    AccumulateSheet wb.Worksheets("Sheet 2"), selected, byCode, values, missingIndicators, 17, 30

    ' CAEM2 TOTAL is synthetic. The official Excel report displays it as 0.
    ' Rebuild all 46 measures explicitly as the sum of B-S section totals.
    RebuildGrandTotal codes, byCode, values, selected.Count

    If SheetExists(wb, OUTPUT_NAME) Then
        If MsgBox("Sheet-ul '" & OUTPUT_NAME & "' exista. Il inlocuim?", vbYesNo + vbQuestion) <> vbYes Then GoTo CleanExit
        Application.DisplayAlerts = False
        wb.Worksheets(OUTPUT_NAME).Delete
        Application.DisplayAlerts = True
    End If
    Set wsOut = wb.Worksheets.Add(Before:=wb.Worksheets(1))
    wsOut.Name = OUTPUT_NAME
    WriteOutput wsOut, codes, labels, values, missingIndicators, countCatalog, inCount, missingCount, noCodeCount, filteredOut
    MsgBox "Tab.2.3.1 a fost generat. Unitati statistice eligibile: " & inCount & _
           ". RIND_400_COL2 lipsa (tratate ca 0): " & missingCount & ".", vbInformation

CleanExit:
    Application.DisplayAlerts = True
    Application.Calculation = oldCalc
    Application.EnableEvents = True
    Application.ScreenUpdating = True
    Exit Sub
Fail:
    MsgBox "Eroare la generarea Tab.2.3.1: " & Err.Description, vbCritical
    Resume CleanExit
End Sub

Private Sub RebuildGrandTotal(ByRef codes() As String, ByVal byCode As Object, _
                              ByRef totals() As Double, ByVal expectedCompanies As Long)
    Dim root As Long, i As Long, j As Long, sect As String
    If Not byCode.Exists(TOTAL_CAEM2_CODE) Then Err.Raise vbObjectError + 104, , _
        "Randul intern TOTAL CAEM2 nu a fost initializat."
    root = CLng(byCode(TOTAL_CAEM2_CODE))
    For j = 1 To 46
        totals(root, j) = 0
    Next j
    For i = LBound(codes) To UBound(codes)
        sect = codes(i)
        If Len(sect) = 5 And sect <> TOTAL_CAEM2_CODE Then
            If Right$(sect, 4) = "0000" And IsEligibleCatalogRow(sect) Then
                For j = 1 To 46
                    totals(root, j) = totals(root, j) + totals(i, j)
                Next j
            End If
        End If
    Next i
    If totals(root, 1) <> expectedCompanies Then Err.Raise vbObjectError + 105, , _
        "TOTAL CAEM2 nu coincide cu numarul unitatilor statistice eligibile."
End Sub

Private Sub MarkReportedCompanies(ByVal ws As Worksheet, ByVal selected As Object, ByVal hasData As Object)
    Dim a As Variant, i As Long, j As Long, key As String
    a = ws.Range(ws.Cells(1, 1), ws.Cells(ws.Cells(ws.Rows.Count, 2).End(xlUp).Row, ws.Cells(1, ws.Columns.Count).End(xlToLeft).Column)).Value2
    For i = 2 To UBound(a, 1)
        key = CompanyKey(a, i)
        If selected.Exists(key) And Not hasData.Exists(key) Then
            For j = 11 To UBound(a, 2)
                If Not IsEmpty(a(i, j)) Then
                    If Not IsError(a(i, j)) Then
                        If Len(Trim$(CStr(a(i, j)))) > 0 Then
                            hasData(key) = True
                            Exit For
                        End If
                    End If
                End If
            Next j
        End If
    Next i
End Sub

Private Sub AccumulateSheet(ByVal ws As Worksheet, ByVal selected As Object, _
                            ByVal byCode As Object, ByRef totals() As Double, ByVal missingIndicators As Object, _
                            ByVal startOutputCol As Long, ByVal expectedFields As Long)
    Dim data As Variant, header As Object, columnMap() As Long, fieldNames As Variant
    Dim i As Long, j As Long, k As Long, idx As Long, n As Long
    Dim key As String, tokens As Variant, token As Variant, amount As Double
    fieldNames = IndicatorNames()
    data = ws.Range(ws.Cells(1, 1), ws.Cells(ws.Cells(ws.Rows.Count, 2).End(xlUp).Row, ws.Cells(1, ws.Columns.Count).End(xlToLeft).Column)).Value2
    AssertColumn data, 2, "CUIIO"
    Set header = CreateObject("Scripting.Dictionary")
    header.CompareMode = vbTextCompare
    For j = 1 To UBound(data, 2)
        header(Trim$(CStr(data(1, j)))) = j
    Next j
    ReDim columnMap(1 To expectedFields)
    For j = 1 To expectedFields
        k = startOutputCol + j - 1
        If header.Exists(fieldNames(k - 1)) Then
            columnMap(j) = CLng(header(fieldNames(k - 1)))
        Else
            columnMap(j) = 0
            missingIndicators(CStr(k)) = CStr(fieldNames(k - 1))
        End If
    Next j
    For i = 2 To UBound(data, 1)
        key = CompanyKey(data, i)
        If selected.Exists(key) Then
            tokens = Split(CStr(selected(key)), ";")
            For j = 1 To expectedFields
                If columnMap(j) = 0 Then GoTo NextField
                amount = NumberOrZero(data(i, columnMap(j)))
                If amount <> 0 Then
                    For Each token In tokens
                        If byCode.Exists(CStr(token)) Then
                            idx = byCode(CStr(token))
                            totals(idx, startOutputCol + j - 1) = totals(idx, startOutputCol + j - 1) + amount
                        End If
                    Next token
                End If
NextField:
            Next j
        End If
    Next i
End Sub

Private Function IndicatorNames() As Variant
    ' Positions correspond to output COL1...COL46; index 1 is a placeholder.
    IndicatorNames = Split("COUNT|RIND_100|RIND_110|RIND_111|RIND_112|RIND_120|RIND_121|RIND_122|RIND_130|RIND_140|RIND_150|RIND_151|RIND_160|RIND_170|RIND_180|" & _
      "RIND_200|RIND_210|RIND_220|RIND_221|RIND_222|RIND_240|RIND_241|RIND_242|RIND_243|RIND_260|RIND_270|RIND_280|RIND_281|RIND_282|RIND_290|" & _
      "RIND_2911|RIND_2912|RIND_292|RIND_293|RIND_2931|RIND_291|RIND_294|RIND_2941|RIND_2942|RIND_2943|RIND_2944|RIND_295|RIND_296|RIND_2961|RIND_2962|RIND_297", "|")
End Function

Private Function CompanyKey(ByRef a As Variant, ByVal r As Long) As String
    ' SQL COL1 = COUNT(DISTINCT D.CUIIO): one unit of observation per CUIIO.
    CompanyKey = Trim$(CStr(a(r, 2)))
End Function

Private Function NumberOrZero(ByVal value As Variant) As Double
    If IsError(value) Or IsEmpty(value) Or IsNull(value) Then Exit Function
    If Trim$(CStr(value)) = "" Then Exit Function
    If IsNumeric(value) Then NumberOrZero = CDbl(value)
End Function

Private Function IsEligibleActivityCode(ByVal code As String) As Boolean
    Dim letter As String
    code = UCase$(Trim$(code))
    If Len(code) <> 5 Then Exit Function
    letter = Left$(code, 1)
    If InStr(1, "BCDEFGHIJKLMNPQRS", letter, vbBinaryCompare) = 0 Then Exit Function
    If Left$(code, 3) = "S94" Or Left$(code, 3) = "K65" Then Exit Function
    If code = "K6419" Or code = "K6411" Then Exit Function
    If Right$(code, 4) = "0000" Then Exit Function
    IsEligibleActivityCode = True
End Function

Private Sub AssertColumn(ByRef a As Variant, ByVal columnNumber As Long, ByVal expected As String)
    If UCase$(Trim$(CStr(a(1, columnNumber)))) <> expected Then _
        Err.Raise vbObjectError + 103, , "Antet neasteptat la coloana " & columnNumber & ": " & expected
End Sub

Private Function SheetExists(ByVal wb As Workbook, ByVal name As String) As Boolean
    Dim s As Worksheet
    On Error Resume Next
    Set s = wb.Worksheets(name)
    SheetExists = Not s Is Nothing
    On Error GoTo 0
End Function

Private Function FindOrImportCatalog(ByVal wb As Workbook) As Worksheet
    Dim filePath As Variant, externalBook As Workbook, source As Worksheet
    If SheetExists(wb, CATALOG_NAME) Then
        Set FindOrImportCatalog = wb.Worksheets(CATALOG_NAME)
        Exit Function
    End If
    filePath = Application.GetOpenFilename("Excel (*.xlsx),*.xlsx", , "Alege VW_CL_CAEM2.xlsx")
    If VarType(filePath) = vbBoolean Then Exit Function
    Set externalBook = Workbooks.Open(CStr(filePath), ReadOnly:=True, UpdateLinks:=False)
    Set source = externalBook.Worksheets(1)
    Set FindOrImportCatalog = wb.Worksheets.Add(After:=wb.Worksheets(wb.Worksheets.Count))
    FindOrImportCatalog.Name = CATALOG_NAME
    With source.UsedRange
        FindOrImportCatalog.Range("A1").Resize(.Rows.Count, .Columns.Count).Value2 = .Value2
    End With
    externalBook.Close SaveChanges:=False
    FindOrImportCatalog.Visible = xlSheetVeryHidden
End Function

Private Sub WriteOutput(ByVal ws As Worksheet, ByRef codes() As String, _
                        ByRef labels() As String, ByRef totals() As Double, _
                        ByVal missingIndicators As Object, ByVal totalCodes As Long, ByVal enterpriseCount As Long, _
                        ByVal missingCount As Long, ByVal noCodeCount As Long, ByVal filteredOut As Long)
    Dim out() As Variant, i As Long, j As Long, r As Long, n As Long
    Dim outputRows As Long, summaryRows As Long, pass As Long, includeRow As Boolean
    Dim fields As Variant, code As String
    fields = IndicatorNames()
    ws.Cells(1, 1).Value2 = "Tab.2.3.1 - ASA 2025"
    ws.Cells(2, 1).Value2 = "Intreprinderi cu CAP_SR = 1,5,6; R400 COL2 = 0..249 (NULL=0); CAEM2 B-S cu excluderile prevazute"
    ws.Cells(3, 1).Value2 = "Unitati statistice cu date CAP I/II: " & enterpriseCount & " | Fara date CAP I/II: " & filteredOut & " | NULL R400 COL2: " & missingCount & " | CAEM excluse/nerecunoscute: " & noCodeCount
    ws.Cells(4, 1).Value2 = "Denumire activitate"
    ws.Cells(4, 2).Value2 = "Codul CAEM rev.2"
    ws.Cells(4, 3).Value2 = "Numarul unitatilor statistice (CUIIO distincte)"
    ws.Cells(5, 1).Value2 = "A"
    ws.Cells(5, 2).Value2 = "B"
    For j = 2 To 46
        ws.Cells(4, j + 2).Value2 = Replace$(fields(j - 1), "_", " ") & " col1"
        If missingIndicators.Exists(CStr(j)) Then
            ws.Cells(4, j + 2).Value2 = CStr(fields(j - 1)) & " - LIPSESTE IN SURSA"
        End If
    Next j
    For j = 1 To 46
        ws.Cells(5, j + 2).Value2 = j
    Next j
    ' The official report uses two UNION branches in this order:
    '   1) TOTAL + section totals B-S;
    '   2) TOTAL + all hierarchy levels with nonzero enterprise counts.
    ' Both branches are ordered by FULL_CODE (the catalog's native order).
    For pass = 1 To 2
        For i = 1 To totalCodes
            code = codes(i)
            includeRow = totals(i, 1) > 0 And IsEligibleCatalogRow(code)
            If pass = 1 Then includeRow = includeRow And (code = TOTAL_CAEM2_CODE Or Right$(code, 4) = "0000")
            If includeRow Then
                outputRows = outputRows + 1
                If pass = 1 Then summaryRows = summaryRows + 1
            End If
        Next i
    Next pass
    If outputRows = 0 Then Exit Sub
    ReDim out(1 To outputRows, 1 To 48)
    For pass = 1 To 2
        For i = 1 To totalCodes
            code = codes(i)
            includeRow = totals(i, 1) > 0 And IsEligibleCatalogRow(code)
            If pass = 1 Then includeRow = includeRow And (code = TOTAL_CAEM2_CODE Or Right$(code, 4) = "0000")
            If includeRow Then
                n = n + 1
                out(n, 1) = labels(i)
                If code = TOTAL_CAEM2_CODE Then out(n, 2) = 0 Else out(n, 2) = code
                For j = 1 To 46
                    If j > 1 And missingIndicators.Exists(CStr(j)) Then
                        out(n, j + 2) = Empty
                    Else
                        ' COL1 = integer company count; COL2..COL46 = at most two decimals.
                        out(n, j + 2) = Application.WorksheetFunction.Round(totals(i, j), IIf(j = 1, 0, 2))
                    End If
                Next j
            End If
        Next i
    Next pass
    ws.Range("A6").Resize(n, 48).Value2 = out
    With ws.Range("A4:AV5")
        .Font.Bold = True
        .Interior.Color = RGB(37, 67, 99)
        .Font.Color = vbWhite
        .WrapText = True
    End With
    ws.Rows("4:5").RowHeight = 32
    ws.Columns("A").ColumnWidth = 59
    ws.Columns("B").ColumnWidth = 17
    ws.Columns("C:AV").ColumnWidth = 16
    ws.Range("C6:AV" & n + 5).NumberFormat = "#,##0.00;[Red](#,##0.00);–"
    ws.Range("C6:C" & n + 5).NumberFormat = "0"
    ws.Range("A6:AV" & summaryRows + 5).Font.Bold = True
    With ws.Range("A" & summaryRows + 6 & ":AV" & summaryRows + 6)
        .Font.Bold = True
        .Interior.Color = RGB(221, 231, 241)
    End With
    ws.Range("A4:AV" & n + 5).AutoFilter
    ws.Activate
    ws.Range("C6").Select
    ActiveWindow.FreezePanes = True
End Sub

Private Function IsEligibleCatalogRow(ByVal code As String) As Boolean
    If code = TOTAL_CAEM2_CODE Then
        IsEligibleCatalogRow = True
    Else
        IsEligibleCatalogRow = InStr(1, "BCDEFGHIJKLMNPQRS", Left$(code, 1), vbBinaryCompare) > 0 _
            And Left$(code, 3) <> "S94" And Left$(code, 3) <> "K65" _
            And code <> "K6419" And code <> "K6411"
    End If
End Function
