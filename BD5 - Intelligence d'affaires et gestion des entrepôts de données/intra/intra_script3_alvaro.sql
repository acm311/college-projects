--Alvaro Cuervo
--2018

--QUESTIONS (SQL)  =======================================================================================================================

--nombre d'inscriptions par session, par annee, par campus...
select nombre_inscriptions, sessionName, year, code_campus, emplacement 
from 
FACT_INSCRIPTIONS AS F
JOIN DimDates AS DD
	ON DD.id = F.idDate
JOIN DimCampus AS DC
	ON DC.id = F.idCampus

--cours generent plus d'inscriptions
select code_cours, nom_cours, SUM(nombre_Inscriptions) AS nom_inscr
FROM
FACT_INSCRIPTIONS AS F
JOIN DimCours as DC
	ON DC.id = F.idCours
GROUP BY code_cours, nom_cours
ORDER BY nom_inscr desc