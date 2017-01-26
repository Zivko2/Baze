SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[pedimpconciliaDetContribucionTasa] (
		[Pedimento]            [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[RecordNum]            [int] NULL,
		[ContributionCode]     [varchar](8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[ContributionRate]     [decimal](38, 6) NULL,
		[RateType]             [varchar](2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
