-- Create Table Person5
Print 'Create Table Person5'
GO
CREATE TABLE [dbo].[Person5] (
		[BusinessEntityID]     [int] NULL,
		[NationalIDNumber]     [int] NULL,
		[JobTitle]             [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[BirthDate]            [varchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Gender]               [varchar](2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Contact]              text COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
