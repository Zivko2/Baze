SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[LISTAEXP] (
		[LE_CODIGO]         [int] NOT NULL,
		[LE_FOLIO]          [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[LE_FECHA]          [datetime] NOT NULL,
		[CL_CODIGO]         [int] NOT NULL,
		[DI_CL]             [int] NULL,
		[LE_COMENTA]        [varchar](1100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LE_COMENTAUS]      [varchar](1100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LE_SEM]            [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LE_TOTALB]         [decimal](15, 8) NULL,
		[US_CODIGO]         [smallint] NULL,
		[TF_CODIGO]         [smallint] NOT NULL,
		[TQ_CODIGO]         [smallint] NOT NULL,
		[LE_ESTATUS]        [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LE_MOSTRARDIV]     [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CP_CODIGO]         [smallint] NULL,
		[CT_CODIGO]         [int] NULL,
		[LE_TRAC_MX]        [varchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LE_CONT_REG]       [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LE_USAPRECIO]      [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		CONSTRAINT [IX_LISTAEXP]
		UNIQUE
		NONCLUSTERED
		([LE_CODIGO])
		ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LISTAEXP]
	ADD
	CONSTRAINT [PK_LISTAEXP]
	PRIMARY KEY
	NONCLUSTERED
	([LE_FOLIO])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[LISTAEXP]
	ADD
	CONSTRAINT [DF_LISTAEXP_LE_ESTATUS]
	DEFAULT ('A') FOR [LE_ESTATUS]
GO
ALTER TABLE [dbo].[LISTAEXP]
	ADD
	CONSTRAINT [DF_LISTAEXP_LE_MOSTRARDIV]
	DEFAULT ('S') FOR [LE_MOSTRARDIV]
GO
ALTER TABLE [dbo].[LISTAEXP]
	ADD
	CONSTRAINT [DF_LISTAEXP_LE_USAPRECIO]
	DEFAULT ('S') FOR [LE_USAPRECIO]
GO
