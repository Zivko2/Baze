SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[TempImport144_7] (
		[FACTIMPDET7#FID_PES_UNILB]      [float] NULL,
		[FACTIMP7#DI_COMP]               [int] NULL,
		[FACTIMP7#TF_CODIGO]             [smallint] NULL,
		[FACTIMP7#SPI_CODIGO]            [smallint] NULL,
		[FACTIMP7#CL_VEND]               [int] NULL,
		[FACTIMP7#DI_VEND]               [int] NULL,
		[FACTIMP7#CL_EXP]                [int] NULL,
		[FACTIMP7#DI_EXP]                [int] NULL,
		[FACTIMP7#CP_CODIGO]             [smallint] NULL,
		[FACTIMP7#FI_TIPO]               [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FACTIMPDET7#FID_NOPARTEAUX]     [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FACTIMPDET7#FID_DEF_TIP]        [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FACTIMP7#PR_CODIGO]             [int] NULL,
		[FACTIMP7#DI_PROVEE]             [int] NULL,
		[FACTIMP7#TQ_CODIGO]             [smallint] NULL,
		[FACTIMP7#CL_PROD]               [int] NULL,
		[FACTIMP7#DI_PROD]               [int] NULL,
		[FACTIMP7#CL_COMP]               [int] NULL,
		[FACTIMP7#FI_FOLIO]              [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FACTIMP7#FI_FECHA]              [datetime] NULL,
		[FACTIMPDET7#FID_NOPARTE]        [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FACTIMPDET7#FID_CANT_ST]        [float] NULL,
		[FACTIMPDET7#FID_COS_UNI]        [float] NULL,
		[FACTIMPDET7#FID_COS_TOT]        [float] NULL,
		[FACTIMPDET7#FID_PES_BRULB]      [float] NULL,
		[Cod_3]                          [varchar](8000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TempImport144_7]
	ADD
	CONSTRAINT [DF__TempImpor__FACTI__0F2304D5]
	DEFAULT ((0)) FOR [FACTIMPDET7#FID_PES_UNILB]
GO
