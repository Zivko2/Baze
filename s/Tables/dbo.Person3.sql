-- Create Table Person3
Print 'Create Table Person3'
GO
CREATE TABLE [dbo].[Person3] (
		[BusinessEntityID]     [int] NULL,
		[NationalIDNumber]     [int] NULL,
		[JobTitle]             [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[BirthDate]            [varchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Gender]               [varchar](2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Contact]              [varchar](4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
