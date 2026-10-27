# Sarcină tehnică detaliată — Tab.2.3.2 (ASA 2025)

## 1. Scop și structură

Tabelul prezintă numărul întreprinderilor și suma indicatorilor raportați, grupate după activitatea economică CAEM2. Are **28 de coloane de indicatori: COL1–COL28**. Coloanele **A — denumirea activității** și **B — codul CAEM2** sunt coloane de identificare, separate de indicatori.

Numerotarea și referințele din antet respectă chestionarul și antetul HTML furnizat.

## 2. Selectarea unităților

Se includ numai unitățile care îndeplinesc **simultan cele trei condiții**:

1. **AP SR:** rândul **1, 5 sau 6**.
2. **CAP IV, R400, COL2:** valoarea este între **0 și 249 inclusiv**; lipsa valorii se consideră **0**.
3. **CAEM2:** secțiunile **B, C, D, E, F, G, H, I, J, K, L, M, N, P, Q, R, S**, cu excluderea codurilor care încep cu **S94** sau **K65**, precum și a codurilor **K6419** și **K6411**. Se folosește **codul CAEM2 actualizat**; dacă acesta lipsește, se utilizează **codul CAEM2 din RENIM**. Condiția se verifică pentru codul astfel ales.

În Excel, criteriul AP SR se citește din `CAP_SR`, iar filtrul numeric din `Sheet 5 / RIND_400_COL2`. Limitele 0 și 249 sunt incluse. Celula lipsă se tratează ca 0 numai pentru acest filtru.

Codul din RENIM se folosește exclusiv când codul actualizat lipsește. Un cod actualizat care nu îndeplinește condițiile CAEM2 determină excluderea unității. Încadrarea se face în catalogul CAEM2, după codul complet, cu litera secțiunii.

## 3. Populația și agregarea

**COL1 = numărul CUIIO distincte** ale unităților eligibile care au date raportate în cel puțin unul dintre capitolele selectate:

| Capitol | ID SQL | Foaia Excel |
|---|---|---|
| I | 1124 | Sheet 1 |
| II | 1125 | Sheet 2 |
| III | 1126 | Sheet 4 |
| IV | 1127 | Sheet 5 |
| V | 1128 | Sheet 6 |
| IX | 1214 | Sheet 7 |

Același CUIIO se numără o singură dată în fiecare grupare, chiar dacă apare în mai multe capitole sau rânduri.

**COL2–COL28 = suma valorilor indicatorului corespunzător**, pentru toate unitățile eligibile din gruparea CAEM2 respectivă. Valoarea unei unități se agregă la nivelurile corespunzătoare din catalog: clasă, grupă, diviziune și secțiune.

Totalul general se reconstruiește din secțiunile admise. Nu se adună concomitent secțiunile cu diviziunile, grupele sau clasele lor. Codul intern al totalului este `00000`, iar în tabel se afișează `0`.

## 4. Corespondența completă a coloanelor

Numerele coloanelor din chestionar nu sunt întotdeauna identice cu numerele câmpurilor SQL. Corespondența de mai jos este verificată după SQL-urile care generează fișierul Excel.

| Coloana tabelului | Capitol (ID) | Rând | Col. chestionar | Câmp SQL | Antet Excel | Foaia Excel |
|---|---|---|---|---|---|---|
| COL1 | I, II, III, IV, V, IX | — | — | COUNT(DISTINCT CUIIO) | CUIIO | Sheet 1, 2, 4, 5, 6, 7 |
| COL2 | II (1125) | 300 | 1 | D.COL1 | RIND_300 | Sheet 2 |
| COL3 | II (1125) | 310 | 1 | D.COL1 | RIND_310 | Sheet 2 |
| COL4 | III (1126) | 320 | 1 | D.COL1 | RIND_320_COL1 | Sheet 4 |
| COL5 | III (1126) | 320 | 2 | D.COL2 | RIND_320_COL2 | Sheet 4 |
| COL6 | III (1126) | 330 | 1 | D.COL1 | RIND_330_COL1 | Sheet 4 |
| COL7 | III (1126) | 330 | 2 | D.COL2 | RIND_330_COL2 | Sheet 4 |
| COL8 | III (1126) | 340 | 1 | D.COL1 | RIND_340_COL1 | Sheet 4 |
| COL9 | III (1126) | 340 | 2 | D.COL2 | RIND_340_COL2 | Sheet 4 |
| COL10 | III (1126) | 350 | 1 | D.COL1 | RIND_350_COL1 | Sheet 4 |
| COL11 | III (1126) | 350 | 2 | D.COL2 | RIND_350_COL2 | Sheet 4 |
| COL12 | IV (1127) | 400 | 1 | D.COL3 | RIND_400_COL1 | Sheet 5 |
| COL13 | IV (1127) | 400 | 2 | D.COL4 | RIND_400_COL2 | Sheet 5 |
| COL14 | IV (1127) | 400 | 3 | D.COL5 | RIND_400_COL3 | Sheet 5 |
| COL15 | V (1128) | 500 | 1 | D.COL8 | RIND_500_COL1 | Sheet 6 |
| COL16 | V (1128) | 500 | 2 | D.COL9 | RIND_500_COL2 | Sheet 6 |
| COL17 | V (1128) | 500 | 3 | D.COL10 | RIND_500_COL3 | Sheet 6 |
| COL18 | V (1128) | 510 | 1 | D.COL8 | RIND_510_COL1 | Sheet 6 |
| COL19 | V (1128) | 510 | 2 | D.COL9 | RIND_510_COL2 | Sheet 6 |
| COL20 | V (1128) | 510 | 3 | D.COL10 | RIND_510_COL3 | Sheet 6 |
| COL21 | IX (1214) | 900 | 1 | D.COL1 | RIND_900 | Sheet 7 |
| COL22 | IX (1214) | 910 | 1 | D.COL1 | RIND_910 | Sheet 7 |
| COL23 | IX (1214) | 920 | 1 | D.COL1 | RIND_920 | Sheet 7 |
| COL24 | IX (1214) | 930 | 1 | D.COL1 | RIND_930 | Sheet 7 |
| COL25 | IX (1214) | 940 | 1 | D.COL1 | RIND_940 | Sheet 7 |
| COL26 | IX (1214) | 950 | 1 | D.COL1 | RIND_950 | Sheet 7 |
| COL27 | IX (1214) | 960 | 1 | D.COL1 | RIND_960 | Sheet 7 |
| COL28 | IX (1214) | 970 | 1 | D.COL1 | RIND_970 | Sheet 7 |

Structura este: **1 coloană de numărare + 2 indicatori din CAP II + 8 din CAP III + 3 din CAP IV + 6 din CAP V + 8 din CAP IX = 28 de coloane**.

Pentru **COL20**, referința obligatorie este **R510 COL3**, adică `RIND_510_COL3` în Excel și `D.COL10` în baza de date. Referința `D.COL1` din SQL-ul atașat trebuie aliniată la `D.COL10` în ambele ramuri ale raportului.

## 5. Ordinea rândurilor

Raportul conține două blocuri:

1. **TOTAL PE ACTIVITĂȚI**, urmat de secțiunile CAEM2 admise.
2. **TOTAL PE ACTIVITĂȚI**, urmat de secțiuni, diviziuni, grupe și clase cu unități raportate.

Ordinea urmează ierarhia din catalog (`FULL_CODE`). Ambele blocuri folosesc aceeași selecție a unităților și aceleași formule de calcul.

## 6. Valori lipsă, zero și rotunjire

- Dacă nu există nicio valoare numerică pentru un indicator în gruparea respectivă, rezultatul rămâne gol.
- Zerourile existente în Excel și sumele egale cu zero se păstrează numeric.
- Dacă un antet necesar lipsește efectiv dintr-un fișier viitor, rezultatul rămâne gol și lipsa sursei se semnalează în antet.
- Se utilizează valorile disponibile în Excel, astfel cum au fost produse de SQL-ul de export.
- Rotunjirea se face după însumare: **COL1 — 0 zecimale; COL7 — 1 zecimală; celelalte coloane — 2 zecimale**, conform expresiilor de rotunjire din SQL.
- Se afișează valori numerice fără simboluri speciale în locul celulelor goale sau al zerourilor.

## 7. Observație privind capitolele din SQL-ul atașat

A doua ramură SQL include suplimentar capitolul `2014`. Acesta nu are o sursă în fișierul Excel primit și nu este inclus în numărarea făcută de macroul actual. `Sheet 3` conține capitolul `1200`, deci nu poate fi substituit pentru `2014`. Capitolele disponibile și utilizate pentru COL1 sunt cele enumerate la punctul 3.

## 8. Implementare VBA

Modulul este `ASA_Tab_2_3_2_2025.bas`, procedura de rulare este `Genereaza_Tab_2_3_2_2025`, iar foaia rezultat este `Tab_2_3_2`.

Registrul se salvează în format `.xlsm`. Antetul rezultatului conține referința rândului și coloanei din chestionar, urmată de numerotarea indicatorilor de la 1 la 28.
