SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
/*
SELECT	C.CustomerCode, C.Name, RT.Name 
FROM	Customer C
		LEFT JOIN RateType RT ON RT.Oid = C.DefaultRateType
WHERE	RT.Name IN ('Aviation Department', 'Department')
ORDER BY RT.Name
[Staged].[SynchronizeCustomerWithPAR] ''
*/
CREATE PROCEDURE [Staged].[SynchronizeCustomerWithPAR] @DepartmentCostCentres NVARCHAR(1000)
AS
BEGIN

	/* Sync up the Customer table with new or changed customers from the view the BID exposes */
	DECLARE @BarcodePrefix VARCHAR(10)

	SELECT @BarcodePrefix = IsNull(CompanyPrefixToDistinguishBarCodes, '') FROM GlobalSetting

	--The source system (BID) has three tables that we 'will be' crunching into one here.
	--Accounts have zero or more Individuals. 
	--  In the case of zero individuals, we create a Customer solely from the account
	--  In the case of 1 or more individuals, we create a Customer for each of the individuals
	--Individuals have zero or Cards, but only one Card is ever to be marked as 'Active'
	--  This translates to us as a property on the Customer ExternalBarCode
	--   Note that it might be better to have a collection property of BarCodes to allow for a
	--   Customer to have multiple barcodes associated with it. Not from BID, but perhaps they have
	--   their own company's badge and they want to use that. Just an idea.
	INSERT INTO Customer (Oid, Name, CustomerCode, AccountNumberReference, DefaultRateType, Email, [Enabled], BarCode) 
	SELECT NEWID(), ParCustomer.CustomerName COLLATE DATABASE_DEFAULT,
		IsNull(CustomerCode, GLA.AccountNumberFormatted) COLLATE DATABASE_DEFAULT, 
		GLA.AccountNumber COLLATE DATABASE_DEFAULT, 
		CASE WHEN OwnerType = 'D' THEN 
			CASE WHEN GLA.CostCenter IN (SELECT * FROM ParseCommaDelimitedString(@DepartmentCostCentres)) THEN
				(SELECT Oid FROM RateType WHERE Name = 'Aviation Department')
			ELSE
				(SELECT Oid FROM RateType WHERE Name = 'Department')
			END
		ELSE CASE WHEN OwnerType = 'M' THEN
			(SELECT Oid FROM RateType WHERE Name = 'Member')
		ELSE CASE WHEN OwnerType = 'O' THEN
			(SELECT Oid FROM RateType WHERE Name = 'Concession')
		ELSE CASE WHEN OwnerType = 'C' THEN
			(SELECT Oid FROM RateType WHERE Name = 'Commercial')
		END END END END,
		EmailAddress COLLATE DATABASE_DEFAULT, 
		1,
		':X30:' + @BarcodePrefix + ':' + CONVERT(VARCHAR(50), (SELECT MAX(CONVERT(INT, REPLACE(Barcode, ':X30:' + @BarcodePrefix + ':', ''))) FROM Customer) + ROW_NUMBER() OVER(ORDER BY ParCustomer.CustomerCode DESC))
	FROM	[PNGBRANCH_FOR_APEX].[Par].[Apex].[Customer] ParCustomer 
			LEFT JOIN [PNGBRANCH_FOR_APEX].[Par].[Apex].[GlAccount] GLA ON GLA.AccountNumber COLLATE DATABASE_DEFAULT = ParCustomer.GlAccount 
	WHERE   ParCustomer.CustomerCode  COLLATE DATABASE_DEFAULT Not IN (SELECT CustomerCode FROM Customer WHERE CustomerCode Is Not null)

	UPDATE Customer 
		SET Name = ParCustomer.CustomerName COLLATE DATABASE_DEFAULT,
			AccountNumberReference = GLA.AccountNumberFormatted COLLATE DATABASE_DEFAULT,
			Email = LEFT(ParCustomer.EmailAddress, 250) COLLATE DATABASE_DEFAULT,
			DefaultRateType = 
			CASE WHEN ParCustomer.OwnerType = 'D' THEN 
				CASE WHEN GLA.CostCenter IN (SELECT * FROM ParseCommaDelimitedString(@DepartmentCostCentres)) THEN
					(SELECT Oid FROM RateType WHERE Name = 'Aviation Department')
				ELSE
					(SELECT Oid FROM RateType WHERE Name = 'Department')
				END
			ELSE CASE WHEN ParCustomer.OwnerType = 'M' THEN
				(SELECT Oid FROM RateType WHERE Name = 'Member')
			ELSE CASE WHEN ParCustomer.OwnerType = 'O' THEN
				(SELECT Oid FROM RateType WHERE Name = 'Concession')
			ELSE CASE WHEN ParCustomer.OwnerType = 'C' THEN
				(SELECT Oid FROM RateType WHERE Name = 'Commercial')
			END END END END
		FROM Customer C 
				INNER JOIN [PNGBRANCH_FOR_APEX].[Par].[Apex].[Customer] ParCustomer ON ParCustomer.CustomerCode COLLATE DATABASE_DEFAULT = C.CustomerCode
				LEFT JOIN [PNGBRANCH_FOR_APEX].[Par].[Apex].[GlAccount] GLA ON GLA.AccountNumber COLLATE DATABASE_DEFAULT = ParCustomer.GlAccount 
		WHERE C.AccountNumberReference is not null AND 
			(REPLACE(C.Name, 'Disabled - ', '') <> ParCustomer.CustomerName COLLATE DATABASE_DEFAULT
			OR C.AccountNumberReference <> GLA.AccountNumberFormatted COLLATE DATABASE_DEFAULT
			OR C.Email <> LEFT(ParCustomer.EmailAddress, 250) COLLATE DATABASE_DEFAULT)
			
	DECLARE @BarCodeTemp TABLE (Oid UNIQUEIDENTIFIER, Barcode VARCHAR(100))
	INSERT INTO @BarCodeTemp
		SELECT Oid, BarCode = ':X30:' + @BarcodePrefix + ':' + CONVERT(VARCHAR(50), IsNull((SELECT MAX(CONVERT(INT, REPLACE(Barcode, ':X30:' + @BarcodePrefix + ':', ''))) FROM Customer), 0) + ROW_NUMBER() OVER(ORDER BY C.CustomerCode DESC))
		FROM Customer C
		WHERE Barcode Is Null AND GCRecord Is Null

	UPDATE Customer SET Barcode = BCT.Barcode FROM Customer C INNER JOIN @BarCodeTemp BCT ON BCT.Oid = C.Oid

	UPDATE Customer SET [Enabled] = 0, Name = 'Disabled - ' + Name 
	WHERE [Enabled] = 1 AND CustomerCode NOT IN (SELECT CustomerCode COLLATE DATABASE_DEFAULT from [PNGBRANCH_FOR_APEX].[Par].[Apex].[Customer])

	--For now, update these customers to ensure that their currencies are restricted. Later pull this from accpac (see APX-
	UPDATE Customer SET CurrenciesNotAllowed = 'USD, PGK' WHERE CurrenciesNotAllowed <> 'USD, PGK' AND AccountNumberReference IN (
	'10110-420217',
	'10210-420117',
	'10210-600112',
	'10210-610112',
	'10321-420217',
	'10421-420217',
	'24710-430412')

	UPDATE Customer SET CurrenciesNotAllowed = 'USD, AUD' WHERE CurrenciesNotAllowed <> 'USD, AUD' AND AccountNumberReference IN (
	'10100-420217',
	'10100-460214',
	'10100-801353',
	'10100-900112',
	'10100-902112',
	'10100-903112',
	'10100-904112',
	'10100-905112',
	'10100-906112',
	'10100-907112',
	'10100-908112',
	'10105-610112',
	'10105-620112',
	'10105-640112',
	'10105-650112',
	'10105-670112',
	'10105-710117',
	'10105-817053',
	'10300-420217',
	'10300-600112',
	'10300-900112',
	'10300-902112',
	'10300-903112',
	'10300-904112',
	'10300-905112',
	'10300-907112',
	'10300-908112',
	'11320-600112',
	'11321-600112',
	'11322-600112',
	'11323-600112',
	'11350-192100',
	'11350-192107',
	'11350-192140',
	'11350-192150',
	'11350-192156',
	'11350-192157',
	'11350-192190',
	'11360-192120',
	'11360-192135',
	'11360-192165',
	'11360-192170',
	'11360-192185',
	'11360-192221',
	'11650-420217',
	'11686-420217',
	'14300-680112',
	'15100-600812',
	'15200-900112',
	'19056-680112',
	'19057-907112',
	'19061-520117',
	'19063-520117',
	'19064-520117',
	'20199-420217',
	'21030-192847',
	'21080-193968',
	'21080-193969',
	'21080-193971',
	'21080-193972',
	'21200-352730',
	'21400-192015',
	'21400-192030',
	'21400-192915',
	'21400-193385',
	'21610-680112',
	'23400-520117',
	'23500-520117',
	'23710-600112',
	'23850-420217',
	'23999-420217')
	

END
GO
