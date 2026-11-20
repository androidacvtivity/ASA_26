-- TAB.1 - Oracle 11g - SELECT pentru CIS2.TABLE_OUT (fara INSERT).
-- Structura conform Tab.1_0000000_2024-Anul.xlsx: 5 sectii de salariati,
-- 44 indicatori/sectie, 6 coloane: Total + grupe CFP.
-- Sursa de baza si HAVING: tab.1_2014.sql.
-- Sursa claselor CFP, grupelor de salariati si formulei VAFC: tab.1_OLD.sql.
-- CFP: COL2=11/12/13; COL3=14..19; COL4=20/21; COL5=22..27; COL6=28.
-- PERS NULL este considerat 0 si intra in 01, 02, 03 si 05; nu in 04.
-- S-a eliminat filtrul de test D.CUIIO = 34275.

WITH SALARIATI AS (
    SELECT
        DD.CUIIO,
        DD.FORM,
        DD.PERIOADA,
        MAX(CIS2.NVAL(DD.COL4)) AS PERS
    FROM CIS2.DATA_ALL DD
    WHERE DD.ID_MD = 69986
      AND DD.FORM = :pFORM
      AND DD.PERIOADA = :pPERIOADA
    GROUP BY DD.CUIIO, DD.FORM, DD.PERIOADA
),
PRIM AS (
    SELECT
        D.CUIIO,
        TRIM(TO_CHAR(D.CFP)) AS CFP,
        MAX(NVL(S.PERS, 0)) AS PERS,
        SUM(CASE WHEN D.CAPITOL = 100 AND D.RIND = 'CD'
                 THEN D.COL1 ELSE 0 END) AS CD,

        -- CAPITOL 1124, COL1
        SUM(CASE WHEN D.CAPITOL = 1124 AND D.RIND = '100' THEN CIS2.NVAL(D.COL1) END) AS R100_C1,
        SUM(CASE WHEN D.CAPITOL = 1124 AND D.RIND = '110' THEN CIS2.NVAL(D.COL1) END) AS R110_C1,
        SUM(CASE WHEN D.CAPITOL = 1124 AND D.RIND = '111' THEN CIS2.NVAL(D.COL1) END) AS R111_C1,
        SUM(CASE WHEN D.CAPITOL = 1124 AND D.RIND = '112' THEN CIS2.NVAL(D.COL1) END) AS R112_C1,
        SUM(CASE WHEN D.CAPITOL = 1124 AND D.RIND = '120' THEN CIS2.NVAL(D.COL1) END) AS R120_C1,
        SUM(CASE WHEN D.CAPITOL = 1124 AND D.RIND = '121' THEN CIS2.NVAL(D.COL1) END) AS R121_C1,
        SUM(CASE WHEN D.CAPITOL = 1124 AND D.RIND = '122' THEN CIS2.NVAL(D.COL1) END) AS R122_C1,
        SUM(CASE WHEN D.CAPITOL = 1124 AND D.RIND = '130' THEN CIS2.NVAL(D.COL1) END) AS R130_C1,
        SUM(CASE WHEN D.CAPITOL = 1124 AND D.RIND = '140' THEN CIS2.NVAL(D.COL1) END) AS R140_C1,
        SUM(CASE WHEN D.CAPITOL = 1124 AND D.RIND = '150' THEN CIS2.NVAL(D.COL1) END) AS R150_C1,
        SUM(CASE WHEN D.CAPITOL = 1124 AND D.RIND = '151' THEN CIS2.NVAL(D.COL1) END) AS R151_C1,
        SUM(CASE WHEN D.CAPITOL = 1124 AND D.RIND = '160' THEN CIS2.NVAL(D.COL1) END) AS R160_C1,
        SUM(CASE WHEN D.CAPITOL = 1124 AND D.RIND = '170' THEN CIS2.NVAL(D.COL1) END) AS R170_C1,
        SUM(CASE WHEN D.CAPITOL = 1124 AND D.RIND = '180' THEN CIS2.NVAL(D.COL1) END) AS R180_C1,

        -- CAPITOL 1125, randuri necesare pentru VP si VAFC
        SUM(CASE WHEN D.CAPITOL = 1125 AND D.RIND = '200' THEN CIS2.NVAL(D.COL1) END) AS R200_C1,
        SUM(CASE WHEN D.CAPITOL = 1125 AND D.RIND = '220' THEN CIS2.NVAL(D.COL1) END) AS R220_C1,
        SUM(CASE WHEN D.CAPITOL = 1125 AND D.RIND = '240' THEN CIS2.NVAL(D.COL1) END) AS R240_C1,
        SUM(CASE WHEN D.CAPITOL = 1125 AND D.RIND = '290' THEN CIS2.NVAL(D.COL1) END) AS R290_C1,
        SUM(CASE WHEN D.CAPITOL = 1125 AND D.RIND = '294' THEN CIS2.NVAL(D.COL1) END) AS R294_C1,

        -- CAPITOL 1126, variatia stocurilor (COL2 - COL1)
        SUM(CASE WHEN D.CAPITOL = 1126 AND D.RIND = '330' THEN CIS2.NVAL(D.COL1) END) AS R330_C1,
        SUM(CASE WHEN D.CAPITOL = 1126 AND D.RIND = '330' THEN CIS2.NVAL(D.COL2) END) AS R330_C2,
        SUM(CASE WHEN D.CAPITOL = 1126 AND D.RIND = '340' THEN CIS2.NVAL(D.COL1) END) AS R340_C1,
        SUM(CASE WHEN D.CAPITOL = 1126 AND D.RIND = '340' THEN CIS2.NVAL(D.COL2) END) AS R340_C2,

        -- CAPITOL 1128: in tabelul de iesire se numesc Col.1/2/3,
        -- dar in raportul primar provin din D.COL8/9/10.
        SUM(CASE WHEN D.CAPITOL = 1128 AND D.RIND = '500' THEN CIS2.NVAL(D.COL8) END) AS R500_C1,
        SUM(CASE WHEN D.CAPITOL = 1128 AND D.RIND = '500' THEN CIS2.NVAL(D.COL9) END) AS R500_C2,
        SUM(CASE WHEN D.CAPITOL = 1128 AND D.RIND = '500' THEN CIS2.NVAL(D.COL10) END) AS R500_C3,
        SUM(CASE WHEN D.CAPITOL = 1128 AND D.RIND = '510' THEN CIS2.NVAL(D.COL8) END) AS R510_C1,
        SUM(CASE WHEN D.CAPITOL = 1128 AND D.RIND = '510' THEN CIS2.NVAL(D.COL9) END) AS R510_C2,
        SUM(CASE WHEN D.CAPITOL = 1128 AND D.RIND = '510' THEN CIS2.NVAL(D.COL10) END) AS R510_C3

    FROM CIS2.VW_DATA_ALL D
    INNER JOIN CIS2.RENIM R
        ON R.CUIIO = D.CUIIO
       AND R.CUIIO_VERS = D.CUIIO_VERS
    LEFT JOIN SALARIATI S
        ON S.CUIIO = D.CUIIO
       AND S.FORM = D.FORM
       AND S.PERIOADA = D.PERIOADA
    WHERE D.FORM IN (:pFORM)
      AND D.FORM_VERS = :pFORM_VERS
      AND D.PERIOADA = :pPERIOADA
      AND D.CAPITOL IN (100, 1123, 1124, 1125, 1126, 1127, 1128, 1129)
    GROUP BY D.CUIIO, D.CFP, D.CFOJ
    HAVING (
           SUM(CASE WHEN D.ID_MD = 62382 AND D.COL1 IS NOT NULL
                    THEN D.COL1 ELSE 0 END) = 1
        OR SUM(CASE WHEN D.ID_MD IN (114171, 62413) AND D.COL1 IS NOT NULL
                    THEN D.COL1 ELSE 0 END) > 0
    )
),
CALC_VP AS (
    SELECT P.*,
           -- VP = 150 + 160 + 170 - 200 + (330 C2-C1) + (340 C2-C1)
           NVL(P.R150_C1, 0) + NVL(P.R160_C1, 0) + NVL(P.R170_C1, 0)
           - NVL(P.R200_C1, 0)
           + NVL(P.R330_C2, 0) - NVL(P.R330_C1, 0)
           + NVL(P.R340_C2, 0) - NVL(P.R340_C1, 0) AS R600
    FROM PRIM P
),
CALC AS (
    SELECT P.*,
           -- VAFC: formula din tab.1_OLD.sql, cu VP integral.
           -- In tab.1_2014.sql lipsea VP din calculul R_700.
           P.R600
           - NVL(P.R220_C1, 0) - NVL(P.R240_C1, 0)
           - NVL(P.R290_C1, 0) + NVL(P.R294_C1, 0)
           + NVL(P.R180_C1, 0) AS R700
    FROM CALC_VP P
),
SECTII AS (
    SELECT '01' AS NR_SECTIE, 'Întreprinderile cu numărul de salariaţi 0-9 persoane' AS NUME_SECTIE, 0 AS PERS_FROM, 9 AS PERS_TO FROM DUAL
    UNION ALL SELECT '02', 'Întreprinderile cu numărul de salariaţi 0-49 persoane', 0, 49 FROM DUAL
    UNION ALL SELECT '03', 'Întreprinderile cu numărul de salariaţi 0-249 persoane', 0, 249 FROM DUAL
    UNION ALL SELECT '04', 'Întreprinderile cu numărul de salariaţi 250 şi mai mult persoane', 250, 99999999 FROM DUAL
    UNION ALL SELECT '05', 'Total republica Moldova', 0, 99999999 FROM DUAL
),
INDICATORI AS (
    -- ORD stabileste ordinea exacta a randurilor din cele 5 foi Excel.
    -- Pentru capitolul 1124, Col.2 si Col.3 sunt goale in Excel.
    SELECT  1 AS ORD, '600' AS COD, '1' AS NR_COL, 'Valoarea producţiei: VP' AS NUME_ROW FROM DUAL
    UNION ALL SELECT  2, '700', '1', 'Valoarea adăugată brută la costul factorilor: VAFC' FROM DUAL
    UNION ALL SELECT  3, '100', '1', 'Venituri din vânzarea produselor' FROM DUAL
    UNION ALL SELECT  4, '100', '2', 'Venituri din vânzarea produselor' FROM DUAL
    UNION ALL SELECT  5, '100', '3', 'Venituri din vânzarea produselor' FROM DUAL
    UNION ALL SELECT  6, '110', '1', 'Venituri din vânzarea mărfurilor' FROM DUAL
    UNION ALL SELECT  7, '110', '2', 'Venituri din vânzarea mărfurilor' FROM DUAL
    UNION ALL SELECT  8, '110', '3', 'Venituri din vânzarea mărfurilor' FROM DUAL
    UNION ALL SELECT  9, '111', '1', 'inclusiv: cu amănuntul' FROM DUAL
    UNION ALL SELECT 10, '111', '2', 'inclusiv: cu amănuntul' FROM DUAL
    UNION ALL SELECT 11, '111', '3', 'inclusiv: cu amănuntul' FROM DUAL
    UNION ALL SELECT 12, '112', '1', 'cu ridicata' FROM DUAL
    UNION ALL SELECT 13, '112', '2', 'cu ridicata' FROM DUAL
    UNION ALL SELECT 14, '112', '3', 'cu ridicata' FROM DUAL
    UNION ALL SELECT 15, '121', '1', 'inclusiv: prestate întreprinderilor' FROM DUAL
    UNION ALL SELECT 16, '121', '2', 'inclusiv: prestate întreprinderilor' FROM DUAL
    UNION ALL SELECT 17, '121', '3', 'inclusiv: prestate întreprinderilor' FROM DUAL
    UNION ALL SELECT 18, '122', '1', 'prestate populaţiei' FROM DUAL
    UNION ALL SELECT 19, '122', '2', 'prestate populaţiei' FROM DUAL
    UNION ALL SELECT 20, '122', '3', 'prestate populaţiei' FROM DUAL
    UNION ALL SELECT 21, '130', '1', 'Venituri din contracte de construcţii' FROM DUAL
    UNION ALL SELECT 22, '130', '2', 'Venituri din contracte de construcţii' FROM DUAL
    UNION ALL SELECT 23, '130', '3', 'Venituri din contracte de construcţii' FROM DUAL
    UNION ALL SELECT 24, '140', '1', 'Venituri din contracte de leasing operaţional şi financiar (arendă, locaţiune)' FROM DUAL
    UNION ALL SELECT 25, '140', '2', 'Venituri din contracte de leasing operaţional şi financiar (arendă, locaţiune)' FROM DUAL
    UNION ALL SELECT 26, '140', '3', 'Venituri din contracte de leasing operaţional şi financiar (arendă, locaţiune)' FROM DUAL
    UNION ALL SELECT 27, '150', '1', 'Cifra de afaceri (venitul din vânzări), fără TVA şi accize – total (rd.100+110+120+130+140)' FROM DUAL
    UNION ALL SELECT 28, '150', '2', 'Cifra de afaceri (venitul din vânzări), fără TVA şi accize – total (rd.100+110+120+130+140)' FROM DUAL
    UNION ALL SELECT 29, '150', '3', 'Cifra de afaceri (venitul din vânzări), fără TVA şi accize – total (rd.100+110+120+130+140)' FROM DUAL
    UNION ALL SELECT 30, '151', '1', 'din rd. 150: Venituri din vânzarea apartamentelor noi şi caselor particulare noi populaţiei' FROM DUAL
    UNION ALL SELECT 31, '151', '2', 'din rd. 150: Venituri din vânzarea apartamentelor noi şi caselor particulare noi populaţiei' FROM DUAL
    UNION ALL SELECT 32, '151', '3', 'din rd. 150: Venituri din vânzarea apartamentelor noi şi caselor particulare noi populaţiei' FROM DUAL
    UNION ALL SELECT 33, '160', '1', 'Alte venituri din activitatea operaţională' FROM DUAL
    UNION ALL SELECT 34, '160', '2', 'Alte venituri din activitatea operaţională' FROM DUAL
    UNION ALL SELECT 35, '160', '3', 'Alte venituri din activitatea operaţională' FROM DUAL
    UNION ALL SELECT 36, '180', '1', 'Subvenţii - total' FROM DUAL
    UNION ALL SELECT 37, '180', '2', 'Subvenţii - total' FROM DUAL
    UNION ALL SELECT 38, '180', '3', 'Subvenţii - total' FROM DUAL
    UNION ALL SELECT 39, '500', '1', 'TOTAL' FROM DUAL
    UNION ALL SELECT 40, '500', '2', 'TOTAL' FROM DUAL
    UNION ALL SELECT 41, '500', '3', 'TOTAL' FROM DUAL
    UNION ALL SELECT 42, '510', '1', 'Sediul Central' FROM DUAL
    UNION ALL SELECT 43, '510', '2', 'Sediul Central' FROM DUAL
    UNION ALL SELECT 44, '510', '3', 'Sediul Central' FROM DUAL
),
DATE_PE_RANDURI AS (
    SELECT
        S.NR_SECTIE,
        S.NUME_SECTIE,
        I.ORD,
        I.COD,
        I.NR_COL,
        I.NUME_ROW,
        D.CFP,
        CASE I.COD || '.' || I.NR_COL
            WHEN '600.1' THEN D.R600
            WHEN '700.1' THEN D.R700
            WHEN '100.1' THEN D.R100_C1
            WHEN '110.1' THEN D.R110_C1
            WHEN '111.1' THEN D.R111_C1
            WHEN '112.1' THEN D.R112_C1
            WHEN '121.1' THEN D.R121_C1
            WHEN '122.1' THEN D.R122_C1
            WHEN '130.1' THEN D.R130_C1
            WHEN '140.1' THEN D.R140_C1
            WHEN '150.1' THEN D.R150_C1
            WHEN '151.1' THEN D.R151_C1
            WHEN '160.1' THEN D.R160_C1
            WHEN '180.1' THEN D.R180_C1
            WHEN '500.1' THEN D.R500_C1
            WHEN '500.2' THEN D.R500_C2
            WHEN '500.3' THEN D.R500_C3
            WHEN '510.1' THEN D.R510_C1
            WHEN '510.2' THEN D.R510_C2
            WHEN '510.3' THEN D.R510_C3
            ELSE NULL -- Col.2/3 la randurile din 1124 raman goale.
        END AS VALOARE
    FROM SECTII S
    CROSS JOIN INDICATORI I
    LEFT JOIN CALC D
        ON D.PERS BETWEEN S.PERS_FROM AND S.PERS_TO
)
SELECT
    :pPERIOADA AS PERIOADA,
    :pFORM AS FORM,
    :pFORM_VERS AS FORM_VERS,
    :pID_MDTABLE AS ID_MDTABLE,
    :pCOD_CUATM AS COD_CUATM,
    X.NR_SECTIE AS NR_SECTIE,
    X.NUME_SECTIE AS NUME_SECTIE,
    '0' AS NR_SECTIE1,
    '0' AS NUME_SECTIE1,
    '0' AS NR_SECTIE2,
    '0' AS NUME_SECTIE2,
    CASE WHEN X.COD IN ('600','700')
         THEN X.COD || '.' || X.NR_SECTIE
         ELSE X.COD || ', Col.' || X.NR_COL END AS NR_ROW,
    TO_NUMBER(X.NR_SECTIE) * 1000 + X.ORD AS ORDINE,
    CASE WHEN X.COD IN ('600','700') THEN '100000'
         ELSE '000000' END AS DECIMAL_POS,
    X.NUME_ROW AS NUME_ROW,

    CASE WHEN X.COD IN ('600','700') THEN ROUND(SUM(X.VALOARE), 1)
         ELSE ROUND(SUM(X.VALOARE), 0) END AS COL1, -- TOTAL, TOATE CFP
    ROUND(SUM(CASE WHEN X.CFP IN ('11','12','13') THEN X.VALOARE END), 0) AS COL2, -- proprietate publica
    ROUND(SUM(CASE WHEN X.CFP IN ('14','15','16','17','18','19') THEN X.VALOARE END), 0) AS COL3, -- privata
    ROUND(SUM(CASE WHEN X.CFP IN ('20','21') THEN X.VALOARE END), 0) AS COL4, -- mixta publica+privata
    ROUND(SUM(CASE WHEN X.CFP IN ('22','23','24','25','26','27') THEN X.VALOARE END), 0) AS COL5, -- straina
    ROUND(SUM(CASE WHEN X.CFP = '28' THEN X.VALOARE END), 0) AS COL6  -- mixta RM+straina

FROM DATE_PE_RANDURI X
GROUP BY X.NR_SECTIE, X.NUME_SECTIE, X.ORD, X.COD, X.NR_COL, X.NUME_ROW
ORDER BY ORDINE;
