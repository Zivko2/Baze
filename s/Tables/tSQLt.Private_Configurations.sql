-- Create Table Private_Configurations
Print 'Create Table Private_Configurations'
GO
CREATE TABLE [tSQLt].[Private_Configurations] (
		[Name]      [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[Value]     [sql_variant] NULL
) ON [PRIMARY]
GO
-- Add Primary Key PK__Private___737584F72601DE6D to Private_Configurations
Print 'Add Primary Key PK__Private___737584F72601DE6D to Private_Configurations'
GO
ALTER TABLE [tSQLt].[Private_Configurations]
	ADD
	CONSTRAINT [PK__Private___737584F72601DE6D]
	PRIMARY KEY
	CLUSTERED
	([Name])
	ON [PRIMARY]
GO
