SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[BUSQUEDACAMPOS] (
		[BSC_CODIGO]          [int] NOT NULL,
		[BUS_CODIGO]          [int] NOT NULL,
		[BSC_TABLA]           [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IMF_CODIGO]          [int] NOT NULL,
		[BSC_SELECCION]       [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[BSC_AGRUPACION]      [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[BSC_DESCRIPCION]     [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[BUF_CODIGO]          [int] NOT NULL,
		[BSC_SECCION]         [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[BSC_LONGITUD]        [int] NOT NULL,
		[BSC_PROCSOLO]        [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[BSC_SQL]             [varchar](8000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[BUSQUEDACAMPOS]
	ADD
	CONSTRAINT [PK_BUSQUEDACAMPOS]
	PRIMARY KEY
	NONCLUSTERED
	([BSC_CODIGO])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[BUSQUEDACAMPOS]
	ADD
	CONSTRAINT [DF_BUSQUEDACAMPOS_BSC_LONGITUD]
	DEFAULT (20) FOR [BSC_LONGITUD]
GO
ALTER TABLE [dbo].[BUSQUEDACAMPOS]
	ADD
	CONSTRAINT [DF_BUSQUEDACAMPOS_BSC_PROCSOLO]
	DEFAULT ('N') FOR [BSC_PROCSOLO]
GO
ALTER TABLE [dbo].[BUSQUEDACAMPOS]
	ADD
	CONSTRAINT [DF_BUSQUEDACAMPOS_BSC_SECCION]
	DEFAULT ('D') FOR [BSC_SECCION]
GO
ALTER TABLE [dbo].[BUSQUEDACAMPOS]
	ADD
	CONSTRAINT [DF_BUSQUEDACAMPOS_BSC_SELECCION]
	DEFAULT ('S') FOR [BSC_SELECCION]
GO
ALTER TABLE [dbo].[BUSQUEDACAMPOS]
	ADD
	CONSTRAINT [DF_BUSQUEDACAMPOS_BSC_SQL]
	DEFAULT ('') FOR [BSC_SQL]
GO
ALTER TABLE [dbo].[BUSQUEDACAMPOS]
	ADD
	CONSTRAINT [DF_BUSQUEDACAMPOS_IMF_CODIGO]
	DEFAULT (0) FOR [IMF_CODIGO]
GO
