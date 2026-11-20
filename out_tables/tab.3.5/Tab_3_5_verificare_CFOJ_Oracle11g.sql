-- Tab.3.5 / ASA 2025 / Oracle 11g
-- Verificare dupa codul CFOJ, cu grupele exact ca in Excel.
-- Indicatorii sunt: primul rand (CNT), R400 C1/C2/C3 si R150 C1.
-- Maparea pastrata din SQL-ul initial:
--   R400 C1 = D.COL3, R400 C2 = D.COL4, R400 C3 = D.COL5.
--   R150 C1 = D.COL1.
-- ATENTIE: grupa de cooperative 540+541+550+560 este subtotal;
-- nu se aduna din nou cu grupele 540, 541, 550 si 560.

WITH
DATE_FIRME AS (
    SELECT
        D.CUIIO,
        TRIM(TO_CHAR(D.CFOJ)) AS CFOJ,
        SUM(
            CASE
                WHEN D.CAPITOL = 1127 AND D.RIND = '400'
                THEN CIS2.NVAL(D.COL3)
            END
        ) AS R400_C1,
        SUM(
            CASE
                WHEN D.CAPITOL = 1127 AND D.RIND = '400'
                THEN CIS2.NVAL(D.COL4)
            END
        ) AS R400_C2,
        SUM(
            CASE
                WHEN D.CAPITOL = 1127 AND D.RIND = '400'
                THEN CIS2.NVAL(D.COL5)
            END
        ) AS R400_C3,
        SUM(
            CASE
                WHEN D.CAPITOL = 1124 AND D.RIND = '150'
                THEN CIS2.NVAL(D.COL1)
            END
        ) AS R150_C1
    FROM CIS2.VW_DATA_ALL D
    INNER JOIN CIS2.RENIM R
        ON R.CUIIO = D.CUIIO
       AND R.CUIIO_VERS = D.CUIIO_VERS
    WHERE D.FORM = 64
      AND D.FORM_VERS = :PFORM_VERS
      AND D.PERIOADA = :pPERIOADA
      AND D.CAPITOL IN (100, 1123, 1124, 1125, 1126, 1127, 1128, 1129)
    GROUP BY
        D.CUIIO,
        TRIM(TO_CHAR(D.CFOJ))
    HAVING
           SUM(
               CASE
                   WHEN D.ID_MD = 62382 AND D.COL1 IS NOT NULL
                   THEN D.COL1 ELSE 0
               END
           ) = 1
        OR SUM(
               CASE
                   WHEN D.ID_MD IN (114171, 62413) AND D.COL1 IS NOT NULL
                   THEN D.COL1 ELSE 0
               END
           ) > 0
),
GRUPE_CFOJ AS (
    SELECT  2 AS ORD, CAST('420' AS VARCHAR2(20)) AS CFOJ_GRUPA,
            CAST('420' AS VARCHAR2(5)) AS CFOJ FROM DUAL
    UNION ALL SELECT  3, '500+510+520', '500' FROM DUAL
    UNION ALL SELECT  3, '500+510+520', '510' FROM DUAL
    UNION ALL SELECT  3, '500+510+520', '520' FROM DUAL
    UNION ALL SELECT  4, '530', '530' FROM DUAL
    UNION ALL SELECT  5, '540+541+550+560', '540' FROM DUAL
    UNION ALL SELECT  5, '540+541+550+560', '541' FROM DUAL
    UNION ALL SELECT  5, '540+541+550+560', '550' FROM DUAL
    UNION ALL SELECT  5, '540+541+550+560', '560' FROM DUAL
    UNION ALL SELECT  6, '540', '540' FROM DUAL
    UNION ALL SELECT  7, '541', '541' FROM DUAL
    UNION ALL SELECT  8, '550', '550' FROM DUAL
    UNION ALL SELECT  9, '560', '560' FROM DUAL
    UNION ALL SELECT 10, '590', '590' FROM DUAL
    UNION ALL SELECT 11, '620', '620' FROM DUAL
    UNION ALL SELECT 12, '690', '690' FROM DUAL
    UNION ALL SELECT 13, '871', '871' FROM DUAL
    UNION ALL SELECT 14, '880', '880' FROM DUAL
    UNION ALL SELECT 15, '993', '993' FROM DUAL
    UNION ALL SELECT 16, '996', '996' FROM DUAL
),
DATE_GRUPATE AS (
    -- Totalul cuprinde toate codurile CFOJ, inclusiv alte coduri.
    SELECT
        1 AS ORD,
        CAST('TOTAL' AS VARCHAR2(20)) AS CFOJ_GRUPA,
        F.CUIIO, F.R400_C1, F.R400_C2, F.R400_C3, F.R150_C1
    FROM DATE_FIRME F

    UNION ALL

    -- Grupele CFOJ din coloanele D:R ale fisierului Excel.
    SELECT
        G.ORD,
        G.CFOJ_GRUPA,
        F.CUIIO, F.R400_C1, F.R400_C2, F.R400_C3, F.R150_C1
    FROM GRUPE_CFOJ G
    LEFT JOIN DATE_FIRME F
        ON G.CFOJ = F.CFOJ
)
SELECT
    T.CFOJ_GRUPA,
    COUNT(DISTINCT T.CUIIO) AS CNT,
    SUM(T.R400_C1) AS R400_C1,
    SUM(T.R400_C2) AS R400_C2,
    SUM(T.R400_C3) AS R400_C3,
    SUM(T.R150_C1) AS R150_C1
FROM DATE_GRUPATE T
GROUP BY T.ORD, T.CFOJ_GRUPA
ORDER BY T.ORD;
