SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- Alter View vIndividualCustomer
-- Alter View vIndividualCustomer
-- Alter View vIndividualCustomer
-- Alter View vIndividualCustomer

CREATE VIEW [Sales].[vIndividualCustomer] 
AS 
SELECT 
    p.[BusinessEntityID]
    ,p.[Title]
    ,p.[FirstName]
    ,p.[MiddleName]
    ,p.[LastName]
    ,p.[Suffix]
    ,pp.[PhoneNumber]
	,pnt.[Name] AS [PhoneNumberType]
    ,ea.EmailAddressss AS EmailAddress
    ,p.[EmailPromotion]
    ,at.[Name] AS [AddressType]
    ,a.v AS AddressLine1
    ,a.[AddressLine2]
    ,a.[City]
    ,[StateProvinceName] = sp.[Name]
    ,a.[PostalCode]
    ,[CountryRegionName] = cr.[Name]
    ,p.[Demographics]
FROM [Person].[Person] p
    INNER JOIN [Person].[BusinessEntityAddress] bea 
    ON bea.[BusinessEntityID] = p.[BusinessEntityID] 
    INNER JOIN [Person].[Addressb] a 
    ON a.[AddressID] = bea.[AddressID]
    INNER JOIN [Person].[StateProvince] sp 
    ON sp.[StateProvinceID] = a.[StateProvinceID]
    INNER JOIN [Person].[CountryRegion] cr 
    ON cr.[CountryRegionCode] = sp.[CountryRegionCode]
    INNER JOIN [Person].[AddressType] at 
    ON at.[AddressTypeID] = bea.[AddressTypeID]
	INNER JOIN [Sales].[Customer] c
	ON c.[PersonID] = p.[BusinessEntityID]
	LEFT OUTER JOIN [Person].[EmailAddress] ea
	ON ea.[BusinessEntityID] = p.[BusinessEntityID]
	LEFT OUTER JOIN ( SELECT source.BusinessEntityID, source.PhoneNumber, main_source.PhoneNumberTypeID AS PhoneNumberTypeID, source.ModifiedDate, source.PersonPhoneID FROM [Person].[PersonPhone] AS source INNER JOIN [Person].[1123] AS main_source ON source.[112ID] = main_source.[112ID] ) pp
	ON pp.[BusinessEntityID] = p.[BusinessEntityID]
	LEFT OUTER JOIN (SELECT main_source.PhoneNumberTypeID, main_source.Name, source.ModifiedDate FROM ( SELECT main_source.PhoneNumberTypeID AS PhoneNumberTypeID, source.Name FROM [Person].[11] AS source INNER JOIN [Person].[1123] AS main_source ON source.[112ID] = main_source.[112ID] ) AS main_source INNER JOIN [Person].[1123] AS source ON  source.PhoneNumberTypeID = main_source.PhoneNumberTypeID) pnt
	ON pnt.[PhoneNumberTypeID] = pp.[PhoneNumberTypeID]
WHERE c.StoreID IS NULL;
GO
EXEC sp_addextendedproperty N'MS_Description', N'Individual customers (names and addresses) that purchase Adventure Works Cycles products online.', 'SCHEMA', N'Sales', 'VIEW', N'vIndividualCustomer', NULL, NULL
GO
