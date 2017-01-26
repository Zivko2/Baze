SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[INVENTARIOTEMP] (
		[PI_CODIGO]              [int] NULL,
		[NoPedimento]            [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FechaPedimento]         [datetime] NULL,
		[FechaPagoPedimento]     [datetime] NULL,
		[PID_saldoCANT]          [decimal](38, 6) NULL,
		[ME_CORTO]               [varchar](5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[PID_SALDOGEN]           [decimal](38, 6) NULL,
		[ME_GEN]                 [varchar](5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[PID_COS_UNI]            [decimal](38, 6) NULL,
		[AR_FRACCION]            [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[PID_POR_DEF]            [decimal](38, 6) NULL,
		[MA_CODIGO]              [int] NULL,
		[SE_CLAVE]               [varchar](5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[SPI_CLAVE]              [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[TI_CODIGO]              [int] NULL,
		[PID_NOPARTE]            [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[PID_DEF_TIP]            [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[PID_INPUTSCANT]         [decimal](38, 6) NULL,
		[PID_INPUTSGEN]          [decimal](38, 6) NULL,
		[PID_OUTPUTSCANT]        [decimal](38, 6) NULL,
		[PID_OUTPUTSGEN]         [decimal](38, 6) NULL,
		[CFT_TIPO]               [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FECHAINI]               [datetime] NULL,
		[FECHAFIN]               [datetime] NULL
) ON [PRIMARY]
GO
