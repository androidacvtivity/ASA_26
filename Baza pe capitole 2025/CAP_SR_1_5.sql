 
SELECT 
DISTINCT D.CUIIO 
FROM CIS2.DATA_ALL D

 WHERE (D.PERIOADA = :pPERIOADA)
            
              AND D.FORM IN (64)
              AND D.FORM_VERS IN (2000)
              AND D.ID_MD IN (62382,114171,62413)
              
              
              GROUP BY 
              D.CUIIO

 HAVING (
           SUM(CASE WHEN D.ID_MD = 62382 AND D.COL1 IS NOT NULL
                    THEN D.COL1 ELSE 0 END) = 1
        OR SUM(CASE WHEN D.ID_MD IN (114171, 62413) AND D.COL1 IS NOT NULL
                    THEN D.COL1 ELSE 0 END) > 0
    )