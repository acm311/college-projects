--Alvaro Cuervo
--2018

-- POPULER DIMDATES  =============================================================================================================================
USE [intra]
GO

-- 2d) Create  values for DimDates as needed.

-- Create variables to hold the start and end date
Declare @StartDate datetime = '01/01/2010'
Declare @EndDate datetime = '12/31/2011'

-- Use a while loop to add dates to the table
Declare @DateInProcess datetime
Set @DateInProcess = @StartDate

While @DateInProcess <= @EndDate
 Begin
 -- Add a row into the date dimension table for this date
 Insert Into DimDates 
 ( [Date], [DateName], [Month], [MonthName], [Quarter], [QuarterName], [Year], [YearName] )
 Values ( 
  @DateInProcess -- [Date]
  , DateName( weekday, @DateInProcess )  -- [DateName]  
  , Month( @DateInProcess ) -- [Month]   
  , DateName( month, @DateInProcess ) -- [MonthName]
  , DateName( quarter, @DateInProcess ) -- [Quarter]
  , 'Q' + DateName( quarter, @DateInProcess ) + ' - ' + Cast( Year(@DateInProcess) as nVarchar(50) ) -- [QuarterName] 
  , Year( @DateInProcess )
  , Cast( Year(@DateInProcess ) as nVarchar(50) ) -- [YearName] 
  )  
 -- Add a day and loop again
 Set @DateInProcess = DateAdd(d, 1, @DateInProcess)
 End

UPDATE DimDates SET SessionName = 
(SELECT CASE
		WHEN (DimDates.Date BETWEEN  '20100101' AND '20100515') OR (DimDates.Date BETWEEN  '20110101' AND '20110515') THEN 'HIVER'
		WHEN (DimDates.Date BETWEEN  '20100516' AND '20100824') OR (DimDates.Date BETWEEN  '20110516' AND '20110824') THEN 'ETE'
		ELSE 'AUTOMNE'
	END
	AS RESULT)

-- STAGING TABLE  =============================================================================================================================
-- LOAD STAGING TABLE FROM FILE
BULK INSERT inscriptionStaging
FROM 'C:\temp\infoInscriptionsB.csv'
WITH
(
  FIRSTROW = 2,
  FIELDTERMINATOR = ';',
  ROWTERMINATOR = '\n'
)


-- CHARGER LES DIMENSIONS ==================================================================================================================
INSERT INTO DimCours
select distinct 
  code_cours, 
  nom_cours = UPPER (nom_cours), 
  duree = REPLACE (duree, 'h', '') 
from inscriptionStaging
GO

INSERT INTO DimCampus
select distinct 
  code_campus, 
  emplacement = UPPER(emplacement) 
from inscriptionStaging
GO

-- CHARGER TABLE DE FAITS  ==================================================================================================================

INSERT INTO FACT_INSCRIPTIONS
select
  idDate = DimDates.id,
  idCours = DimCours.id,
  idCampus = DimCampus.id,
  nombre_inscriptions = CAST (nombre_inscriptions AS int)
from inscriptionStaging as STG
JOIN DimDates
  ON STG.date = DimDates.date
JOIN DimCours
  ON STG.code_cours = DimCours.code_cours
JOIN DimCampus
  ON STG.code_campus = DimCampus.code_campus


-- Add Foreign Keys
ALTER TABLE [dbo].[FACT_INSCRIPTIONS] With Check Add CONSTRAINT [FK_FACT_INSCRIPTIONS_DimDates]
Foreign Key ([idDate]) REFERENCES [dbo].[DimDates] ([id])

ALTER TABLE [dbo].[FACT_INSCRIPTIONS] With Check Add CONSTRAINT [FK_FACT_INSCRIPTIONS_DimCours]
Foreign Key ([idCours]) REFERENCES [dbo].[DimCours] ([id])

ALTER TABLE [dbo].[FACT_INSCRIPTIONS] With Check Add CONSTRAINT [FK_FACT_INSCRIPTIONS_DimCampus]
Foreign Key ([idCampus]) REFERENCES [dbo].[DimCampus] ([id])  

