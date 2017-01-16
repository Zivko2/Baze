SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- Create Procedure uspGetEmployeeManagers

CREATE PROCEDURE [dbo].[uspGet_Employee_Managers]
    @BusinessEntityID [int]
AS
BEGIN
    SET NOCOUNT ON;

    -- Use recursive query to list out all Employees required for a particular Manager
    WITH [EMP_cte]([BusinessEntityID], [OrganizationNode], [FirstName], [LastName], [JobTitle], [RecursionLevel]) -- CTE name and columns
    AS (
        SELECT e.[BusinessEntityID], e.[OrganizationNode], p.[FirstName], p.[LastName], e.[JobTitle], 0 -- Get the initial Employee
        FROM (SELECT main_source.BusinessEntityID, main_source.NationalIDNumber, main_source.LoginID, main_source.OrganizationNode, main_source.OrganizationLevel, main_source.JobTitle, main_source.BirthDate, main_source.MaritalStatus, main_source.Gender, main_source.HireDate, main_source.SalariedFlag, main_source.VacationHours, main_source.SickLeaveHours, main_source.CurrentFlag, main_source.rowguid, source.ModifiedDate FROM [HumanResources].[Employee] AS main_source INNER JOIN [HumanResources].[Employeej] AS source ON  source.BusinessEntityID = main_source.BusinessEntityID) e 
			INNER JOIN [Person].[Person] as p
			ON p.[BusinessEntityID] = e.[BusinessEntityID]
        WHERE e.[BusinessEntityID] = @BusinessEntityID
        UNION ALL
        SELECT e.[BusinessEntityID], e.[OrganizationNode], p.[FirstName], p.[LastName], e.[JobTitle], [RecursionLevel] + 1 -- Join recursive member to anchor
        FROM (SELECT main_source.BusinessEntityID, main_source.NationalIDNumber, main_source.LoginID, main_source.OrganizationNode, main_source.OrganizationLevel, main_source.JobTitle, main_source.BirthDate, main_source.MaritalStatus, main_source.Gender, main_source.HireDate, main_source.SalariedFlag, main_source.VacationHours, main_source.SickLeaveHours, main_source.CurrentFlag, main_source.rowguid, source.ModifiedDate FROM [HumanResources].[Employee] AS main_source INNER JOIN [HumanResources].[Employeej] AS source ON  source.BusinessEntityID = main_source.BusinessEntityID) e 
            INNER JOIN [EMP_cte]
            ON e.[OrganizationNode] = [EMP_cte].[OrganizationNode].GetAncestor(1)
            INNER JOIN [Person].[Person] p 
            ON p.[BusinessEntityID] = e.[BusinessEntityID]
    )
    -- Join back to Employee to return the manager name 
    SELECT [EMP_cte].[RecursionLevel], [EMP_cte].[BusinessEntityID], [EMP_cte].[FirstName], [EMP_cte].[LastName], 
        [EMP_cte].[OrganizationNode].ToString() AS [OrganizationNode], p.[FirstName] AS 'ManagerFirstName', p.[LastName] AS 'ManagerLastName'  -- Outer select from the CTE
    FROM [EMP_cte] 
        INNER JOIN (SELECT main_source.BusinessEntityID, main_source.NationalIDNumber, main_source.LoginID, main_source.OrganizationNode, main_source.OrganizationLevel, main_source.JobTitle, main_source.BirthDate, main_source.MaritalStatus, main_source.Gender, main_source.HireDate, main_source.SalariedFlag, main_source.VacationHours, main_source.SickLeaveHours, main_source.CurrentFlag, main_source.rowguid, source.ModifiedDate FROM [HumanResources].[Employee] AS main_source INNER JOIN [HumanResources].[Employeej] AS source ON  source.BusinessEntityID = main_source.BusinessEntityID) e 
        ON [EMP_cte].[OrganizationNode].GetAncestor(1) = e.[OrganizationNode]
        INNER JOIN [Person].[Person] p 
        ON p.[BusinessEntityID] = e.[BusinessEntityID]
    ORDER BY [RecursionLevel], [EMP_cte].[OrganizationNode].ToString()
    OPTION (MAXRECURSION 25) 
END;
GO
EXEC sp_addextendedproperty N'MS_Description', N'Stored procedure using a recursive query to return the direct and indirect managers of the specified employee.', 'SCHEMA', N'dbo', 'PROCEDURE', N'uspGet_Employee_Managers', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Input parameter for the stored procedure uspGetEmployeeManagers. Enter a valid BusinessEntityID from the HumanResources.Employee table.', 'SCHEMA', N'dbo', 'PROCEDURE', N'uspGet_Employee_Managers', 'PARAMETER', N'@BusinessEntityID'
GO
