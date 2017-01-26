SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[TempPedImpIdentifica] (
		[PII_CODIGO]       [int] IDENTITY(1, 1) NOT NULL,
		[PI_CODIGO]        [int] NOT NULL,
		[IDE_CODIGO]       [int] NOT NULL,
		[IDED_CODIGO]      [int] NULL,
		[PII_DESC]         [varchar](40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[PII_DESC2]        [varchar](40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IDED_CODIGO2]     [int] NULL,
		[IDED_CODIGO3]     [int] NULL,
		[PII_DESC3]        [varchar](40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		CONSTRAINT [IX_TempPedImpIdentifica]
		UNIQUE
		NONCLUSTERED
		([PII_CODIGO])
		ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TempPedImpIdentifica]
	ADD
	CONSTRAINT [DF_TempPedImpIdentifica_PII_DESC]
	DEFAULT ('') FOR [PII_DESC]
GO
