SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[PlntExpSeccFiltro] (
		[PXSF_CODIGO]       [int] NOT NULL,
		[PXS_CODIGO]        [int] NOT NULL,
		[PXSF_CAMPO1]       [int] NOT NULL,
		[PXSF_CAMPO2]       [int] NOT NULL,
		[PXSF_OPERADOR]     [int] NOT NULL,
		[PXSF_IGUAL]        [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[PXSF_MIN]          [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[PXSF_MAX]          [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[PXSF_NULL]         [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PlntExpSeccFiltro]
	ADD
	CONSTRAINT [PK_PlntExpSeccFiltro]
	PRIMARY KEY
	NONCLUSTERED
	([PXSF_CODIGO])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[PlntExpSeccFiltro]
	ADD
	CONSTRAINT [DF_PlntExpSeccFiltro_PXSF_CAMPO2]
	DEFAULT (0) FOR [PXSF_CAMPO2]
GO
ALTER TABLE [dbo].[PlntExpSeccFiltro]
	ADD
	CONSTRAINT [DF_PlntExpSeccFiltro_PXSF_NULL]
	DEFAULT ('N') FOR [PXSF_NULL]
GO
ALTER TABLE [dbo].[PlntExpSeccFiltro] SET (LOCK_ESCALATION = TABLE)
GO
