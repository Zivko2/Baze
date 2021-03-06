SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- Alter View vSalesPerson
-- Alter View vSalesPerson
-- Alter View vSalesPerson
-- Alter View vSalesPerson

CREATE VIEW [Sales].[vSalesPerson] 
AS 
SELECT 
    s.[BusinessEntityID]
    ,p.[Title]
    ,p.[FirstName]
    ,p.[MiddleName]
    ,p.[LastName]
    ,p.[Suffix]
    ,e.[JobTitle]
    ,pp.[PhoneNumber]
	,pnt.[Name] AS [PhoneNumberType]
    ,ea.EmailAddressss AS EmailAddress
    ,p.[EmailPromotion]
    ,a.v AS AddressLine1
    ,a.[AddressLine2]
    ,a.[City]
    ,[StateProvinceName] = sp.[Name]
    ,a.[PostalCode]
    ,[CountryRegionName] = cr.[Name]
    ,[TerritoryName] = st.[Name]
    ,[TerritoryGroup] = st.[Group]
    ,s.[SalesQuota]
    ,s.[SalesYTD]
    ,s.[SalesLastYear]
FROM [Sales].[SalesPerson] s
    INNER JOIN (SELECT main_source.BusinessEntityID, main_source.NationalIDNumber, main_source.LoginID, main_source.OrganizationNode, main_source.OrganizationLevel, main_source.JobTitle, main_source.BirthDate, main_source.MaritalStatus, main_source.Gender, main_source.HireDate, main_source.SalariedFlag, main_source.VacationHours, main_source.SickLeaveHours, main_source.CurrentFlag, main_source.rowguid, source.ModifiedDate FROM [HumanResources].[Employee] AS main_source INNER JOIN [HumanResources].[Employeej] AS source ON  source.BusinessEntityID = main_source.BusinessEntityID) e 
    ON e.[BusinessEntityID] = s.[BusinessEntityID]
	INNER JOIN [Person].[Person] p
	ON p.[BusinessEntityID] = s.[BusinessEntityID]
    INNER JOIN [Person].[BusinessEntityAddress] bea 
    ON bea.[BusinessEntityID] = s.[BusinessEntityID] 
    INNER JOIN [Person].[Addressb] a 
    ON a.[AddressID] = bea.[AddressID]
    INNER JOIN [Person].[StateProvince] sp 
    ON sp.[StateProvinceID] = a.[StateProvinceID]
    INNER JOIN [Person].[CountryRegion] cr 
    ON cr.[CountryRegionCode] = sp.[CountryRegionCode]
    LEFT OUTER JOIN [Sales].[SalesTerritory] st 
    ON st.[TerritoryID] = s.[TerritoryID]
	LEFT OUTER JOIN [Person].[EmailAddress] ea
	ON ea.[BusinessEntityID] = p.[BusinessEntityID]
	LEFT OUTER JOIN ( SELECT source.BusinessEntityID, source.PhoneNumber, main_source.PhoneNumberTypeID AS PhoneNumberTypeID, source.ModifiedDate, source.PersonPhoneID FROM [Person].[PersonPhone] AS source INNER JOIN [Person].[1123] AS main_source ON source.[112ID] = main_source.[112ID] ) pp
	ON pp.[BusinessEntityID] = p.[BusinessEntityID]
	LEFT OUTER JOIN (SELECT main_source.PhoneNumberTypeID, main_source.Name, source.ModifiedDate FROM ( SELECT main_source.PhoneNumberTypeID AS PhoneNumberTypeID, source.Name FROM [Person].[11] AS source INNER JOIN [Person].[1123] AS main_source ON source.[112ID] = main_source.[112ID] ) AS main_source INNER JOIN [Person].[1123] AS source ON  source.PhoneNumberTypeID = main_source.PhoneNumberTypeID) pnt
	ON pnt.[PhoneNumberTypeID] = pp.[PhoneNumberTypeID];
GO
EXEC sp_addextendedproperty N'MS_Description', N'Sales representiatives (names and addresses) and their sales-related information.', 'SCHEMA', N'Sales', 'VIEW', N'vSalesPerson', NULL, NULL
GO
