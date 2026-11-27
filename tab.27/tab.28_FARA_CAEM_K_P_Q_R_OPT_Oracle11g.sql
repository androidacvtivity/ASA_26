-- Tab.28 (*) - Oracle 11g - optimizat, fara CAEM2 actualizat K, P, Q, R.
-- Sursa de comparatie: tab.27/tab.28_FARA_CAEM_K_P_Q_R.sql
--
-- Optimizari:
--   1) VW_DATA_ALL_COEF si agregarea pe intreprindere sunt scrise o singura data.
--   2) CAEM2 actualizat: ID_MD=61832/COL31; fallback RENIM.CAEM2.
--   3) Excluderea K/P/Q/R preceda ambele clasamente Top 5.
--   4) Ambele ROW_NUMBER folosesc aceeasi baza; TOPURI este reutilizat.
--   5) UNION ALL inlocuieste UNION (sectiunile 1 si 2 sunt disjuncte).
--   6) O singura sectiune CAEM2 per cod, fara join-ul multiplicator la CC.
-- Nota: departajarea la egalitate se face determinist prin CUIIO si versiune.
-- Verificati prin comparatie cu raportul original: eliminarea multiplicarilor
-- din clasificator poate corecta rezultate Top 5 care erau duplicate.
-- A nu se rula impreuna cu celelalte variante pentru acelasi ID_MDTABLE.

INSERT INTO CIS2.TABLE_OUT
(
    PERIOADA, FORM, FORM_VERS, ID_MDTABLE, COD_CUATM,
    NR_SECTIE, NUME_SECTIE,
    NR_SECTIE1, NUME_SECTIE1,
    NR_SECTIE2, NUME_SECTIE2,
    NR_ROW, ORDINE, DECIMAL_POS, NUME_ROW,
    COL1, COL2
)
WITH
RENIM_ULTIMA AS
(
    SELECT R.CUIIO, MAX(R.CUIIO_VERS) AS CUIIO_VERS
    FROM CIS2.RENIM R
    WHERE R.CUIIO_VERS <= :pPERIOADA
    GROUP BY R.CUIIO
),
BAZA AS
(
    SELECT
        D.CUIIO,
        D.CUIIO_VERS,
        D.CUATM_FULL,
        D.PERIOADA,
        R.DENUMIRE AS NUME_ROW,
        NVL(
            MAX(CASE WHEN D.ID_MD = 61832 THEN D.COL31 END),
            MAX(SUBSTR(R.CAEM2, 2, 4))
        ) AS CAEM_FINAL,
        CIS2.NVAL(
            SUM(
                CASE WHEN D.CAPITOL = 1124 AND D.RIND = '150'
                     THEN CIS2.NVAL(D.COL1) END
            )
        ) AS VENITURI
    FROM CIS2.VW_DATA_ALL_COEF D
    INNER JOIN RENIM_ULTIMA RU
        ON RU.CUIIO = D.CUIIO
    INNER JOIN CIS2.RENIM R
        ON R.CUIIO = RU.CUIIO
       AND R.CUIIO_VERS = RU.CUIIO_VERS
    WHERE D.FORM = 64
      AND D.FORM = :pFORM
      AND D.FORM_VERS = :pFORM_VERS
      AND D.PERIOADA = :pPERIOADA
      AND D.CUATM_FULL LIKE '%' || :pCOD_CUATM || ';%'
      AND D.CAPITOL IN (100,1124,1127,1129)
      AND :pID_MDTABLE = :pID_MDTABLE
    GROUP BY
        D.CUIIO, D.CUIIO_VERS, D.CUATM_FULL,
        D.PERIOADA, R.DENUMIRE
    HAVING
        (
            SUM(CASE WHEN D.ID_MD = 62382 AND D.COL1 IS NOT NULL
                     THEN D.COL1 ELSE 0 END) = 1
            OR
            SUM(CASE WHEN D.ID_MD IN (114171,62413)
                       AND D.COL1 IS NOT NULL
                     THEN D.COL1 ELSE 0 END) > 0
        )
),
CAEM_PERMISE AS
(
    SELECT /*+ MATERIALIZE */ DISTINCT
        SUBSTR(C.CODUL, 2, 4) AS CAEM4,
        SUBSTR(C.CODUL, 1, 1) AS SECTIUNE
    FROM CIS2.VW_CL_CAEM2 C
    WHERE SUBSTR(C.CODUL, 1, 1) IN
          ('B','C','D','E','F','G','H','I','J','L','M','N','S')
      AND SUBSTR(C.CODUL, 1, 3) <> 'S94'
),
BAZA_FILTRATA AS
(
    SELECT
        B.CUIIO,
        B.CUIIO_VERS,
        B.CUATM_FULL,
        B.NUME_ROW,
        B.CAEM_FINAL,
        B.VENITURI,
        C.SECTIUNE
    FROM BAZA B
    INNER JOIN CAEM_PERMISE C
        ON C.CAEM4 = B.CAEM_FINAL
),
TOPURI AS
(
    SELECT /*+ MATERIALIZE */
        B.*,
        ROW_NUMBER() OVER
        (
            ORDER BY B.VENITURI DESC NULLS LAST,
                     B.CUIIO, B.CUIIO_VERS, B.CUATM_FULL
        ) AS R150_GLOBAL,
        ROW_NUMBER() OVER
        (
            PARTITION BY B.SECTIUNE
            ORDER BY B.VENITURI DESC NULLS LAST,
                     B.CUIIO, B.CUIIO_VERS, B.CUATM_FULL
        ) AS R150_SECTIUNE
    FROM BAZA_FILTRATA B
)
-- Primele 5 intreprinderi din intreaga populatie ramasa.
SELECT
    :pPERIOADA AS PERIOADA,
    :pFORM AS FORM,
    :pFORM_VERS AS FORM_VERS,
    :pID_MDTABLE AS ID_MDTABLE,
    :pCOD_CUATM AS COD_CUATM,
    '0' AS NR_SECTIE,
    '0' AS NUME_SECTIE,
    '1' AS NR_SECTIE1,
    'Total' AS NUME_SECTIE1,
    '0' AS NR_SECTIE2,
    '0' AS NUME_SECTIE2,
    '00000~' || TO_CHAR(T.R150_GLOBAL) AS NR_ROW,
    T.R150_GLOBAL AS ORDINE,
    '01' AS DECIMAL_POS,
    T.NUME_ROW,
    T.CUIIO AS COL1,
    T.VENITURI AS COL2
FROM TOPURI T
WHERE T.R150_GLOBAL <= 5

UNION ALL

-- Primele 5 intreprinderi separat pe fiecare dintre cele 13 sectiuni CAEM2.
SELECT
    :pPERIOADA AS PERIOADA,
    :pFORM AS FORM,
    :pFORM_VERS AS FORM_VERS,
    :pID_MDTABLE AS ID_MDTABLE,
    :pCOD_CUATM AS COD_CUATM,
    '0' AS NR_SECTIE,
    '0' AS NUME_SECTIE,
    '2' AS NR_SECTIE1,
    'Pe CAEM2' AS NUME_SECTIE1,
    '0' AS NR_SECTIE2,
    '0' AS NUME_SECTIE2,
    T.SECTIUNE || T.CAEM_FINAL || '~' || TO_CHAR(T.CUIIO) AS NR_ROW,
    ROW_NUMBER() OVER
    (
        ORDER BY T.SECTIUNE, T.R150_SECTIUNE,
                 T.CUIIO, T.CUIIO_VERS
    ) AS ORDINE,
    '01' AS DECIMAL_POS,
    T.NUME_ROW,
    T.CUIIO AS COL1,
    T.VENITURI AS COL2
FROM TOPURI T
WHERE T.R150_SECTIUNE <= 5
