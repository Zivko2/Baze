SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- Alter View vEmployee
-- Alter View vEmployee
-- Alter View vEmployee
-- Alter View vEmployee

CREATE VIEW [HumanResources].[vEmployee] 
AS 
SELECT 
    e.[BusinessEntityID]
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
    ,sp.[Name] AS [StateProvinceName] 
    ,a.[PostalCode]
    ,cr.[Name] AS [CountryRegionName] 
    ,p.[AdditionalContactInfo]
FROM (SELECT main_source.BusinessEntityID, main_source.NationalIDNumber, main_source.LoginID, main_source.OrganizationNode, main_source.OrganizationLevel, main_source.JobTitle, main_source.BirthDate, main_source.MaritalStatus, main_source.Gender, main_source.HireDate, main_source.SalariedFlag, main_source.VacationHours, main_source.SickLeaveHours, main_source.CurrentFlag, main_source.rowguid, source.ModifiedDate FROM [HumanResources].[Employee] AS main_source INNER JOIN [HumanResources].[Employeej] AS source ON  source.BusinessEntityID = main_source.BusinessEntityID) e
	INNER JOIN [Person].[Person] p
	ON p.[BusinessEntityID] = e.[BusinessEntityID]
    INNER JOIN [Person].[BusinessEntityAddress] bea 
    ON bea.[BusinessEntityID] = e.[BusinessEntityID] 
    INNER JOIN [Person].[Addressb] a 
    ON a.[AddressID] = bea.[AddressID]
    INNER JOIN [Person].[StateProvince] sp 
    ON sp.[StateProvinceID] = a.[StateProvinceID]
    INNER JOIN [Person].[CountryRegion] cr 
    ON cr.[CountryRegionCode] = sp.[CountryRegionCode]
    LEFT OUTER JOIN ( SELECT source.BusinessEntityID, source.PhoneNumber, main_source.PhoneNumberTypeID AS PhoneNumberTypeID, source.ModifiedDate, source.PersonPhoneID FROM [Person].[PersonPhone] AS source INNER JOIN [Person].[1123] AS main_source ON source.[112ID] = main_source.[112ID] ) pp
    ON pp.BusinessEntityID = p.[BusinessEntityID]
    LEFT OUTER JOIN (SELECT main_source.PhoneNumberTypeID, main_source.Name, source.ModifiedDate FROM ( SELECT main_source.PhoneNumberTypeID AS PhoneNumberTypeID, source.Name FROM [Person].[11] AS source INNER JOIN [Person].[1123] AS main_source ON source.[112ID] = main_source.[112ID] ) AS main_source INNER JOIN [Person].[1123] AS source ON  source.PhoneNumberTypeID = main_source.PhoneNumberTypeID) pnt
    ON pp.[PhoneNumberTypeID] = pnt.[PhoneNumberTypeID]
    LEFT OUTER JOIN [Person].[EmailAddress] ea
    ON p.[BusinessEntityID] = ea.[BusinessEntityID];
GO
EXEC sp_addextendedproperty N'MS_Description', N'Employee names and addresses.', 'SCHEMA', N'HumanResources', 'VIEW', N'vEmployee', NULL, NULL
GO
