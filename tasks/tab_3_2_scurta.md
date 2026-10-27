# Sarcină tehnică — Tab.2.3.2

Pentru **Tab.2.3.2**, unitatea trebuie să îndeplinească **3 condiții simultan**:

1. **AP SR:** rândul **1, 5 sau 6**.
2. **CAP IV, R400, COL2:** valoarea este între **0 și 249 inclusiv**; lipsa valorii se consideră **0**.
3. **CAEM2:** secțiunile **B, C, D, E, F, G, H, I, J, K, L, M, N, P, Q, R, S**, cu excluderea codurilor care încep cu **S94** sau **K65**, precum și a codurilor **K6419** și **K6411**. Se folosește **codul CAEM2 actualizat**; dacă acesta lipsește, se utilizează **codul CAEM2 din RENIM**. Condiția se verifică pentru codul astfel ales.

**Formarea celor 28 de coloane:**

**COL1** reprezintă numărul unităților eligibile distincte după **CUIIO**, cu date raportate în capitolele **I, II, III, IV, V sau IX**. Același CUIIO se numără o singură dată în fiecare grupare CAEM2.

Pentru **COL2–COL28**, se însumează valorile din capitolul, rândul și coloana din chestionar / Excel indicate mai jos, numai pentru unitățile eligibile.

| Coloana tabelului | Capitol | Rând | Coloana din chestionar / Excel |
|---|---|---|---|
| **COL1** | Capitolele selectate | — | Numărul CUIIO distincte |
| **COL2** | II | 300 | 1 |
| **COL3** | II | 310 | 1 |
| **COL4** | III | 320 | 1 |
| **COL5** | III | 320 | 2 |
| **COL6** | III | 330 | 1 |
| **COL7** | III | 330 | 2 |
| **COL8** | III | 340 | 1 |
| **COL9** | III | 340 | 2 |
| **COL10** | III | 350 | 1 |
| **COL11** | III | 350 | 2 |
| **COL12** | IV | 400 | 1 |
| **COL13** | IV | 400 | 2 |
| **COL14** | IV | 400 | 3 |
| **COL15** | V | 500 | 1 |
| **COL16** | V | 500 | 2 |
| **COL17** | V | 500 | 3 |
| **COL18** | V | 510 | 1 |
| **COL19** | V | 510 | 2 |
| **COL20** | V | 510 | 3 |
| **COL21** | IX | 900 | 1 |
| **COL22** | IX | 910 | 1 |
| **COL23** | IX | 920 | 1 |
| **COL24** | IX | 930 | 1 |
| **COL25** | IX | 940 | 1 |
| **COL26** | IX | 950 | 1 |
| **COL27** | IX | 960 | 1 |
| **COL28** | IX | 970 | 1 |

Rezultatele se calculează pe **clase, grupe, diviziuni și secțiuni CAEM2**. Totalul general reprezintă suma secțiunilor admise, fără dublarea unităților.

**Valorile lipsă rămân goale, iar zerourile existente în Excel se păstrează.**

**Precizare pentru implementare:** în capitolul IV, coloanele 1–3 din chestionar corespund câmpurilor SQL `D.COL3–D.COL5`; în capitolul V, coloanele 1–3 corespund câmpurilor `D.COL8–D.COL10`. Prin urmare, **COL20 = R510 COL3 = D.COL10**.
