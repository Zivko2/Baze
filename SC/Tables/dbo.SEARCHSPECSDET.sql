SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[SEARCHSPECSDET] (
		[SS_CODIGO]            [int] NOT NULL,
		[SSD_CODIGO]           [int] NOT NULL,
		[SSD_IGUAL]            [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[SSD_IGUALCODIGO]      [int] NULL,
		[SSD_IGUALCOMBO]       [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[SSD_MENOR]            [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[SSD_MENORCODIGO]      [int] NULL,
		[SSD_MENORCOMBO]       [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[SSD_MAYOR]            [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[SSD_MAYORCODIGO]      [int] NULL,
		[SSD_MAYORCOMBO]       [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[SSD_TIPOBUSQUEDA]     [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[SSD_CAMPO]            [varchar](60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[SSD_OPERADOR]         [smallint] NULL,
		[SSD_SEPARECE]         [varchar](60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[SSD_NULO]             [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[SEARCHSPECSDET]
	ADD
	CONSTRAINT [PK_SEARCHSPECSDET]
	PRIMARY KEY
	NONCLUSTERED
	([SSD_CODIGO])
	ON [PRIMARY]
GO
