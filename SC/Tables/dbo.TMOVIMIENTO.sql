SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[TMOVIMIENTO] (
		[TM_CODIGO]           [int] IDENTITY(1, 1) NOT NULL,
		[TM_NOMBRE]           [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[TM_NAME]             [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[TM_TIPO]             [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[TM_ALMACENES]        [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[TM_HABADICIONAL]     [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[ALM_ORIGEN]          [int] NULL,
		[ALM_DESTINO]         [int] NULL,
		[TM_ACTIVO]           [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[TM_SISTEMA]          [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		CONSTRAINT [IX_TMOVIMIENTO]
		UNIQUE
		NONCLUSTERED
		([TM_CODIGO])
		ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TMOVIMIENTO]
	ADD
	CONSTRAINT [PK_TMOVIMIENTO]
	PRIMARY KEY
	NONCLUSTERED
	([TM_NOMBRE])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[TMOVIMIENTO]
	ADD
	CONSTRAINT [DF_TMOVIMIENTO_TM_ACTIVO]
	DEFAULT ('S') FOR [TM_ACTIVO]
GO
ALTER TABLE [dbo].[TMOVIMIENTO]
	ADD
	CONSTRAINT [DF_TMOVIMIENTO_TM_ALMACENES]
	DEFAULT ('A') FOR [TM_ALMACENES]
GO
ALTER TABLE [dbo].[TMOVIMIENTO]
	ADD
	CONSTRAINT [DF_TMOVIMIENTO_TM_HABADICIONAL]
	DEFAULT ('S') FOR [TM_HABADICIONAL]
GO
ALTER TABLE [dbo].[TMOVIMIENTO]
	ADD
	CONSTRAINT [DF_TMOVIMIENTO_TM_SISTEMA]
	DEFAULT ('N') FOR [TM_SISTEMA]
GO
ALTER TABLE [dbo].[TMOVIMIENTO]
	ADD
	CONSTRAINT [DF_TMOVIMIENTO_TM_TIPO]
	DEFAULT ('A') FOR [TM_TIPO]
GO
