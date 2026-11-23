-- TAB.27.2.2 / ASA 2025 / ORACLE 11g
-- STRUCTURA VECHE: INSERT INTO TABLE_OUT + SELECT-uri imbricate (fara WITH).
-- NOU: clasament independent pentru TOTAL si pentru fiecare sectiune CAEM2.
-- TOTAL: top 5/20 din intreaga selectie eligibila (inclusiv coduri nemapate B-S).
-- B-S: top 5/20 numai din sectiunea respectiva (dupa CAEM_FINAL).
-- COL1, COL2, COL3 = totaluri; COL4-COL7 = procente rotunjite la 1 zecimala.
-- Procentele se calculeaza direct: NU rulati vechiul DECLARE/UPDATE.
-- IMPORTANT: acest cod INSEREAZA un rand TOTAL (NR_ROW='0').
-- Daca TOTAL este creat si de alt SQL, dezactivati generarea sa acolo.
-- Nu executati INSERT de mai multe ori pentru aceeasi combinatie de parametri.
-- Inainte de INSERT, testati versiunea SELECT de control.

INSERT INTO CIS2.TABLE_OUT
(
    PERIOADA, FORM, FORM_VERS, ID_MDTABLE, COD_CUATM,
    NR_SECTIE, NUME_SECTIE, NR_SECTIE1, NUME_SECTIE1,
    NR_SECTIE2, NUME_SECTIE2, NR_ROW, ORDINE, DECIMAL_POS,
    NUME_ROW, COL1, COL2, COL3, COL4, COL5, COL6, COL7
)
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
    ROWNUM AS ORDINE,
    '0001111' AS DECIMAL_POS,
    T.NUME_ROW,
    T.COL1,
    T.COL2,
    T.COL3,
    -- Procente calculate direct, ca in fostul UPDATE:
    ROUND(T.COL4 / NOZERO(T.COL2) * 100, 1) AS COL4,
    ROUND(T.COL5 / NOZERO(T.COL2) * 100, 1) AS COL5,
    ROUND(T.COL6 / NOZERO(T.COL3) * 100, 1) AS COL6,
    ROUND(T.COL7 / NOZERO(T.COL3) * 100, 1) AS COL7
FROM
(
    SELECT
        CASE WHEN TIP = 'TOTAL'
             THEN '0'
             ELSE CODUL || '~' || COL1 || '1'
        END AS NR_ROW,
        CASE WHEN TIP = 'TOTAL'
             THEN '0'
             ELSE '1' || ORDINE
        END AS ORDINE,
        DENUMIRE AS NUME_ROW,
        COL1, COL2, COL3, COL4, COL5, COL6, COL7
    FROM
    (
        SELECT
            DD.TIP,
            DD.CODUL,
            DD.DENUMIRE,
            DD.ORDINE,
            -- Totalurile se insumeaza nerotunjit; rotunjire numai la sfarsit.
            CIS2.NVAL(ROUND(SUM(DD.CD), 1))   AS COL1,
            CIS2.NVAL(ROUND(SUM(DD.COL2), 1)) AS COL2,
            CIS2.NVAL(ROUND(SUM(DD.COL3), 1)) AS COL3,
            -- R400: top 5/20 pe TOTAL sau pe sectiune, dupa caz.
            CIS2.NVAL(SUM(CASE WHEN DD.R400 BETWEEN 1 AND 5
                               THEN DD.COL2 END)) AS COL4,
            CIS2.NVAL(SUM(CASE WHEN DD.R400 BETWEEN 1 AND 20
                               THEN DD.COL2 END)) AS COL5,
            -- R150: top 5/20 pe TOTAL sau pe sectiune, dupa caz.
            CIS2.NVAL(SUM(CASE WHEN DD.R150 BETWEEN 1 AND 5
                               THEN DD.COL3 END)) AS COL6,
            CIS2.NVAL(SUM(CASE WHEN DD.R150 BETWEEN 1 AND 20
                               THEN DD.COL3 END)) AS COL7
        FROM
        (
            SELECT
                E.CUIIO,
                E.CUIIO_VERS,
                E.CUATM,
                E.FORM,
                E.FORM_VERS,
                E.PERIOADA,
                E.CAEM_FINAL,
                E.CD,
                E.COL2,
                E.COL3,
                TIP.TIP,
                CASE WHEN TIP.TIP = 'TOTAL' THEN '00000'
                     ELSE C.CODUL_SECTIUNE END AS CODUL,
                CASE WHEN TIP.TIP = 'TOTAL' THEN 'TOTAL PE ACTIVITATI'
                     ELSE C.DENUMIRE_SECTIUNE END AS DENUMIRE,
                CASE WHEN TIP.TIP = 'TOTAL' THEN '0'
                     ELSE C.FULL_CODE_SECTIUNE END AS ORDINE,
                -- Ambele clasamente sunt independente in fiecare partitionare:
                -- TOTAL = toate intreprinderile eligibile;
                -- SECT = intreprinderi din B, C, D etc., separat.
                ROW_NUMBER() OVER
                (
                    PARTITION BY TIP.TIP,
                                 CASE WHEN TIP.TIP = 'TOTAL' THEN '00000'
                                      ELSE C.CODUL_SECTIUNE END
                    ORDER BY E.COL2 DESC NULLS LAST,
                             E.CUIIO, E.CUIIO_VERS, E.CUATM
                ) AS R400,
                ROW_NUMBER() OVER
                (
                    PARTITION BY TIP.TIP,
                                 CASE WHEN TIP.TIP = 'TOTAL' THEN '00000'
                                      ELSE C.CODUL_SECTIUNE END
                    ORDER BY E.COL3 DESC NULLS LAST,
                             E.CUIIO, E.CUIIO_VERS, E.CUATM
                ) AS R150
            FROM
            (
                -- Agregare pe intreprindere: pastram WHERE, HAVING si CAEM_FINAL.
                SELECT
                    D.CUIIO,
                    D.CUIIO_VERS,
                    D.CUATM,
                    D.FORM,
                    D.FORM_VERS,
                    D.CUATM_FULL,
                    D.PERIOADA,
                    CASE
                        WHEN MAX(CASE WHEN D.ID_MD = 61832
                                      THEN D.COL31 END) IS NULL
                        THEN SUBSTR(R.CAEM2, 2, 4)
                        ELSE MAX(CASE WHEN D.ID_MD = 61832
                                      THEN D.COL31 END)
                    END AS CAEM_FINAL,
                    SUM(CASE WHEN D.CAPITOL = 100 AND D.RIND = 'CD'
                             THEN D.COL1 ELSE 0 END) AS CD,
                    CIS2.NVAL(SUM(CASE WHEN D.CAPITOL = 1127
                                        AND D.RIND = '400'
                                        THEN CIS2.NVAL(D.COL4) ELSE 0 END)) AS COL2,
                    CIS2.NVAL(SUM(CASE WHEN D.CAPITOL = 1124
                                        AND D.RIND = '150'
                                        THEN CIS2.NVAL(D.COL1) END)) AS COL3
                FROM CIS2.VW_DATA_ALL_COEF D
                INNER JOIN CIS2.RENIM R
                    ON R.CUIIO = D.CUIIO
                   AND R.CUIIO_VERS = D.CUIIO_VERS
                WHERE D.FORM IN (64)
                  AND D.FORM_VERS = :pFORM_VERS
                  AND D.PERIOADA = :pPERIOADA
                  AND D.CUATM_FULL LIKE '%' || :pCOD_CUATM || ';%'
                  AND D.CAPITOL IN
                      (1123, 1124, 1125, 1126, 1127, 1128, 1129, 100)
                GROUP BY
                    D.CUIIO, D.CUIIO_VERS, D.CUATM, D.FORM,
                    D.FORM_VERS, D.CUATM_FULL, D.PERIOADA,
                    SUBSTR(R.CAEM2, 2, 4)
                HAVING
                    NVAL(SUM(D.COL1)) + NVAL(SUM(D.COL2)) +
                    NVAL(SUM(D.COL3)) + NVAL(SUM(D.COL4)) > 0
                    AND
                    (
                        SUM(CASE WHEN D.ID_MD = 62382
                                  AND D.COL1 IS NOT NULL
                                 THEN D.COL1 ELSE 0 END) = 1
                        OR
                        SUM(CASE WHEN D.ID_MD IN (114171, 62413)
                                  AND D.COL1 IS NOT NULL
                                 THEN D.COL1 ELSE 0 END) > 0
                    )
            ) E
            -- Maparea CAEM2 in sectiuni, exact pe baza clasificatorului
            -- original. DISTINCT protejeaza impotriva duplicarii din mapare.
            LEFT JOIN
            (
                SELECT DISTINCT
                    SUBSTR(C.CODUL, 2, 4) AS COD_CAEM,
                    CC.CODUL AS CODUL_SECTIUNE,
                    CC.DENUMIRE AS DENUMIRE_SECTIUNE,
                    CC.FULL_CODE AS FULL_CODE_SECTIUNE
                FROM
                (
                    SELECT CODUL, DENUMIRE, GRUPA, ORDINE,
                           FULL_CODE, NUM_CODE, PRIM
                    FROM CIS2.VW_CL_CAEM2
                    WHERE SUBSTR(CODUL, 1, 1) IN
                        ('B','C','D','E','F','G','H','I','J','K',
                         'L','M','N','P','Q','R','S')
                      AND SUBSTR(CODUL, 1, 3) NOT IN ('S94','K65')
                      AND CODUL NOT IN ('K6419','K6411')
                ) C
                INNER JOIN CIS2.VW_CL_CAEM2 CC
                    ON C.FULL_CODE LIKE '%' || CC.CODUL || ';%'
                   AND CC.CODUL = SUBSTR(C.CODUL, 1, 1) || '0000'
                WHERE CC.DENUMIRE IS NOT NULL
            ) C ON C.COD_CAEM = E.CAEM_FINAL
            CROSS JOIN
            (
                SELECT 'TOTAL' AS TIP FROM DUAL
                UNION ALL
                SELECT 'SECT' AS TIP FROM DUAL
            ) TIP
            WHERE E.FORM = :pFORM
              AND E.FORM_VERS = :pFORM_VERS
              AND (TIP.TIP = 'TOTAL' OR C.CODUL_SECTIUNE IS NOT NULL)
        ) DD
        GROUP BY DD.TIP, DD.CODUL, DD.DENUMIRE, DD.ORDINE
    )
    ORDER BY ORDINE
) T;
