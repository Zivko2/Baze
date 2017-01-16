SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[REQUISICION] (
		[REQ_CODIGO]            [int] NOT NULL,
		[REQ_FOLIO]             [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[TR_CODIGO]             [int] NOT NULL,
		[TQ_CODIGO]             [smallint] NOT NULL,
		[REQ_FECHA]             [datetime] NOT NULL,
		[REQ_TIPOCAMBIO]        [decimal](38, 6) NULL,
		[PR_CODIGO]             [int] NOT NULL,
		[DI_CODIGO]             [int] NULL,
		[CO_PROVEE]             [int] NULL,
		[REQ_SEM]               [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[US_CODIGO]             [smallint] NULL,
		[CL_DESTINO]            [int] NULL,
		[DI_DESTINO]            [int] NULL,
		[CL_COMP]               [int] NULL,
		[DI_COMP]               [int] NULL,
		[CO_COMP]               [smallint] NULL,
		[REQ_COMENTA]           [varchar](1100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[REQ_TOTALB]            [decimal](38, 6) NULL,
		[REQ_ESTATUS]           [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[REQ_METODOENVIO]       [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[REQ_CANCELADO]         [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[MO_CODIGO]             [int] NULL,
		[REQ_FLETE]             [decimal](38, 6) NULL,
		[REQ_SEGURO]            [decimal](38, 6) NULL,
		[REQ_EMBALAJE]          [decimal](38, 6) NULL,
		[REQ_DESCUENTO]         [decimal](38, 6) NULL,
		[TE_CODIGO]             [smallint] NULL,
		[CL_CON_VEN]            [varchar](40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CL_LIMCRE]             [decimal](38, 6) NULL,
		[IT_CODIGO]             [int] NULL,
		[REQ_INCOTLUGAR]        [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[REQ_CANTLETRADL]       [varchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[REQ_CANTLETRAMN]       [varchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[REQ_CANTLETRADLIN]     [varchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[REQ_CANTLETRAMNIN]     [varchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[REQ_LISTAAPROBA]       [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[REQ_MULTIPROVEE]       [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[REQUISICION]
	ADD
	CONSTRAINT [PK_REQUISICION]
	PRIMARY KEY
	NONCLUSTERED
	([REQ_FOLIO])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[REQUISICION]
	ADD
	CONSTRAINT [DF_REQUISICION_REQ_CANCELADO]
	DEFAULT ('N') FOR [REQ_CANCELADO]
GO
ALTER TABLE [dbo].[REQUISICION]
	ADD
	CONSTRAINT [DF_REQUISICION_REQ_ESTATUS]
	DEFAULT ('E') FOR [REQ_ESTATUS]
GO
ALTER TABLE [dbo].[REQUISICION]
	ADD
	CONSTRAINT [DF_REQUISICION_REQ_LISTAAPROBA]
	DEFAULT ('N') FOR [REQ_LISTAAPROBA]
GO
ALTER TABLE [dbo].[REQUISICION]
	ADD
	CONSTRAINT [DF_REQUISICION_REQ_MULTIPROVEE]
	DEFAULT ('N') FOR [REQ_MULTIPROVEE]
GO
ALTER TABLE [dbo].[REQUISICION] SET (LOCK_ESCALATION = TABLE)
GO
