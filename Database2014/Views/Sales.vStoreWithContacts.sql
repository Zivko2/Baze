SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- Alter View vStoreWithContacts
-- Alter View vStoreWithContacts
-- Alter View vStoreWithContacts

CREATE VIEW [Sales].[vStoreWithContacts] AS 
SELECT 
    s.[BusinessEntityID] 
    ,s.[Name] 
    ,ct.[Name] AS [ContactType] 
    ,p.[Title] 
    ,p.[FirstName] 
    ,p.[MiddleName] 
    ,p.[LastName] 
    ,p.[Suffix] 
    ,pp.[PhoneNumber] 
	,pnt.[Name] AS [PhoneNumberType]
    ,ea.EmailAddressss AS EmailAddress 
    ,p.[EmailPromotion] 
FROM [Sales].[Store] s
    INNER JOIN [Person].[BusinessEntityContact] bec 
    ON bec.[BusinessEntityID] = s.[BusinessEntityID]
	INNER JOIN [Person].[ContactType] ct
	ON ct.[ContactTypeID] = bec.[ContactTypeID]
	INNER JOIN [Person].[Person] p
	ON p.[BusinessEntityID] = bec.[PersonID]
	LEFT OUTER JOIN [Person].[EmailAddress] ea
	ON ea.[BusinessEntityID] = p.[BusinessEntityID]
	LEFT OUTER JOIN ( SELECT source.BusinessEntityID, source.PhoneNumber, main_source.PhoneNumberTypeID AS PhoneNumberTypeID, source.ModifiedDate, source.PersonPhoneID FROM [Person].[PersonPhone] AS source INNER JOIN [Person].[1123] AS main_source ON source.[112ID] = main_source.[112ID] ) pp
	ON pp.[BusinessEntityID] = p.[BusinessEntityID]
	LEFT OUTER JOIN (SELECT main_source.PhoneNumberTypeID, main_source.Name, source.ModifiedDate FROM ( SELECT main_source.PhoneNumberTypeID AS PhoneNumberTypeID, source.Name FROM [Person].[11] AS source INNER JOIN [Person].[1123] AS main_source ON source.[112ID] = main_source.[112ID] ) AS main_source INNER JOIN [Person].[1123] AS source ON  source.PhoneNumberTypeID = main_source.PhoneNumberTypeID) pnt
	ON pnt.[PhoneNumberTypeID] = pp.[PhoneNumberTypeID];
GO
EXEC sp_addextendedproperty N'MS_Description', N'Stores (including store contacts) that sell Adventure Works Cycles products to consumers.', 'SCHEMA', N'Sales', 'VIEW', N'vStoreWithContacts', NULL, NULL
GO
