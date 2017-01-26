SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[PEDIDO] (
		[PD_CODIGO]            [int] NOT NULL,
		[PD_FOLIO]             [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[PD_FECHA]             [datetime] NOT NULL,
		[PD_TIPOCAMBIO]        [decimal](38, 6) NOT NULL,
		[CL_CODIGO]            [int] NOT NULL,
		[DI_CLIENTE]           [int] NULL,
		[CO_CODIGO]            [smallint] NULL,
		[CL_DESTINO]           [int] NOT NULL,
		[DI_DESTINO]           [int] NULL,
		[CO_DESTINO]           [smallint] NULL,
		[CL_VENDEDOR]          [int] NULL,
		[DI_VENDEDOR]          [int] NULL,
		[CO_VENDEDOR]          [int] NULL,
		[PD_TIPO]              [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[PD_ESTATUS]           [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[PD_TOTALB]            [decimal](38, 6) NULL,
		[US_CODIGO]            [int] NULL,
		[PD_COMENTA]           [varchar](1100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[PD_CANCELADO]         [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[PD_REFERENCIA]        [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[PD_METODOENVIO]       [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[PD_CUENTAMENSAJE]     [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[PD_NOGUIA]            [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[MO_CODIGO]            [int] NULL,
		[PD_FLETE]             [decimal](38, 6) NULL,
		[PD_SEGURO]            [decimal](38, 6) NULL,
		[PD_EMBALAJE]          [decimal](38, 6) NULL,
		[TE_CODIGO]            [smallint] NULL,
		[PD_CON_VEN]           [varchar](40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[PD_LIMCRE]            [decimal](38, 6) NULL,
		[IT_CODIGO]            [int] NULL,
		[PD_INCOTLUGAR]        [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[PD_CANTLETRADL]       [varchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[PD_CANTLETRAMN]       [varchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[PD_CANTLETRADLIN]     [varchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[PD_CANTLETRAMNIN]     [varchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[PD_SEM]               [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
