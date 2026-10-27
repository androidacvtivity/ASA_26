# Sarcină tehnică — Tab.3.1

Pentru **Tab.3.1**, unitatea trebuie să îndeplinească **3 condiții simultan**:

1. **AP SR:** rândul **1, 5 sau 6**.

2. **CAP IV, R400, COL2:** valoarea este între **0 și 249 inclusiv**; lipsa valorii se consideră **0**.

3. **CAEM2:** secțiunile **B, C, D, E, F, G, H, I, J, K, L, M, N, P, Q, R, S**, cu excluderea codurilor care încep cu **S94** sau **K65**, precum și a codurilor **K6419** și **K6411**. Se folosește **codul CAEM2 actualizat**; dacă acesta lipsește, se utilizează **codul CAEM2 din RENIM**. Condiția se verifică pentru codul astfel ales.

**Formarea celor 39 de coloane:**

**COL1** reprezintă numărul unităților eligibile distincte după **CUIIO**, cu date raportate în capitolul I sau II. Același CUIIO se numără o singură dată în fiecare grupare CAEM2.

Pentru **COL2–COL39**, se însumează valorile din **coloana 1** a fiecărui indicator indicat mai jos, numai pentru unitățile eligibile.

| Coloana tabelului | Capitolul sursă | Rândul indicatorului |
|---|---|---|
| **COL1** | I și II | Numărul CUIIO distincte |
| **COL2** | I | 100 |
| **COL3** | I | 110 |
| **COL4** | I | 111 |
| **COL5** | I | 112 |
| **COL6** | I | 120 |
| **COL7** | I | 121 |
| **COL8** | I | 122 |
| **COL9** | I | 130 |
| **COL10** | I | 140 |
| **COL11** | I | 150 |
| **COL12** | I | 151 |
| **COL13** | I | 160 |
| **COL14** | I | 170 |
| **COL15** | I | 180 |
| **COL16** | II | 200 |
| **COL17** | II | 210 |
| **COL18** | II | 220 |
| **COL19** | II | 221 |
| **COL20** | II | 222 |
| **COL21** | II | 240 |
| **COL22** | II | 241 |
| **COL23** | II | 242 |
| **COL24** | II | 243 |
| **COL25** | II | 260 |
| **COL26** | II | 270 |
| **COL27** | II | 280 |
| **COL28** | II | 290 |
| **COL29** | II | 2911 |
| **COL30** | II | 2912 |
| **COL31** | II | 292 |
| **COL32** | II | 293 |
| **COL33** | II | 2931 |
| **COL34** | II | 291 |
| **COL35** | II | 295 |
| **COL36** | II | 296 |
| **COL37** | II | 2961 |
| **COL38** | II | 2962 |
| **COL39** | II | 297 |

Rezultatele se calculează pe **clase, grupe, diviziuni și secțiuni CAEM2**. Totalul general reprezintă suma secțiunilor admise, fără dublarea unităților.

**Valorile lipsă rămân goale, iar zerourile raportate se păstrează.**
