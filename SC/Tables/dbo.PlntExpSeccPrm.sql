SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[PlntExpSeccPrm] (
		[PXM_CODIGO]             [int] NOT NULL,
		[PXS_CODIGO]             [int] NOT NULL,
		[PXM_ORDEN]              [int] NOT NULL,
		[IMF_CODIGO]             [int] NOT NULL,
		[PXM_LABELPARAMETRO]     [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[PXM_OPERADOR]           [varchar](8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[PXM_DISPLAYFIELDS]      [varchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[PXM_TIPOPARAM]          [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[PXM_PROCSOLO]           [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PlntExpSeccPrm]
	ADD
	CONSTRAINT [DF_PlntExpSeccPrm_IMF_CODIGO]
	DEFAULT (0) FOR [IMF_CODIGO]
GO
ALTER TABLE [dbo].[PlntExpSeccPrm]
	ADD
	CONSTRAINT [DF_PlntExpSeccPrm_PXM_OPERADOR]
	DEFAULT ('=') FOR [PXM_OPERADOR]
GO
ALTER TABLE [dbo].[PlntExpSeccPrm]
	ADD
	CONSTRAINT [DF_PlntExpSeccPrm_PXM_ORDEN]
	DEFAULT (0) FOR [PXM_ORDEN]
GO
ALTER TABLE [dbo].[PlntExpSeccPrm]
	ADD
	CONSTRAINT [DF_PlntExpSeccPrm_PXM_PROCSOLO]
	DEFAULT ('N') FOR [PXM_PROCSOLO]
GO
ALTER TABLE [dbo].[PlntExpSeccPrm]
	ADD
	CONSTRAINT [DF_PlntExpSeccPrm_PXM_TIPOPARAM]
	DEFAULT ('U') FOR [PXM_TIPOPARAM]
GO
