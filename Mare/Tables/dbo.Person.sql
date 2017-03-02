SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Person] (
		[id]              [int] NULL,
		[firstName]       [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[lastName]        [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[isAlive]         [bit] NULL,
		[age]             [int] NULL,
		[dateOfBirth]     [binary](8) NULL,
		[spouse]          [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[dhddh]           [int] NULL
) ON [PRIMARY]
GO
