# Sarcină tehnică — Tab.19

Tabelul prezintă principalii indicatori ai întreprinderilor pe **total economie, secțiuni CAEM2 și grupe după numărul de salariați**.

## Selectarea întreprinderilor

Se folosesc datele pentru perioada și versiunea formularului selectate.

- **AP SR:** rândul **1 = 1** sau rândul **5 > 0**. Rândul 6 singur nu asigură includerea în acest SQL.
- **CAEM2:** se folosește codul actualizat; dacă acesta lipsește, se utilizează codul din RENIM.
- **Activități admise:** secțiunile **B, C, D, E, F, G, H, I, J, K, L, M, N, P, Q, R, S**, cu excluderea prefixelor **S94, K65** și a codurilor **K6419, K6411**.

Sunt incluse și întreprinderile cu **250 sau mai mulți salariați**. Filtrul teritorial după CUATM este comentat și nu se aplică în SQL-ul actual.

## Formarea celor 11 coloane

Încadrarea se face după **CAP IV, R400, col.2 din chestionar / Excel**, corespunzător câmpului `D.COL4` din SQL.

| Coloana | Grupa după numărul de salariați |
|---|---|
| COL1 | Total |
| COL2 | 0–9, inclusiv fără valoare raportată |
| COL3 | 10–19 |
| COL4 | 20–49 |
| COL5 | Subtotal 0–49, inclusiv fără valoare raportată |
| COL6 | 50–99 |
| COL7 | 100–249 |
| COL8 | Subtotal 50–249 |
| COL9 | Subtotal 250 și peste |
| COL10 | 250–499 |
| COL11 | 500 și peste |

**COL5, COL8 și COL9 sunt subtotaluri**; nu se adună toate cele 11 coloane între ele.

## Formarea indicatorilor pe rânduri

Pentru fiecare grupă de salariați și secțiune CAEM2 se însumează indicatorii întreprinderilor incluse.

| Rândul valorii | Rândul structurii (%) | Indicator | Sursa / calculul |
|---|---|---|---|
| 01 | 02 | Numărul întreprinderilor | Suma marcajelor AP SR din rândurile 1, 5 și 6, pentru întreprinderile selectate |
| 03 | 04 | Numărul mediu de salariați | CAP IV, R400, col.2 din chestionar (D.COL4) |
| 05 | 06 | Venituri din vânzări | CAP I, R150, col.1 |
| 07 | 08 | Valoarea producției | Formula VP |
| 09 | 10 | Valoarea adăugată brută la costul factorilor | Formula VAB |

**VP =** CAP I (R150 + R160 + R170), col.1  
− CAP II R200, col.1  
+ CAP III R330 (col.2 − col.1)  
+ CAP III R340 (col.2 − col.1).

**VAB =** VP  
− CAP II (R220 + R240 + R290), col.1  
+ CAP II R294, col.1  
+ CAP I R180, col.1.

## Structura procentuală

În SQL-ul actual, rândurile **02, 04, 06, 08 și 10** afișează **100 în COL1**, iar **COL2–COL11 rămân goale**. Ponderile pe grupe nu sunt calculate.

Formula pentru completarea lor ar fi:

**Ponderea grupei (%) = valoarea indicatorului în grupă / totalul aceluiași indicator pentru aceeași activitate CAEM2 × 100.**

Referință: [SQL Tab.19 — 2025](../VB/Tab.19_2025.sql).
