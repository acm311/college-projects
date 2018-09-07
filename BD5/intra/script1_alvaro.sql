--Alvaro Cuervo
--2018

--CREATION DE LA BD ====================================================================================================
USE [master]
GO

IF EXISTS (SELECT name FROM sys.databases WHERE name = N'intra')
	BEGIN
		-- Close connections to the intra database
		ALTER DATABASE [intra] SET SINGLE_USER WITH ROLLBACK IMMEDIATE
		DROP DATABASE [intra]
	END
GO

CREATE DATABASE [intra] ON PRIMARY
(	NAME = N'intra',
	FILENAME = N'C:\temp\intra.mdf')
	LOG ON
(	NAME = N'intra_log',
	FILENAME = N'C:\temp\intra_log.LDF'
)
GO


--CREATE A STAGING TABLE TO HOLD IMPORTED ETL DATA======================================================================
USE [intra]
GO

CREATE TABLE [inscriptionStaging] ( 
	[code_cours] varchar(50),
	[nom_cours] varchar(50),
	[duree] varchar(50),
	[code_campus] varchar(50),
	[emplacement] varchar(50),
	[date] varchar(50),
	[nombre_inscriptions] varchar(50)
)

--CREER LES DIMENSIONS ================================================================================================================================

USE [intra]
GO

CREATE TABLE [dbo].[DimCours](
	[id] [int] NOT NULL PRIMARY KEY Identity,
	[code_cours] [nvarchar](20) NOT NULL,
	[nom_cours] [nvarchar](30) NOT NULL,
	[duree_heures] int NOT NULL
)
GO

CREATE TABLE [dbo].[DimCampus](
	[id] [int] NOT NULL PRIMARY KEY Identity,
	[code_campus] [nvarchar](20) NOT NULL,
	[emplacement] [nvarchar](20) NOT NULL,
)
GO

--CREER LA DIMENSION DATE ================================================================================================================================

USE [intra]
GO

CREATE TABLE [dbo].[DimDates](
	[id] int NOT NULL PRIMARY KEY Identity,
	[Date] datetime NOT NULL,				-- valeur de type datetime stockee dans la table
	[DateName] nvarchar(50),				-- nom du jour
	[Month] int NOT NULL,					-- numero de mois de l'annee
	[MonthName] nvarchar(50) NOT NULL,		-- nom du mois de l'annee
	[Quarter] int NOT NULL,					-- le numero du trimestre (1, 2, 3 ou 4)
	[QuarterName] nvarchar(50) NOT NULL,	-- un nom de trimestre obtenu en concatenant plusierus info
	[Year] int NOT NULL,					-- l'annee numerique
	[YearName] nvarchar(50) NOT NULL,		-- info sur l'annee (en chaine de caracteres)
	[SessionName] nvarchar(50)		-- session
)


--CREER LES TABLES DE FAIT ================================================================================================================================

USE [intra]
GO

CREATE TABLE [dbo].[FACT_INSCRIPTIONS](
	[idDate] [int] NOT NULL,
	[idCours] [int] NOT NULL,
	[idCampus] [int] NOT NULL,
	[nombre_inscriptions] [int] NOT NULL,
	CONSTRAINT [PK_FACT_VENTES] PRIMARY KEY CLUSTERED ([idDate], [idCours], [idCampus])
)
GO
