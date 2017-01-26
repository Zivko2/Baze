SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[COTIZACION] (
		[COT_CODIGO]            [int] NOT NULL,
		[COT_FOLIO]             [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[COT_FECHA]             [datetime] NOT NULL,
		[COT_TIPOCAMBIO]        [decimal](38, 6) NOT NULL,
		[CL_CODIGO]             [int] NOT NULL,
		[DI_CLIENTE]            [int] NOT NULL,
		[CO_CODIGO]             [smallint] NULL,
		[CL_DESTINO]            [int] NOT NULL,
		[DI_DESTINO]            [int] NOT NULL,
		[CO_DESTINO]            [smallint] NULL,
		[CL_VENDEDOR]           [int] NULL,
		[DI_VENDEDOR]           [int] NULL,
		[CO_VENDEDOR]           [int] NULL,
		[COT_TIPO]              [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[COT_ESTATUS]           [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[COT_TOTALB]            [decimal](38, 6) NULL,
		[US_CODIGO]             [int] NULL,
		[COT_COMENTA]           [varchar](1100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[COT_CANCELADO]         [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[COT_REFERENCIA]        [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[COT_METODOENVIO]       [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[COT_CUENTAMENSAJE]     [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[COT_NOGUIA]            [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[MO_CODIGO]             [int] NULL,
		[COT_FLETE]             [decimal](38, 6) NULL,
		[COT_SEGURO]            [decimal](38, 6) NULL,
		[COT_EMBALAJE]          [decimal](38, 6) NULL,
		[TE_CODIGO]             [smallint] NULL,
		[COT_CON_VEN]           [varchar](40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[COT_LIMCRE]            [decimal](38, 6) NULL,
		[IT_CODIGO]             [int] NULL,
		[COT_INCOTLUGAR]        [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[COT_CANTLETRADL]       [varchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[COT_CANTLETRAMN]       [varchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[COT_CANTLETRADLIN]     [varchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[COT_CANTLETRAMNIN]     [varchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[COT_SEM]               [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[COT_VIGENTEFECHA]      [datetime] NULL,
		[COT_TIEMPOENTREGA]     [varchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[COT_PERGARANTIA]       [varchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[COT_CONDPRECIOS]       [varchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[COT_APROBADA]          [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[COTIZACION]
	ADD
	CONSTRAINT [PK_COTIZACION]
	PRIMARY KEY
	NONCLUSTERED
	([COT_FOLIO])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[COTIZACION]
	ADD
	CONSTRAINT [DF_COTIZACION_COT_APROBADA]
	DEFAULT ('N') FOR [COT_APROBADA]
GO
ALTER TABLE [dbo].[COTIZACION]
	ADD
	CONSTRAINT [DF_COTIZACION_COT_CANCELADO]
	DEFAULT ('N') FOR [COT_CANCELADO]
GO
ALTER TABLE [dbo].[COTIZACION]
	ADD
	CONSTRAINT [DF_COTIZACION_COT_ESTATUS]
	DEFAULT ('N') FOR [COT_ESTATUS]
GO
ALTER TABLE [dbo].[COTIZACION]
	ADD
	CONSTRAINT [DF_COTIZACION_COT_TIPO]
	DEFAULT ('X') FOR [COT_TIPO]
GO
