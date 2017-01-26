SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[SubtotalesIntrade] (
		[PI_MOVIMIENTO]      [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[AGT_PATENTE]        [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[PI_FOLIO]           [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[AD_CLAVE]           [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CP_CLAVE]           [varchar](5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[PI_RECTESTATUS]     [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[PI_RECTIFICA]       [int] NOT NULL,
		[PI_FEC_PAGR1]       [datetime] NULL,
		[Expr1]              [varchar](5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[PI_TIP_CAM]         [decimal](38, 6) NULL,
		[PI_FEC_ENT]         [datetime] NULL,
		[PI_FEC_PAG]         [datetime] NULL,
		[PID_VAL_ADU]        [decimal](38, 6) NULL,
		[ValorComercial]     [decimal](38, 6) NULL,
		[PID_CAN_GEN]        [decimal](38, 6) NULL,
		[CantUMT]            [decimal](38, 6) NULL,
		[Contribucion]       [decimal](38, 6) NULL,
		[ValorDlls]          [decimal](38, 6) NULL,
		[Planta]             [varchar](3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[EstatusGral]        [int] NOT NULL,
		[EstatusDetalle]     [int] NOT NULL,
		[PI_CODIGO]          [int] NOT NULL
) ON [PRIMARY]
GO
