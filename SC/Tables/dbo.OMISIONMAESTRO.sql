SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[OMISIONMAESTRO] (
		[MA_INV_GEN]        [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CS_CODIGO]         [smallint] NULL,
		[MA_TIP_ENS]        [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CM_CODIGO]         [smallint] NULL,
		[ME_COM]            [int] NULL,
		[ME_ALM]            [int] NULL,
		[PA_ORIGEN]         [int] NULL,
		[PA_PROCEDE]        [int] NULL,
		[MA_MARCA]          [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[MA_COLOR]          [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[MA_MODELO]         [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CX_CODIGO]         [smallint] NULL,
		[MA_TALLA]          [varchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[MA_ESTILO]         [varchar](40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[EM_CODIGO]         [int] NOT NULL,
		[SE_CODIGO]         [smallint] NULL,
		[MA_GENERA_EMP]     [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[MA_EMPAQUE]        [int] NULL,
		[MA_CANTEMP]        [decimal](38, 6) NULL,
		[CFT_TIPO]          [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[TCO_CODIGO]        [smallint] NULL,
		[AR_IMPMX]          [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[OMISIONMAESTRO]
	ADD
	CONSTRAINT [PK_OMISIONMAESTRO]
	PRIMARY KEY
	NONCLUSTERED
	([MA_INV_GEN], [CFT_TIPO])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[OMISIONMAESTRO]
	ADD
	CONSTRAINT [DF_OMISIONMAESTRO_MA_GENERA_EMP]
	DEFAULT ('D') FOR [MA_GENERA_EMP]
GO
ALTER TABLE [dbo].[OMISIONMAESTRO]
	ADD
	CONSTRAINT [DF_OMISIONMAESTRO_MA_TIP_ENS]
	DEFAULT ('C') FOR [MA_TIP_ENS]
GO
