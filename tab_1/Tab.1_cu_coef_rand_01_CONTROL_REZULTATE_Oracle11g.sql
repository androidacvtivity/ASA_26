-- CONTROL COMPARATIV Oracle 11g
-- Executati mai intai varianta veche si cea optimizata in mediu de test,
-- cu doua ID_MDTABLE distincte (aceleasi PERIOADA, FORM, FORM_VERS si COD_CUATM).
-- Ambele SELECT-uri produc aceeasi structura; nu modifica datele.
--
-- :pID_MDTABLE_VECHI = ID folosit la rularea originalului
-- :pID_MDTABLE_OPT   = ID folosit la rularea optimizata
--
-- Pentru echivalenta, DIF_VECHI_MINUS_OPT = 0, DIF_OPT_MINUS_VECHI = 0,
-- iar RANDURI_VECHI = RANDURI_OPT = 105 (5 sectii x 21 indicatori).
WITH VECHI AS (
    SELECT
        NR_SECTIE, NUME_SECTIE, NR_ROW, ORDINE, DECIMAL_POS, NUME_ROW,
        COL1, COL2, COL3, COL4, COL5, COL6
    FROM CIS2.TABLE_OUT
    WHERE PERIOADA = :pPERIOADA
      AND FORM = :pFORM
      AND FORM_VERS = :pFORM_VERS
      AND COD_CUATM = :pCOD_CUATM
      AND ID_MDTABLE = :pID_MDTABLE_VECHI
),
OPT AS (
    SELECT
        NR_SECTIE, NUME_SECTIE, NR_ROW, ORDINE, DECIMAL_POS, NUME_ROW,
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
    (SELECT COUNT(*) FROM OPT) AS RANDURI_OPT,
    (SELECT COUNT(*) FROM (
        SELECT * FROM VECHI
        MINUS
        SELECT * FROM OPT
    )) AS DIF_VECHI_MINUS_OPT,
    (SELECT COUNT(*) FROM (
        SELECT * FROM OPT
        MINUS
        SELECT * FROM VECHI
    )) AS DIF_OPT_MINUS_VECHI
FROM DUAL;
