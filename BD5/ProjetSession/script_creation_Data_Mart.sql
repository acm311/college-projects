-- Raul Bernal
-- Alvaro Cuervo
-- Octobre 2018

--CREATION DE LA BD ====================================================================================================

USE [master]
GO

IF EXISTS (SELECT name FROM sys.databases WHERE name = N'DW_Northwind_Sales')
	BEGIN
		-- Close connections to the intra database
		ALTER DATABASE [DW_Northwind_Sales] SET SINGLE_USER WITH ROLLBACK IMMEDIATE
		DROP DATABASE [DW_Northwind_Sales]
	END
GO

CREATE DATABASE [DW_Northwind_Sales] ON PRIMARY
(	NAME = N'DW_Northwind_Sales',
	FILENAME = N'C:\temp\DW_Northwind_Sales.mdf')
	LOG ON
(	NAME = N'DW_Northwind_Sales_log',
	FILENAME = N'C:\temp\DW_Northwind_Sales_log.LDF'
)
GO

--CREER LES DIMENSIONS ==================================================================================================
USE [DW_Northwind_Sales]
GO

CREATE TABLE [dbo].[DimProduct](
	[id] [int] NOT NULL PRIMARY KEY Identity,
	[ProductID] [int] NOT NULL,
	[ProductName] [nvarchar](40) NOT NULL,
	[QuantityPerUnit] [nvarchar](20) NULL,
	[UnitPrice] [money] NULL,
	[UnitsInStock] [smallint] NULL,
	[UnitsOnOrder] [smallint] NULL,
	[ReorderLevel] [smallint] NULL,
	[Discontinued] [bit] NOT NULL
)
GO

CREATE TABLE [dbo].[DimShipper](
	[id] [int] NOT NULL PRIMARY KEY Identity,
	[ShipperID] [int] NOT NULL,
	[CompanyName] [nvarchar](40) NOT NULL,
	[Phone] [nvarchar](24) NULL
)
GO

CREATE TABLE [dbo].[DimGeography](
	[id] [int] NOT NULL PRIMARY KEY Identity,
	[Country] [nvarchar](15) NULL,	
	[Region] [nvarchar](15) NULL,	
	[City] [nvarchar](15) NULL,
	[PostalCode] [nvarchar](10) NULL
)
GO

CREATE TABLE [dbo].[DimSupplier](
	[id] [int] NOT NULL PRIMARY KEY Identity,
	[SupplierID] [int] NOT NULL,	
	[CompanyName] [nvarchar](40) NOT NULL,
	[ContactName] [nvarchar](30) NULL,
	[ContactTitle] [nvarchar](30) NULL,
	[Address] [nvarchar](60) NULL,	
	[Phone] [nvarchar](24) NULL,
	[Fax] [nvarchar](24) NULL,
	[HomePage] [ntext] NULL
)
GO

CREATE TABLE [dbo].[DimEmployee](
	[id] [int] NOT NULL PRIMARY KEY Identity,
	[EmployeeID] [int] NOT NULL,
	[LastName] [nvarchar](20) NOT NULL,
	[FirstName] [nvarchar](10) NOT NULL,
	[Title] [nvarchar](30) NULL,
	[TitleOfCourtesy] [nvarchar](25) NULL,
	[BirthDate] [datetime] NULL,
	[HireDate] [datetime] NULL,
	[Address] [nvarchar](60) NULL,
	[HomePhone] [nvarchar](24) NULL,
	[Extension] [nvarchar](4) NULL,
	[Photo] [image] NULL,
	[Notes] [ntext] NULL,
	[PhotoPath] [nvarchar](255) NULL
)
GO

CREATE TABLE [dbo].[DimCustomer](
	[id] [int] NOT NULL PRIMARY KEY Identity,
	[CustomerID] [nchar](5) NOT NULL,
	[CompanyName] [nvarchar](40) NOT NULL,
	[ContactName] [nvarchar](30) NULL,
	[ContactTitle] [nvarchar](30) NULL,
	[Address] [nvarchar](60) NULL,
	[Phone] [nvarchar](24) NULL,
	[Fax] [nvarchar](24) NULL
)
GO


--CREER LA DIMENSION DATE ================================================================================================================================

USE [DW_Northwind_Sales]
GO

CREATE TABLE [dbo].[DimDate](
	[id] int NOT NULL PRIMARY KEY Identity,
	[Date] datetime NOT NULL,				-- valeur de type datetime stockee dans la table
	[DateName] nvarchar(50),				-- nom du jour
	[Month] int NOT NULL,					-- numero de mois de l'annee
	[MonthName] nvarchar(50) NOT NULL,		-- nom du mois de l'annee
	[Quarter] int NOT NULL,					-- le numero du trimestre (1, 2, 3 ou 4)
	[QuarterName] nvarchar(50) NOT NULL,	-- un nom de trimestre obtenu en concatenant plusierus info
	[Year] int NOT NULL,					-- l'annee numerique
	[YearName] nvarchar(50) NOT NULL,		-- info sur l'annee (en chaine de caracteres)
	[YearFiscal] nvarchar(10) NOT NULL
)


--CREER LES TABLES DE FAIT ================================================================================================================================

USE [DW_Northwind_Sales]
GO

CREATE TABLE [dbo].[FACT_SALES](
	[idProduct] [int] NOT NULL,
	[idSupplier] [int] NOT NULL,
	[idEmployee] [int] NOT NULL,
	[idCustomer] [int] NOT NULL,
	[idShipper] [int] NOT NULL,
	[idOrderDate] [int] NOT NULL,
	[idRequiredDate] [int] NOT NULL,
	[idShippedDate] [int] NOT NULL,
	[idGeographyCustomer] [int] NOT NULL,
	[idGeographySupplier] [int] NOT NULL,
	[idGeographyEmployee] [int] NOT NULL,
	[numOrder] [int] NULL,					--OrderId Orders table
	[UnitPrice] [money] NOT NULL,
	[Quantity] [smallint] NOT NULL,
	[Discount] [real] NOT NULL,
	[Total] [real] NOT NULL		
	CONSTRAINT [PK_FACT_VENTES] PRIMARY KEY CLUSTERED ([idProduct], [idSupplier], [idEmployee], [idCustomer], [idShipper],  
		[idOrderDate], [idRequiredDate], [idShippedDate], [idGeographyCustomer], [idGeographySupplier], [idGeographyEmployee])
)
GO

-- Add Foreign Keys

ALTER TABLE [dbo].[FACT_SALES] With Check Add CONSTRAINT [FK_FACT_SALES_DimProduct]
Foreign Key ([idProduct]) REFERENCES [dbo].[DimProduct] ([id])

ALTER TABLE [dbo].[FACT_SALES] With Check Add CONSTRAINT [FK_FACT_SALES_DimSupplier]
Foreign Key ([idSupplier]) REFERENCES [dbo].[DimSupplier] ([id])

ALTER TABLE [dbo].[FACT_SALES] With Check Add CONSTRAINT [FK_FACT_SALES_DimEmployee]
Foreign Key ([idEmployee]) REFERENCES [dbo].[DimEmployee] ([id])

ALTER TABLE [dbo].[FACT_SALES] With Check Add CONSTRAINT [FK_FACT_SALES_DimCustomer]
Foreign Key ([idCustomer]) REFERENCES [dbo].[DimCustomer] ([id])

ALTER TABLE [dbo].[FACT_SALES] With Check Add CONSTRAINT [FK_FACT_SALES_DimShipper]
Foreign Key ([idShipper]) REFERENCES [dbo].[DimShipper] ([id])

ALTER TABLE [dbo].[FACT_SALES] With Check Add CONSTRAINT [FK_FACT_SALES_DimDate_Order]
Foreign Key ([idOrderDate]) REFERENCES [dbo].[DimDate] ([id])

ALTER TABLE [dbo].[FACT_SALES] With Check Add CONSTRAINT [FK_FACT_SALES_DimDate_Required]
Foreign Key ([idRequiredDate]) REFERENCES [dbo].[DimDate] ([id])

ALTER TABLE [dbo].[FACT_SALES] With Check Add CONSTRAINT [FK_FACT_SALES_DimDate_Shipped]
Foreign Key ([idShippedDate]) REFERENCES [dbo].[DimDate] ([id])

ALTER TABLE [dbo].[FACT_SALES] With Check Add CONSTRAINT [FK_FACT_SALES_DimGeography_Customer]
Foreign Key ([idGeographyCustomer]) REFERENCES [dbo].[DimGeography] ([id])

ALTER TABLE [dbo].[FACT_SALES] With Check Add CONSTRAINT [FK_FACT_SALES_DimGeography_Supplier]
Foreign Key ([idGeographySupplier]) REFERENCES [dbo].[DimGeography] ([id])

ALTER TABLE [dbo].[FACT_SALES] With Check Add CONSTRAINT [FK_FACT_SALES_DimGeography_Employee]
Foreign Key ([idGeographyEmployee]) REFERENCES [dbo].[DimGeography] ([id])


