SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[TempImport141_7] (
		[MAESTRO7#MA_PESO_KG]        [float] NULL,
		[MAESTRO7#MA_TIP_ENS]        [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[MAESTRO7#PA_PROCEDE]        [int] NULL,
		[MAESTRO7#MA_NOPARTEAUX]     [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[MAESTRO7#MA_INV_GEN]        [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[MAESTRO7#MA_NOPARTE]        [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[MAESTRO7#TI_CODIGO]         [smallint] NULL,
		[MAESTRO7#MA_NOMBRE]         [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[MAESTRO7#MA_NAME]           [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[MAESTRO7#ME_COM]            [int] NULL,
		[MAESTRO7#PA_ORIGEN]         [int] NULL,
		[MAESTRO7#MA_GENERICO]       [int] NULL,
		[MAESTRO7#MA_PESO_LB]        [float] NULL,
		[MAESTRO7#AR_IMPFO]          [int] NULL,
		[MAESTRO7#AR_EXPFO]          [int] NULL,
		[MAESTRO7#AR_IMPMX]          [int] NULL,
		[MAESTRO7#AR_EXPMX]          [int] NULL,
		[Cod_5]                      [varchar](8000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Cod_6]                      [varchar](8000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Cod_7]                      [varchar](8000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Cod_10]                     [varchar](8000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Cod_11]                     [varchar](8000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TempImport141_7]
	ADD
	CONSTRAINT [DF__TempImpor__MAEST__5A30E500]
	DEFAULT ((0)) FOR [MAESTRO7#MA_PESO_KG]
GO
