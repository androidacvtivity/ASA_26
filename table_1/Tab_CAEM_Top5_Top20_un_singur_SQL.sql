-- CAEM2 / ASA. Oracle 11g.
-- SQL 1 + calculul procentelor care se facea anterior in SQL 2 (UPDATE).
-- COL1-COL3: totaluri, COL4-COL7: procente rotunjite la o zecimala.
-- IMPORTANT: nu mai executati fostul bloc DECLARE/UPDATE dupa acest SELECT.
-- Momentan este SELECT de verificare, la fel ca SQL-ul original.

-- INSERT INTO CIS2.TABLE_OUT
-- (
--   PERIOADA, FORM, FORM_VERS, ID_MDTABLE, COD_CUATM,
--   NR_SECTIE, NUME_SECTIE, NR_SECTIE1, NUME_SECTIE1,
--   NR_SECTIE2, NUME_SECTIE2, NR_ROW, ORDINE, DECIMAL_POS,
--   NUME_ROW, COL1, COL2, COL3, COL4, COL5, COL6, COL7
-- )

SELECT
    NR_ROW,
    ROWNUM AS ORDINE,
    '0001111' AS DECIMAL_POS,
    NUME_ROW,
    COL1,
    COL2,
    COL3,
    -- Procente calculate direct, identic cu fostul UPDATE:
    ROUND(COL4 / NOZERO(COL2) * 100, 1) AS COL4,
    ROUND(COL5 / NOZERO(COL2) * 100, 1) AS COL5,
    ROUND(COL6 / NOZERO(COL3) * 100, 1) AS COL6,
    ROUND(COL7 / NOZERO(COL3) * 100, 1) AS COL7
FROM (
    SELECT
        CODUL || '~' || COL1 || '1' AS NR_ROW,
        '1' || ORDINE AS ORDINE,
        DENUMIRE AS NUME_ROW,
        COL1, COL2, COL3, COL4, COL5, COL6, COL7
    FROM (
        SELECT
            CC.FULL_CODE,
            CASE WHEN CC.CODUL LIKE '%0000' THEN CC.DENUMIRE END AS DENUMIRE,
            SUBSTR(CC.CODUL, 1, 1) || '0000' AS CODUL,
            CC.FULL_CODE AS ORDINE,
            -- Totaluri: insumare nerotunjita si o singura rotunjire.
            CIS2.NVAL(ROUND(SUM(DD.CD), 1)) AS COL1,
            CIS2.NVAL(ROUND(SUM(DD.COL2), 1)) AS COL2,
            CIS2.NVAL(ROUND(SUM(DD.COL3), 1)) AS COL3,
            -- Sumele topurilor inainte de transformarea lor in procente.
            CIS2.NVAL(SUM(CASE WHEN DD.R400 BETWEEN 1 AND 5
                                THEN DD.COL2 END)) AS COL4,
            CIS2.NVAL(SUM(CASE WHEN DD.R400 BETWEEN 1 AND 20
                                THEN DD.COL2 END)) AS COL5,
            CIS2.NVAL(SUM(CASE WHEN DD.R150 BETWEEN 1 AND 5
                                THEN DD.COL3 END)) AS COL6,
            CIS2.NVAL(SUM(CASE WHEN DD.R150 BETWEEN 1 AND 20
                                THEN DD.COL3 END)) AS COL7
        FROM (
            SELECT DISTINCT
                D.CUIIO,
                D.CUIIO_VERS,
                MAX(SUBSTR(D.CAEM2, 2, 4)) AS CAEM2,
                CASE
                    WHEN MAX(CASE WHEN D.ID_MD = 61832 THEN D.COL31 END) IS NULL
                    THEN SUBSTR(R.CAEM2, 2, 4)
                    ELSE MAX(CASE WHEN D.ID_MD = 61832 THEN D.COL31 END)
                END AS CAEM_FINAL,
                D.CUATM,
                D.FORM,
                D.FORM_VERS,
                D.CUATM_FULL,
                D.PERIOADA,
                SUM(CASE WHEN D.CAPITOL = 100 AND D.RIND = 'CD'
                         THEN D.COL1 ELSE 0 END) AS CD,
                CIS2.NVAL(SUM(CASE WHEN D.CAPITOL = 1127 AND D.RIND = '400'
                                    THEN CIS2.NVAL(D.COL4) ELSE 0 END)) AS COL2,
                CIS2.NVAL(SUM(CASE WHEN D.CAPITOL = 1124 AND D.RIND = '150'
                                    THEN CIS2.NVAL(D.COL1) END)) AS COL3,
                -- Clasamente globale (nu separate pe fiecare CAEM2).
                ROW_NUMBER() OVER (
                    ORDER BY CIS2.NVAL(SUM(CASE WHEN D.CAPITOL = 1124
                                                   AND D.RIND = '150'
                                               THEN CIS2.NVAL(D.COL1) END)) DESC NULLS LAST
                ) AS R150,
                ROW_NUMBER() OVER (
                    ORDER BY CIS2.NVAL(SUM(CASE WHEN D.CAPITOL = 1127
                                                   AND D.RIND = '400'
                                               THEN CIS2.NVAL(D.COL4) END)) DESC NULLS LAST
                ) AS R400
            FROM CIS2.VW_DATA_ALL_COEF D
            INNER JOIN CIS2.RENIM R
                ON R.CUIIO = D.CUIIO
               AND R.CUIIO_VERS = D.CUIIO_VERS
            WHERE D.FORM IN (64)
              AND D.FORM_VERS = :PFORM_VERS
              AND D.PERIOADA = :PPERIOADA
              AND D.CUATM_FULL LIKE '%' || :PCOD_CUATM || ';%'
              AND D.CAPITOL IN (1123, 1124, 1125, 1126, 1127, 1128, 1129, 100)
            GROUP BY
                D.CUIIO, D.CUIIO_VERS, D.CUATM, D.FORM,
                D.FORM_VERS, D.CUATM_FULL, D.PERIOADA,
                SUBSTR(R.CAEM2, 2, 4)
            HAVING
                NVAL(SUM(COL1)) + NVAL(SUM(COL2)) +
                NVAL(SUM(COL3)) + NVAL(SUM(COL4)) > 0
                AND (
                    SUM(CASE WHEN D.ID_MD = 62382 AND D.COL1 IS NOT NULL
                             THEN D.COL1 ELSE 0 END) = 1
                    OR
                    SUM(CASE WHEN D.ID_MD IN (114171, 62413)
                              AND D.COL1 IS NOT NULL
                             THEN D.COL1 ELSE 0 END) > 0
                )
        ) DD
        INNER JOIN (
            SELECT CODUL, DENUMIRE, GRUPA, ORDINE, FULL_CODE, NUM_CODE, PRIM
            FROM CIS2.VW_CL_CAEM2
            WHERE (
                CODUL LIKE 'B%' OR CODUL LIKE 'C%' OR CODUL LIKE 'D%' OR
                CODUL LIKE 'E%' OR CODUL LIKE 'F%' OR CODUL LIKE 'G%' OR
                CODUL LIKE 'H%' OR CODUL LIKE 'I%' OR CODUL LIKE 'J%' OR
                CODUL LIKE 'K%' OR CODUL LIKE 'L%' OR CODUL LIKE 'M%' OR
                CODUL LIKE 'N%' OR CODUL LIKE 'P%' OR CODUL LIKE 'Q%' OR
                CODUL LIKE 'R%' OR CODUL LIKE 'S%'
            )
              AND SUBSTR(CODUL, 1, 3) NOT IN ('S94', 'K65')
              AND CODUL NOT IN ('K6419', 'K6411')
        ) C
            ON SUBSTR(C.CODUL, 2, 4) = DD.CAEM_FINAL
        INNER JOIN CIS2.VW_CL_CAEM2 CC
            ON C.FULL_CODE LIKE '%' || CC.CODUL || ';%'
        WHERE DD.FORM = :pFORM
          AND DD.FORM_VERS = :pFORM_VERS
          AND :pID_MDTABLE = :pID_MDTABLE
        GROUP BY CC.FULL_CODE, CC.DENUMIRE, CC.CODUL
        ORDER BY CC.CODUL
    )
    WHERE DENUMIRE IS NOT NULL
)
ORDER BY ORDINE;
