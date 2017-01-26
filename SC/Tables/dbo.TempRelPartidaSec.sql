SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[TempRelPartidaSec] (
		[PI_CODIGO]         [int] NULL,
		[GEMCO]             [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[ORDEN]             [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FACTURA]           [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[NOTA_PARTE]        [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[DESCRIPCION]       [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[NAFTA]             [varchar](2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[QTY_COM]           [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[PESO_NETO]         [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[VAL_COMERCIAL]     [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[PAIS_ORIGEN]       [varchar](5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[PAIS_FISICO]       [varchar](5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[PARTIDA]           [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FRACCION]          [varchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[UMC]               [varchar](2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[UMT]               [varchar](2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[ADV]               [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IVA]               [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[QTY_TARIFA]        [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[QTY_COMERCIAL]     [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[UMF]               [varchar](2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[PESO_UNIT]         [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
