SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[KARDESPEDres] (
		[KAP_CODIGO]                [int] NOT NULL,
		[KAP_FACTRANS]              [int] NULL,
		[KAP_INDICED_FACT]          [int] NULL,
		[KAP_INDICED_PED]           [int] NULL,
		[MA_HIJO]                   [int] NULL,
		[KAP_TIPO_DESC]             [char](2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[KAP_ESTATUS]               [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[KAP_CANTDESC]              [float] NULL,
		[KAP_CantTotADescargar]     [float] NULL,
		[KAP_Saldo_FED]             [float] NULL,
		[KAP_PADRESUST]             [int] NULL,
		[KAP_CONTESTATUS]           [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[KAP_FISCOMP]               [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[KAP_PADREMAIN]             [int] NULL
) ON [PRIMARY]
GO
