SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[RECIBEMATDET] (
		[RC_CODIGO]           [int] NOT NULL,
		[RCD_INDICED]         [int] NOT NULL,
		[MA_CODIGO]           [int] NOT NULL,
		[RCD_NOPARTE]         [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[RCD_NOMBRE]          [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[RCD_NAME]            [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[RCD_CANT]            [decimal](38, 6) NOT NULL,
		[RCD_COS_UNI]         [decimal](38, 6) NOT NULL,
		[RCD_COS_TOT]         [decimal](38, 6) NOT NULL,
		[RCD_CAN_ALM]         [decimal](38, 6) NOT NULL,
		[ME_CODIGO]           [int] NOT NULL,
		[ME_ALM]              [int] NULL,
		[RCD_OBSERVA]         [varchar](1100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[EQ_ALM]              [decimal](28, 14) NOT NULL,
		[FI_CODIGO]           [int] NULL,
		[FI_FOLIO]            [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FID_INDICED]         [int] NULL,
		[CL_CODIGO]           [int] NULL,
		[RCD_NOORDEN]         [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[RCD_ORD_COMP]        [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[PD_FOLIO]            [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[OR_CODIGO]           [int] NULL,
		[ORD_INDICED]         [int] NULL,
		[RCD_FECHARECSAL]     [datetime] NULL,
		[ALMD_CODIGO]         [int] NULL,
		[MA_EMPAQUE]          [int] NULL,
		[RCD_CANTEMP]         [decimal](38, 6) NULL,
		[RCD_CANTREC]         [decimal](38, 6) NOT NULL,
		[RCD_LOTE]            [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[RCD_CANTINSP]        [decimal](38, 6) NOT NULL,
		[RCD_CANTRESTPO]      [decimal](38, 6) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[RECIBEMATDET]
	ADD
	CONSTRAINT [PK_RECIBEMATDET]
	PRIMARY KEY
	NONCLUSTERED
	([RCD_INDICED])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[RECIBEMATDET]
	ADD
	CONSTRAINT [DF_RECIBEMATDET_EQ_ALM]
	DEFAULT (1) FOR [EQ_ALM]
GO
ALTER TABLE [dbo].[RECIBEMATDET]
	ADD
	CONSTRAINT [DF_RECIBEMATDET_RCD_CANT]
	DEFAULT (0) FOR [RCD_CANT]
GO
ALTER TABLE [dbo].[RECIBEMATDET]
	ADD
	CONSTRAINT [DF_RECIBEMATDET_RCD_CANTEMP]
	DEFAULT (0) FOR [RCD_CANTEMP]
GO
ALTER TABLE [dbo].[RECIBEMATDET]
	ADD
	CONSTRAINT [DF_RECIBEMATDET_RCD_CANTINSP]
	DEFAULT (0) FOR [RCD_CANTINSP]
GO
ALTER TABLE [dbo].[RECIBEMATDET]
	ADD
	CONSTRAINT [DF_RECIBEMATDET_RCD_CANTREC]
	DEFAULT (0) FOR [RCD_CANTREC]
GO
ALTER TABLE [dbo].[RECIBEMATDET]
	ADD
	CONSTRAINT [DF_RECIBEMATDET_RCD_COS_UNI]
	DEFAULT (0) FOR [RCD_COS_UNI]
GO
