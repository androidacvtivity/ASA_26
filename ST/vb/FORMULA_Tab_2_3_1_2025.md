# Sarcină tehnică — Tab.3.1 (ASA 2025)

Tabelul prezintă numărul unităților statistice și suma indicatorilor raportați, grupate după activitatea economică CAEM2. Structura conține **39 de coloane de indicatori: COL1–COL39**, conform ultimei versiuni `tab_3.1.sql`.

## 1. Condiții de includere

O unitate statistică este inclusă numai dacă îndeplinește **simultan toate cele trei condiții** de mai jos.

### Condiția 1 — AP SR

Unitatea este încadrată în anexa **AP SR la rândul 1, 5 sau 6**.

În fișierul de date, această condiție este reprezentată prin `CAP_SR IN ('1', '5', '6')`.

### Condiția 2 — Capitolul IV, rândul 400, coloana 2

Valoarea din **capitolul IV, rândul 400, coloana 2** trebuie să fie **între 0 și 249 inclusiv**:

**0 ≤ CAP IV R400 COL2 ≤ 249.**

Pentru această condiție de selecție, o celulă fără valoare este interpretată ca **0**, conform regulii stabilite. Această excepție se referă la filtrul R400 COL2; indicatorii lipsă din tabel rămân fără valoare.

### Condiția 3 — Activitatea CAEM2 admisă

Mai întâi se stabilește codul CAEM2 utilizat la clasificare:

1. Dacă există un **cod CAEM2 actualizat**, se folosește acest cod.
2. Dacă acel cod **lipsește**, se folosește codul CAEM2 al unității din **RENIM**.
3. Codul ales se identifică în catalogul CAEM2, în forma completă, cu litera secțiunii, apoi se verifică după regulile de mai jos.

| Verificare | Regula |
|---|---|
| Secțiuni admise — prima literă a codului | B, C, D, E, F, G, H, I, J, K, L, M, N, P, Q, R, S |
| Prefixe excluse — primele trei caractere | S94, K65 |
| Coduri complete excluse | K6419, K6411 |

**Codul din RENIM se folosește numai când codul actualizat lipsește.** Dacă un cod actualizat există, dar nu îndeplinește condițiile CAEM2, unitatea este exclusă.

## 2. Calculul indicatorilor

Calculul se efectuează pentru unitățile eligibile, pe baza datelor raportate în **capitolele I și II**, pentru perioada de referință.

- **COL1** reprezintă numărul unităților statistice distincte după **CUIIO**, cu date raportate în capitolul I sau II. Același CUIIO se numără o singură dată în fiecare grupare CAEM2, inclusiv când apare în ambele capitole.
- Pentru **COL2–COL39**, se însumează valorile din **coloana 1** a rândului și capitolului indicate mai jos, numai pentru unitățile eligibile din gruparea CAEM2 respectivă.
- **CAP IV R400 COL2 este criteriu de selecție** și nu reprezintă o coloană de indicatori a tabelului.

## 3. Sursa fiecărei coloane

Pentru COL2–COL39, fiecare poziție de mai jos reprezintă **suma valorilor din coloana sursă indicată**.

| Coloana tabelului | Capitol sursă | Rând sursă | Câmp / coloană sursă |
|---|---|---|---|
| COL1 | I și II (1124 și 1125) | Rânduri raportate | CUIIO — numărat distinct |
| COL2 | I (1124) | 100 | Coloana 1 |
| COL3 | I (1124) | 110 | Coloana 1 |
| COL4 | I (1124) | 111 | Coloana 1 |
| COL5 | I (1124) | 112 | Coloana 1 |
| COL6 | I (1124) | 120 | Coloana 1 |
| COL7 | I (1124) | 121 | Coloana 1 |
| COL8 | I (1124) | 122 | Coloana 1 |
| COL9 | I (1124) | 130 | Coloana 1 |
| COL10 | I (1124) | 140 | Coloana 1 |
| COL11 | I (1124) | 150 | Coloana 1 |
| COL12 | I (1124) | 151 | Coloana 1 |
| COL13 | I (1124) | 160 | Coloana 1 |
| COL14 | I (1124) | 170 | Coloana 1 |
| COL15 | I (1124) | 180 | Coloana 1 |
| COL16 | II (1125) | 200 | Coloana 1 |
| COL17 | II (1125) | 210 | Coloana 1 |
| COL18 | II (1125) | 220 | Coloana 1 |
| COL19 | II (1125) | 221 | Coloana 1 |
| COL20 | II (1125) | 222 | Coloana 1 |
| COL21 | II (1125) | 240 | Coloana 1 |
| COL22 | II (1125) | 241 | Coloana 1 |
| COL23 | II (1125) | 242 | Coloana 1 |
| COL24 | II (1125) | 243 | Coloana 1 |
| COL25 | II (1125) | 260 | Coloana 1 |
| COL26 | II (1125) | 270 | Coloana 1 |
| COL27 | II (1125) | 280 | Coloana 1 |
| COL28 | II (1125) | 290 | Coloana 1 |
| COL29 | II (1125) | 2911 | Coloana 1 |
| COL30 | II (1125) | 2912 | Coloana 1 |
| COL31 | II (1125) | 292 | Coloana 1 |
| COL32 | II (1125) | 293 | Coloana 1 |
| COL33 | II (1125) | 2931 | Coloana 1 |
| COL34 | II (1125) | 291 | Coloana 1 |
| COL35 | II (1125) | 295 | Coloana 1 |
| COL36 | II (1125) | 296 | Coloana 1 |
| COL37 | II (1125) | 2961 | Coloana 1 |
| COL38 | II (1125) | 2962 | Coloana 1 |
| COL39 | II (1125) | 297 | Coloana 1 |

Structura este formată din **1 coloană de numărare + 14 indicatori din capitolul I + 24 de indicatori din capitolul II = 39 de coloane**. Codul și denumirea activității CAEM2 sunt coloane de identificare, separate de cele 39 de coloane de indicatori.

## 4. Gruparea și prezentarea rândurilor

Fiecare unitate este încadrată după codul CAEM2 stabilit la condiția 3. Valorile sale sunt agregate la nivelurile corespunzătoare din catalog: **clasă, grupă, diviziune și secțiune**.

Tabelul conține două blocuri:

1. **TOTAL PE ACTIVITĂȚI**, urmat de secțiunile CAEM2 admise.
2. **TOTAL PE ACTIVITĂȚI**, urmat de secțiuni, diviziuni, grupe și clase CAEM2 cu unități raportate, în ordinea ierarhiei din catalog (`FULL_CODE`).

Totalul general se calculează ca **suma secțiunilor admise**, astfel încât fiecare unitate să contribuie o singură dată la total. Codul intern al totalului este `00000`, iar în tabel se afișează `0`.

## 5. Valori lipsă și rotunjire

- Dacă nu există nicio valoare numerică raportată pentru un indicator într-o grupare CAEM2, celula rezultatului rămâne **goală**.
- Un **zero raportat** sau o **sumă egală cu zero** se păstrează ca valoare numerică și se afișează fără simboluri speciale.
- Dacă lipsește din sursă o coloană necesară, rezultatul ei rămâne gol și lipsa se semnalează în antet.
- Rotunjirea se face **după însumare**: **COL1 la 0 zecimale**, **COL7 la 1 zecimală**, iar celelalte coloane la **2 zecimale**, conform ultimei versiuni SQL.

