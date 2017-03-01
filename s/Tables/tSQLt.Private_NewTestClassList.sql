-- Create Table Private_NewTestClassList
Print 'Create Table Private_NewTestClassList'
GO
CREATE TABLE [tSQLt].[Private_NewTestClassList] (
		[ClassName]     [nvarchar](450) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
-- Add Primary Key PK__Private___F8BF561A04E91502 to Private_NewTestClassList
Print 'Add Primary Key PK__Private___F8BF561A04E91502 to Private_NewTestClassList'
GO
ALTER TABLE [tSQLt].[Private_NewTestClassList]
	ADD
	CONSTRAINT [PK__Private___F8BF561A04E91502]
	PRIMARY KEY
	CLUSTERED
	([ClassName])
	ON [PRIMARY]
GO
