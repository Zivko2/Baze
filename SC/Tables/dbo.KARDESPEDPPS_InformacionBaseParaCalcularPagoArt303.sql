SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[KARDESPEDPPS_InformacionBaseParaCalcularPagoArt303] (
		[KAP_CODIGO]            [int] NOT NULL,
		[KAP_TASAFINAL]         [decimal](38, 6) NOT NULL,
		[KAP_DEF_TIP]           [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[KAP_SECIMP]            [int] NULL,
		[SPI_CODIGO]            [int] NULL,
		[KAP_COSTOUNITACT]      [decimal](38, 6) NULL,
		[KAP_FT_ACT]            [decimal](38, 6) NULL,
		[KAP_PEDIMENTO]         [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[KAP_FECHAPED]          [datetime] NULL,
		[KAP_TIP_CAM]           [decimal](38, 6) NOT NULL,
		[KAP_SALDOAFECTADO]     [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[PedExp_codigo]         [int] NULL
) ON [PRIMARY]
GO
