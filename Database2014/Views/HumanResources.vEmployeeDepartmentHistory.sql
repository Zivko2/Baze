SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [HumanResources].[vEmployeeDepartmentHistory] 
AS 
SELECT 
    e.[BusinessEntityID] 
    ,p.[Title] 
    ,p.[FirstName] 
    ,p.[MiddleName] 
    ,p.[LastName] 
    ,p.[Suffix] 
    ,s.[Name] AS [Shift]
    ,d.[Name] AS [Department] 
    ,d.[GroupName] 
    ,edh.[StartDate] 
    ,edh.[EndDate]
FROM (SELECT main_source.BusinessEntityID, main_source.NationalIDNumber, main_source.LoginID, main_source.OrganizationNode, main_source.OrganizationLevel, main_source.JobTitle, main_source.BirthDate, main_source.MaritalStatus, main_source.Gender, main_source.HireDate, main_source.SalariedFlag, main_source.VacationHours, main_source.SickLeaveHours, main_source.CurrentFlag, main_source.rowguid, source.ModifiedDate FROM [HumanResources].[Employee] AS main_source INNER JOIN [HumanResources].[Employeej] AS source ON  source.BusinessEntityID = main_source.BusinessEntityID) e
	INNER JOIN [Person].[Person] p
	ON p.[BusinessEntityID] = e.[BusinessEntityID]
    INNER JOIN [HumanResources].[EmployeeDepartmentHistory] edh 
    ON e.[BusinessEntityID] = edh.[BusinessEntityID] 
    INNER JOIN [HumanResources].[Department] d 
    ON edh.[DepartmentID] = d.[DepartmentID] 
    INNER JOIN [HumanResources].[Shift] s
    ON s.[ShiftID] = edh.[ShiftID];
GO
EXEC sp_addextendedproperty N'MS_Description', N'Returns employee name and current and previous departments.', 'SCHEMA', N'HumanResources', 'VIEW', N'vEmployeeDepartmentHistory', NULL, NULL
GO
