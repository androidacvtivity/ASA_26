-- Control comparativ pentru Tab.1 FARA coeficienti - Oracle 11g.
-- Executati in MEDIUL DE TEST ambele versiuni, fiecare cu un ID_MDTABLE distinct
-- si fara alte inregistrari in TABLE_OUT pentru ID-urile de test:
--   :pID_MDTABLE_VECHI   -> Tab.1_fara_coef_rand_01.sql
--   :pID_MDTABLE_OPT     -> Tab.1_fara_coef_rand_01_OPTIMIZAT_Oracle11g.sql
-- Pastrati identice :pPERIOADA, :pFORM, :pFORM_VERS, :pCOD_CUATM.
-- Diferentele in ambele directii trebuie sa fie zero; numarul de randuri: 105.
--
-- Comparati si TIMPUL de executie pentru aceeasi perioada/aceleasi bind-uri.
-- Nu se executa niciun INSERT / UPDATE / DELETE in acest script.

WITH VECHI AS (
    SELECT NR_SECTIE, NUME_SECTIE, NR_ROW, ORDINE, DECIMAL_POS, NUME_ROW,
           COL1, COL2, COL3, COL4, COL5, COL6
    FROM CIS2.TABLE_OUT
    WHERE PERIOADA = :pPERIOADA
      AND FORM = :pFORM
      AND FORM_VERS = :pFORM_VERS
      AND COD_CUATM = :pCOD_CUATM
      AND ID_MDTABLE = :pID_MDTABLE_VECHI
),
OPTIMIZAT AS (
    SELECT NR_SECTIE, NUME_SECTIE, NR_ROW, ORDINE, DECIMAL_POS, NUME_ROW,
           COL1, COL2, COL3, COL4, COL5, COL6
    FROM CIS2.TABLE_OUT
    WHERE PERIOADA = :pPERIOADA
      AND FORM = :pFORM
      AND FORM_VERS = :pFORM_VERS
      AND COD_CUATM = :pCOD_CUATM
      AND ID_MDTABLE = :pID_MDTABLE_OPT
)
SELECT
    (SELECT COUNT(*) FROM VECHI) AS RANDURI_VECHI,
    (SELECT COUNT(*) FROM OPTIMIZAT) AS RANDURI_OPTIMIZAT,
    (SELECT COUNT(*) FROM (
        SELECT * FROM VECHI
        MINUS
        SELECT * FROM OPTIMIZAT
    )) AS DIFERENTE_VECHI_FATA_DE_OPT,
    (SELECT COUNT(*) FROM (
        SELECT * FROM OPTIMIZAT
        MINUS
        SELECT * FROM VECHI
    )) AS DIFERENTE_OPT_FATA_DE_VECHI
FROM DUAL;
