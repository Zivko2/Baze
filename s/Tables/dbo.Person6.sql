-- Create Table Person6
Print 'Create Table Person6'
GO
CREATE TABLE [dbo].[Person6] (
		[BusinessEntityID]     [int] NULL,
		[NationalIDNumber]     [int] NULL,
		[JobTitle]             [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[BirthDate]            [varchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Gender]               [varchar](2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Contact]              ntext COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
