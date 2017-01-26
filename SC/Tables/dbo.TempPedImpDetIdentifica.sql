SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[TempPedImpDetIdentifica] (
		[PIID_CODIGO]      [int] IDENTITY(1, 1) NOT NULL,
		[PIB_INDICEB]      [int] NOT NULL,
		[IDE_CODIGO]       [int] NOT NULL,
		[IDED_CODIGO]      [int] NULL,
		[PIID_DESC]        [varchar](40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[PIID_DESC2]       [varchar](40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[PIID_TIPO]        [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[IDED_CODIGO2]     [int] NULL,
		[IDED_CODIGO3]     [int] NULL,
		[PIID_DESC3]       [varchar](40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		CONSTRAINT [IX_TempPedImpDetIdentifica]
		UNIQUE
		NONCLUSTERED
		([PIID_CODIGO])
		ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TempPedImpDetIdentifica]
	ADD
	CONSTRAINT [DF_TempPedImpDetIdentifica_PIID_DESC]
	DEFAULT ('') FOR [PIID_DESC]
GO
ALTER TABLE [dbo].[TempPedImpDetIdentifica]
	ADD
	CONSTRAINT [DF_TempPedImpDetIdentifica_PIID_TIPO]
	DEFAULT ('N') FOR [PIID_TIPO]
GO
