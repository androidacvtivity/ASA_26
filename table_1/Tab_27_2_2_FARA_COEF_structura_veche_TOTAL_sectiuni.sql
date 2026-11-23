-- TAB.27.2.2 - ASA, varianta FARA COEFICIENTI - Oracle 11g
-- Structura veche: INSERT INTO ... SELECT cu subinterogari imbricate (fara WITH).
-- COL1 = COUNT(DISTINCT CUIIO), NU SUM(CD)!
-- Sursa: CIS2.VW_DATA_ALL (NU VW_DATA_ALL_COEF).
-- COL2: cap.1127, rind 400, col.4; COL3: cap.1124, rind 150, col.1.
-- COL4/5: Top 5/20 dupa COL2, pondere in COL2.
-- COL6/7: Top 5/20 dupa COL3, pondere in COL3.
-- TOTAL: clasament global din toate intreprinderile eligibile.
-- B-S: clasament separat, dupa sectiunea CAEM2 actualizata.
-- CAEM_FINAL = ID_MD 61832 / D.COL31, daca exista; altfel RENIM.CAEM2.
-- Capitolul 1129 este inclus in filtrul D.CAPITOL IN (...) pentru CAEM actualizat.
-- FARA al doilea UPDATE: procente calculate direct in INSERT.
-- Atentie: TOTAL este creat aici, NR_ROW='0'. Daca e creat de alta rutina,
-- folositi varianta NUMAI_SECTIUNI si nu inserati TOTAL de doua ori.
-- Inainte de INSERT rulati varianta SELECT de control.
-- Nu am executat aceasta interogare pe serverul Oracle.

INSERT INTO CIS2.TABLE_OUT
(
    PERIOADA, FORM, FORM_VERS, ID_MDTABLE, COD_CUATM,
    NR_SECTIE, NUME_SECTIE, NR_SECTIE1, NUME_SECTIE1,
    NR_SECTIE2, NUME_SECTIE2,
    NR_ROW, ORDINE, DECIMAL_POS, NUME_ROW,
    COL1, COL2, COL3, COL4, COL5, COL6, COL7
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
    CASE
        WHEN G.TIP = 'TOTAL' THEN '0'
        ELSE G.CODUL_SECTIUNE || '~' || TO_CHAR(G.COL1) || '1'
    END AS NR_ROW,
    ROW_NUMBER() OVER
    (
        ORDER BY CASE WHEN G.TIP = 'TOTAL' THEN 0 ELSE 1 END,
                 G.CODUL_SECTIUNE
    ) AS ORDINE,
    '0001111' AS DECIMAL_POS,
    G.NUME_ROW,
    G.COL1,
    G.COL2,
    G.COL3,
    ROUND(G.TOP5_R400  / NOZERO(G.COL2) * 100, 1) AS COL4,
    ROUND(G.TOP20_R400 / NOZERO(G.COL2) * 100, 1) AS COL5,
    ROUND(G.TOP5_R150  / NOZERO(G.COL3) * 100, 1) AS COL6,
    ROUND(G.TOP20_R150 / NOZERO(G.COL3) * 100, 1) AS COL7
FROM
(
    -- O singura agregare pentru TOTAL si pentru toate sectiunile CAEM2.
    SELECT
        T.TIP,
        T.CODUL_SECTIUNE,
        MAX(T.DENUMIRE_SECTIUNE) AS NUME_ROW,

        -- IN ACEST RAPORT COL1 ESTE NUMARUL DISTINCT DE INTREPRINDERI.
        CIS2.NVAL(COUNT(DISTINCT T.CUIIO)) AS COL1,
        CIS2.NVAL(SUM(T.VAL_R400)) AS COL2,
        CIS2.NVAL(SUM(T.VAL_R150)) AS COL3,

        CIS2.NVAL(SUM(CASE WHEN T.R400 BETWEEN 1 AND 5
                            THEN T.VAL_R400 END)) AS TOP5_R400,
        CIS2.NVAL(SUM(CASE WHEN T.R400 BETWEEN 1 AND 20
                            THEN T.VAL_R400 END)) AS TOP20_R400,
        CIS2.NVAL(SUM(CASE WHEN T.R150 BETWEEN 1 AND 5
                            THEN T.VAL_R150 END)) AS TOP5_R150,
        CIS2.NVAL(SUM(CASE WHEN T.R150 BETWEEN 1 AND 20
                            THEN T.VAL_R150 END)) AS TOP20_R150
    FROM
    (
        -- Top 5/20 separat pentru TOTAL si pentru fiecare sectiune.
        SELECT
            X.TIP,
            X.CODUL_SECTIUNE,
            X.DENUMIRE_SECTIUNE,
            X.CUIIO,
            X.CUIIO_VERS,
            X.CUATM,
            X.VAL_R400,
            X.VAL_R150,

            ROW_NUMBER() OVER
            (
                PARTITION BY X.TIP, X.CODUL_SECTIUNE
                ORDER BY X.VAL_R400 DESC NULLS LAST,
                         X.CUIIO, X.CUIIO_VERS, X.CUATM
            ) AS R400,

            ROW_NUMBER() OVER
            (
                PARTITION BY X.TIP, X.CODUL_SECTIUNE
                ORDER BY X.VAL_R150 DESC NULLS LAST,
                         X.CUIIO, X.CUIIO_VERS, X.CUATM
            ) AS R150
        FROM
        (
            -- Fiecare intreprindere participa o data la TOTAL,
            -- si inca o data la propria sectiune CAEM2 (daca este B-S).
            SELECT
                TIP.TIP,
                CASE WHEN TIP.TIP = 'TOTAL' THEN '00000'
                     ELSE CL.CODUL_SECTIUNE END AS CODUL_SECTIUNE,
                CASE WHEN TIP.TIP = 'TOTAL' THEN 'TOTAL PE ACTIVITATI'
                     ELSE CL.DENUMIRE_SECTIUNE END AS DENUMIRE_SECTIUNE,
                DD.CUIIO,
                DD.CUIIO_VERS,
                DD.CUATM,
                DD.VAL_R400,
                DD.VAL_R150
            FROM
            (
                -- O singura agregare per CUIIO / versiune / teritoriu.
                -- Nu grupam dupa D.CAEM2 sau D.CFP, deoarece acestea
                -- pot fragmenta intreprinderea in mai multe randuri.
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
                  AND D.CAPITOL IN
                      (100, 1123, 1124, 1125, 1126, 1127, 1128, 1129)
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
                        SUM(CASE WHEN D.ID_MD = 62382
                                  AND D.COL1 IS NOT NULL
                                 THEN D.COL1 ELSE 0 END) = 1
                        OR
                        SUM(CASE WHEN D.ID_MD IN (114171, 62413)
                                  AND D.COL1 IS NOT NULL
                                 THEN D.COL1 ELSE 0 END) > 0
                    )
            ) DD

            CROSS JOIN
            (
                SELECT 'TOTAL' AS TIP FROM DUAL
                UNION ALL
                SELECT 'SECT' AS TIP FROM DUAL
            ) TIP

            LEFT JOIN
            (
                -- Determinam sectiunea CAEM2 din CAEM_FINAL.
                -- DISTINCT evita dublarile din clasificator.
                SELECT DISTINCT
                    SUBSTR(C.CODUL, 2, 4) AS CAEM4,
                    CC.CODUL AS CODUL_SECTIUNE,
                    CC.DENUMIRE AS DENUMIRE_SECTIUNE
                FROM CIS2.VW_CL_CAEM2 C
                INNER JOIN CIS2.VW_CL_CAEM2 CC
                    ON C.FULL_CODE LIKE '%' || CC.CODUL || ';%'
                   AND CC.CODUL = SUBSTR(C.CODUL, 1, 1) || '0000'
                WHERE SUBSTR(C.CODUL, 1, 1) IN
                    ('B','C','D','E','F','G','H','I','J','K',
                     'L','M','N','P','Q','R','S')
                  AND SUBSTR(C.CODUL, 1, 3) NOT IN ('S94', 'K65')
                  AND C.CODUL NOT IN ('K6419', 'K6411')
            ) CL
                ON CL.CAEM4 = DD.CAEM_FINAL

            WHERE TIP.TIP = 'TOTAL'
               OR (TIP.TIP = 'SECT' AND CL.CODUL_SECTIUNE IS NOT NULL)
        ) X
    ) T
    GROUP BY T.TIP, T.CODUL_SECTIUNE
) G
;
