SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [INSNT01\osolano].[KardespedUsuario27] (
		[KAP_CODIGO]                [int] NOT NULL,
		[KAP_INDICED_FACT]          [int] NULL,
		[KAP_INDICED_PED]           [int] NULL,
		[MA_HIJO]                   [int] NULL,
		[KAP_ESTATUS]               [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[KAP_CANTDESC]              [decimal](38, 6) NULL,
		[KAP_CantTotADescargar]     [decimal](38, 6) NULL,
		[KAP_Saldo_FED]             [decimal](38, 6) NULL,
		[KAP_PADRESUST]             [int] NULL
) ON [PRIMARY]
GO
