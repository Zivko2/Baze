-- Create Table Run_LastExecution
Print 'Create Table Run_LastExecution'
GO
CREATE TABLE [tSQLt].[Run_LastExecution] (
		[TestName]      ntext COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[SessionId]     [int] NULL,
		[LoginTime]     [datetime] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
