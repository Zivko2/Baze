SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING OFF
GO
CREATE TABLE [HumanResources].[Employeej] (
		[BusinessEntityID]     [int] NOT NULL,
		[ModifiedDate]         [datetime] NOT NULL,
		CONSTRAINT [PK_Employeej]
		PRIMARY KEY
		CLUSTERED
		([BusinessEntityID])
	WITH (IGNORE_DUP_KEY = ON, ALLOW_ROW_LOCKS = OFF, ALLOW_PAGE_LOCKS = OFF)
	ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [HumanResources].[Employeej]
	ADD
	CONSTRAINT [DF_Employee_ModifiedDate_Employeej]
	DEFAULT (getdate()) FOR [ModifiedDate]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Default constraint value of GETDATE()', 'SCHEMA', N'HumanResources', 'TABLE', N'Employeej', 'CONSTRAINT', N'DF_Employee_ModifiedDate_Employeej'
GO
ALTER TABLE [HumanResources].[Employeej]
	WITH CHECK
	ADD CONSTRAINT [FK_Employee_Person_BusinessEntityID_Employeej]
	FOREIGN KEY ([BusinessEntityID]) REFERENCES [Person].[Person] ([BusinessEntityID])
ALTER TABLE [HumanResources].[Employeej]
	CHECK CONSTRAINT [FK_Employee_Person_BusinessEntityID_Employeej]

GO
EXEC sp_addextendedproperty N'MS_Description', N'Foreign key constraint referencing Person.BusinessEntityID.', 'SCHEMA', N'HumanResources', 'TABLE', N'Employeej', 'CONSTRAINT', N'FK_Employee_Person_BusinessEntityID_Employeej'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Primary key for Employee records.  Foreign key to BusinessEntity.BusinessEntityID.', 'SCHEMA', N'HumanResources', 'TABLE', N'Employeej', 'COLUMN', N'BusinessEntityID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the record was last updated.', 'SCHEMA', N'HumanResources', 'TABLE', N'Employeej', 'COLUMN', N'ModifiedDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Employee information such as salary, department, and title.', 'SCHEMA', N'HumanResources', 'TABLE', N'Employeej', NULL, NULL
GO
ALTER TABLE [HumanResources].[Employeej] SET (LOCK_ESCALATION = TABLE)
GO
