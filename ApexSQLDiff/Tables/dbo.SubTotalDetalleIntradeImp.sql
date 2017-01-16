SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[SubTotalDetalleIntradeImp] (
		[AGT_PATENTE]        [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[PI_FOLIO]           [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Aduana]             [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CP_CLAVE]           [varchar](5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[PI_RECTESTATUS]     [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[PI_TIP_CAM]         [decimal](38, 6) NULL,
		[PI_FEC_ENT]         [datetime] NULL,
		[PI_FEC_PAG]         [datetime] NULL,
		[PID_SECUENCIA]      [int] NULL,
		[AR_FRACCION]        [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[PA_SAAIM3]          [varchar](5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[PID_VAL_ADU]        [decimal](38, 6) NULL,
		[ValorComercial]     [decimal](38, 6) NULL,
		[PID_CAN_GEN]        [decimal](38, 6) NULL,
		[UMGen]              [varchar](5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CantUMT]            [decimal](38, 6) NULL,
		[UMTarifa]           [varchar](5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Contribucion]       [decimal](38, 6) NULL,
		[ValorDlls]          [decimal](38, 6) NULL,
		[Planta]             [varchar](3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[EstatusGral]        [int] NULL,
		[EstatusDetalle]     [int] NULL,
		[PI_CODIGO]          [int] NULL,
		[PID_DEF_TIP]        [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[PID_SEC_IMP]        [smallint] NULL,
		[PID_POR_DEF]        [decimal](38, 6) NULL,
		[PG_CODIGO]          [smallint] NULL,
		[PG_CLAVEM3]         [varchar](5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[SubTotalDetalleIntradeImp] SET (LOCK_ESCALATION = TABLE)
GO
