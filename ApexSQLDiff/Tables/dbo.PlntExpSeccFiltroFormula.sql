SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[PlntExpSeccFiltroFormula] (
		[PXFF_CODIGO]       [int] NOT NULL,
		[PXS_CODIGO]        [int] NOT NULL,
		[PXFF_FORMULA]      [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[PXFF_OPERADOR]     [int] NOT NULL,
		[PXFF_IGUAL]        [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[PXFF_MIN]          [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[PXFF_MAX]          [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[PXFF_NULL]         [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PlntExpSeccFiltroFormula]
	ADD
	CONSTRAINT [PK_PlntExpSeccFiltroFormula]
	PRIMARY KEY
	NONCLUSTERED
	([PXFF_CODIGO])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[PlntExpSeccFiltroFormula]
	ADD
	CONSTRAINT [DF_PlntExpSeccFiltroFormula_PXFF_NULL]
	DEFAULT ('N') FOR [PXFF_NULL]
GO
ALTER TABLE [dbo].[PlntExpSeccFiltroFormula] SET (LOCK_ESCALATION = TABLE)
GO
