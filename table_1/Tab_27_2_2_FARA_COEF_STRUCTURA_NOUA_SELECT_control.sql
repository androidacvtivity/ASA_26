-- TAB.27.2.2 FARA COEF - SELECT CONTROL, FARA INSERT.
-- Aceleasi calcule: TOTAL + CAEM2 pe sectiuni.
WITH
-- 1. O inregistrare agregata per intreprindere/versiune/teritoriu.
-- Numarul de intreprinderi se calculeaza la final cu COUNT(DISTINCT CUIIO).
BAZA AS
(
    SELECT
        D.CUIIO,
        D.CUIIO_VERS,
        D.CUATM,
        D.FORM,
        D.FORM_VERS,
        D.CUATM_FULL,
        D.PERIOADA,
        CASE
            WHEN MAX(CASE WHEN D.ID_MD = 61832 THEN D.COL31 END) IS NULL
            THEN SUBSTR(R.CAEM2, 2, 4)
            ELSE MAX(CASE WHEN D.ID_MD = 61832 THEN D.COL31 END)
        END AS CAEM_FINAL,
        CIS2.NVAL(SUM(
            CASE WHEN D.CAPITOL = 1127 AND D.RIND = '400'
                 THEN CIS2.NVAL(D.COL4) ELSE 0 END
        )) AS VAL_R400,
        CIS2.NVAL(SUM(
            CASE WHEN D.CAPITOL = 1124 AND D.RIND = '150'
                 THEN CIS2.NVAL(D.COL1) END
        )) AS VAL_R150
    FROM CIS2.VW_DATA_ALL D
    INNER JOIN CIS2.RENIM R
        ON R.CUIIO = D.CUIIO
       AND R.CUIIO_VERS = D.CUIIO_VERS
    WHERE D.FORM = 64
      AND D.FORM = :pFORM
      AND D.FORM_VERS = :pFORM_VERS
      AND D.PERIOADA = :pPERIOADA
      AND D.CUATM_FULL LIKE '%' || :pCOD_CUATM || ';%'
      AND D.CAPITOL IN (100, 1123, 1124, 1125, 1126, 1127, 1128, 1129)
    GROUP BY
        D.CUIIO,
        D.CUIIO_VERS,
        D.CUATM,
        D.FORM,
        D.FORM_VERS,
        D.CUATM_FULL,
        D.PERIOADA,
        SUBSTR(R.CAEM2, 2, 4)
    HAVING
        NVAL(SUM(D.COL1)) + NVAL(SUM(D.COL2)) +
        NVAL(SUM(D.COL3)) + NVAL(SUM(D.COL4)) > 0
        AND
        (
            SUM(CASE WHEN D.ID_MD = 62382 AND D.COL1 IS NOT NULL
                     THEN D.COL1 ELSE 0 END) = 1
            OR
            SUM(CASE WHEN D.ID_MD IN (114171, 62413)
                      AND D.COL1 IS NOT NULL
                     THEN D.COL1 ELSE 0 END) > 0
        )
),
-- 2. Rangurile GLOBAL: se aplica intregului esantion eligibil.
TOP_GLOBAL AS
(
    SELECT
        B.*,
        ROW_NUMBER() OVER
        (
            ORDER BY B.VAL_R400 DESC NULLS LAST,
                     B.CUIIO, B.CUIIO_VERS, B.CUATM
        ) AS R400_GLOBAL,
        ROW_NUMBER() OVER
        (
            ORDER BY B.VAL_R150 DESC NULLS LAST,
                     B.CUIIO, B.CUIIO_VERS, B.CUATM
        ) AS R150_GLOBAL
    FROM BAZA B
),
-- 3. Mapare la sectiunea CAEM2, folosind CAEM_FINAL.
-- DISTINCT previne multiplicarea datorata unor inregistrari identice de clasificator.
CLASIFICATOR_SECTIUNI AS
(
    SELECT DISTINCT
        SUBSTR(C.CODUL, 2, 4) AS CAEM4,
        CC.CODUL AS CODUL_SECTIUNE,
        CC.DENUMIRE AS DENUMIRE_SECTIUNE
    FROM CIS2.VW_CL_CAEM2 C
    INNER JOIN CIS2.VW_CL_CAEM2 CC
        ON C.FULL_CODE LIKE '%' || CC.CODUL || ';%'
       AND CC.CODUL = SUBSTR(C.CODUL, 1, 1) || '0000'
    WHERE SUBSTR(C.CODUL, 1, 1) IN
          ('B','C','D','E','F','G','H','I','J','K','L','M','N','P','Q','R','S')
      AND SUBSTR(C.CODUL, 1, 3) NOT IN ('S94', 'K65')
      AND C.CODUL NOT IN ('K6419', 'K6411')
),
BAZA_SECTIUNI AS
(
    SELECT
        G.CUIIO,
        G.CUIIO_VERS,
        G.CUATM,
        G.VAL_R400,
        G.VAL_R150,
        C.CODUL_SECTIUNE,
        C.DENUMIRE_SECTIUNE
    FROM TOP_GLOBAL G
    INNER JOIN CLASIFICATOR_SECTIUNI C
        ON C.CAEM4 = G.CAEM_FINAL
),
-- 4. Ranguri NOI, calculate INDEPENDENT in fiecare sectiune B, C, ... S.
TOP_SECTIUNI AS
(
    SELECT
        S.*,
        ROW_NUMBER() OVER
        (
            PARTITION BY S.CODUL_SECTIUNE
            ORDER BY S.VAL_R400 DESC NULLS LAST,
                     S.CUIIO, S.CUIIO_VERS, S.CUATM
        ) AS R400_SECTIUNE,
        ROW_NUMBER() OVER
        (
            PARTITION BY S.CODUL_SECTIUNE
            ORDER BY S.VAL_R150 DESC NULLS LAST,
                     S.CUIIO, S.CUIIO_VERS, S.CUATM
        ) AS R150_SECTIUNE
    FROM BAZA_SECTIUNI S
),
-- 5. Numere de intreprinderi, totaluri si Top 5/20 PE FIECARE SECTIUNE.
AGREG_SECTIUNI AS
(
    SELECT
        CODUL_SECTIUNE,
        MAX(DENUMIRE_SECTIUNE) AS NUME_ROW,
        CIS2.NVAL(COUNT(DISTINCT CUIIO)) AS COL1,
        CIS2.NVAL(SUM(VAL_R400)) AS COL2,
        CIS2.NVAL(SUM(VAL_R150)) AS COL3,
        CIS2.NVAL(SUM(CASE WHEN R400_SECTIUNE BETWEEN 1 AND 5
                           THEN VAL_R400 END)) AS TOP5_R400,
        CIS2.NVAL(SUM(CASE WHEN R400_SECTIUNE BETWEEN 1 AND 20
                           THEN VAL_R400 END)) AS TOP20_R400,
        CIS2.NVAL(SUM(CASE WHEN R150_SECTIUNE BETWEEN 1 AND 5
                           THEN VAL_R150 END)) AS TOP5_R150,
        CIS2.NVAL(SUM(CASE WHEN R150_SECTIUNE BETWEEN 1 AND 20
                           THEN VAL_R150 END)) AS TOP20_R150
    FROM TOP_SECTIUNI
    GROUP BY CODUL_SECTIUNE
),
-- 6. Numere de intreprinderi, totaluri si Top 5/20 DIN INTREGUL ESANTION.
AGREG_TOTAL AS
(
    SELECT
        CIS2.NVAL(COUNT(DISTINCT CUIIO)) AS COL1,
        CIS2.NVAL(SUM(VAL_R400)) AS COL2,
        CIS2.NVAL(SUM(VAL_R150)) AS COL3,
        CIS2.NVAL(SUM(CASE WHEN R400_GLOBAL BETWEEN 1 AND 5
                           THEN VAL_R400 END)) AS TOP5_R400,
        CIS2.NVAL(SUM(CASE WHEN R400_GLOBAL BETWEEN 1 AND 20
                           THEN VAL_R400 END)) AS TOP20_R400,
        CIS2.NVAL(SUM(CASE WHEN R150_GLOBAL BETWEEN 1 AND 5
                           THEN VAL_R150 END)) AS TOP5_R150,
        CIS2.NVAL(SUM(CASE WHEN R150_GLOBAL BETWEEN 1 AND 20
                           THEN VAL_R150 END)) AS TOP20_R150
    FROM TOP_GLOBAL
),
-- 7. Un singur set de randuri: TOTAL + sectiunile CAEM2.
RANDURI AS
(
    SELECT
        '0' AS NR_ROW,
        '0' AS ORD_SORT,
        'TOTAL PE ACTIVITATI' AS NUME_ROW,
        T.COL1, T.COL2, T.COL3,
        T.TOP5_R400, T.TOP20_R400,
        T.TOP5_R150, T.TOP20_R150
    FROM AGREG_TOTAL T

    UNION ALL

    SELECT
        S.CODUL_SECTIUNE || '~' || TO_CHAR(S.COL1) || '1' AS NR_ROW,
        S.CODUL_SECTIUNE AS ORD_SORT,
        S.NUME_ROW,
        S.COL1, S.COL2, S.COL3,
        S.TOP5_R400, S.TOP20_R400,
        S.TOP5_R150, S.TOP20_R150
    FROM AGREG_SECTIUNI S
)
-- 8. Procentele se calculeaza direct, fara UPDATE ulterior.
SELECT
    :pPERIOADA AS PERIOADA,
    :pFORM AS FORM,
    :pFORM_VERS AS FORM_VERS,
    :pID_MDTABLE AS ID_MDTABLE,
    :pCOD_CUATM AS COD_CUATM,
    '0' AS NR_SECTIE,
    '0' AS NUME_SECTIE,
    '0' AS NR_SECTIE1,
    '0' AS NUME_SECTIE1,
    '0' AS NR_SECTIE2,
    '0' AS NUME_SECTIE2,
    T.NR_ROW,
    ROW_NUMBER() OVER (ORDER BY T.ORD_SORT) AS ORDINE,
    '0001111' AS DECIMAL_POS,
    T.NUME_ROW,
    T.COL1,
    T.COL2,
    T.COL3,
    ROUND(T.TOP5_R400 / NOZERO(T.COL2) * 100, 1) AS COL4,
    ROUND(T.TOP20_R400 / NOZERO(T.COL2) * 100, 1) AS COL5,
    ROUND(T.TOP5_R150 / NOZERO(T.COL3) * 100, 1) AS COL6,
    ROUND(T.TOP20_R150 / NOZERO(T.COL3) * 100, 1) AS COL7
FROM RANDURI T;
