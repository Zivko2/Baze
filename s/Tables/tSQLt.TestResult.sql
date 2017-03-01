-- Create Table TestResult
Print 'Create Table TestResult'
GO
CREATE TABLE [tSQLt].[TestResult] (
		[Id]                [int] IDENTITY(1, 1) NOT NULL,
		[Class]             ntext COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[TestCase]          ntext COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[Name]              AS ((quotename([Class])+'.')+quotename([TestCase])),
		[TranName]          ntext COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[Result]            ntext COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Msg]               ntext COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[TestStartTime]     [datetime] NOT NULL,
		[TestEndTime]       [datetime] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
-- Add Primary Key PK__TestResu__3214EC0750211E18 to TestResult
Print 'Add Primary Key PK__TestResu__3214EC0750211E18 to TestResult'
GO
ALTER TABLE [tSQLt].[TestResult]
	ADD
	CONSTRAINT [PK__TestResu__3214EC0750211E18]
	PRIMARY KEY
	CLUSTERED
	([Id])
	ON [PRIMARY]
GO
-- Add Default Constraint DF:TestResult(TestStartTime) to TestResult
Print 'Add Default Constraint DF:TestResult(TestStartTime) to TestResult'
GO
ALTER TABLE [tSQLt].[TestResult]
	ADD
	CONSTRAINT [DF:TestResult(TestStartTime)]
	DEFAULT (getdate()) FOR [TestStartTime]
GO
