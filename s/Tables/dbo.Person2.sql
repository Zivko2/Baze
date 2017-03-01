-- Create Table Person2
Print 'Create Table Person2'
GO
CREATE TABLE [dbo].[Person2] (
		[id]              [int] NULL,
		[firstName]       [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[lastName]        [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[isAlive]         [bit] NULL,
		[age]             [int] NULL,
		[dateOfBirth]     [binary](8) NULL,
		[spouse]          [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
