-- Create Table Private_RenamedObjectLog
Print 'Create Table Private_RenamedObjectLog'
GO
CREATE TABLE [tSQLt].[Private_RenamedObjectLog] (
		[Id]               [int] IDENTITY(1, 1) NOT NULL,
		[ObjectId]         [int] NOT NULL,
		[OriginalName]     ntext COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
-- Add Primary Key PK__Private_RenamedObjectLog__Id to Private_RenamedObjectLog
Print 'Add Primary Key PK__Private_RenamedObjectLog__Id to Private_RenamedObjectLog'
GO
ALTER TABLE [tSQLt].[Private_RenamedObjectLog]
	ADD
	CONSTRAINT [PK__Private_RenamedObjectLog__Id]
	PRIMARY KEY
	CLUSTERED
	([Id])
	ON [PRIMARY]
GO
