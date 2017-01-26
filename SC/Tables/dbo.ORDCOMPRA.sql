SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ORDCOMPRA] (
		[OR_CODIGO]              [int] NOT NULL,
		[OR_FOLIO]               [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[TR_CODIGO]              [int] NOT NULL,
		[TQ_CODIGO]              [smallint] NOT NULL,
		[OR_FECHA]               [datetime] NOT NULL,
		[OR_TIPOCAMBIO]          [decimal](38, 6) NULL,
		[PR_CODIGO]              [int] NOT NULL,
		[DI_CODIGO]              [int] NULL,
		[CO_PROVEE]              [int] NULL,
		[OR_SEM]                 [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[US_CODIGO]              [smallint] NULL,
		[CL_DESTINO]             [int] NULL,
		[DI_DESTINO]             [int] NULL,
		[CL_COMP]                [int] NULL,
		[DI_COMP]                [int] NULL,
		[CO_COMP]                [smallint] NULL,
		[OR_COMENTA]             [varchar](1100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[OR_TOTALB]              [decimal](38, 6) NULL,
		[OR_ESTATUS]             [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[OR_METODOENVIO]         [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[OR_CANCELADO]           [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[MO_CODIGO]              [int] NULL,
		[OR_FLETE]               [decimal](38, 6) NULL,
		[OR_SEGURO]              [decimal](38, 6) NULL,
		[OR_EMBALAJE]            [decimal](38, 6) NULL,
		[OR_DESCUENTO]           [decimal](38, 6) NULL,
		[TE_CODIGO]              [smallint] NULL,
		[CL_CON_VEN]             [varchar](40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CL_LIMCRE]              [decimal](38, 6) NULL,
		[IT_CODIGO]              [int] NULL,
		[OR_INCOTLUGAR]          [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[OR_CANTLETRADL]         [varchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[OR_CANTLETRAMN]         [varchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[OR_CANTLETRADLIN]       [varchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[OR_CANTLETRAMNIN]       [varchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[OT_FECHARECORDTRAB]     [datetime] NULL,
		CONSTRAINT [IX_ORDCOMPRA]
		UNIQUE
		NONCLUSTERED
		([OR_CODIGO])
		ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ORDCOMPRA]
	ADD
	CONSTRAINT [PK_ORDCOMPRA]
	PRIMARY KEY
	NONCLUSTERED
	([OR_FOLIO])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[ORDCOMPRA]
	ADD
	CONSTRAINT [DF_ORDCOMPRA_OR_CANCELADO]
	DEFAULT ('N') FOR [OR_CANCELADO]
GO
ALTER TABLE [dbo].[ORDCOMPRA]
	ADD
	CONSTRAINT [DF_ORDCOMPRA_OR_ESTATUS]
	DEFAULT ('E') FOR [OR_ESTATUS]
GO
