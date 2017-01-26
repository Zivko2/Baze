SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[TempImport144_9] (
		[FACTIMPDET9#FID_PES_UNILB]      [float] NULL,
		[FACTEXPDET9#FED_COS_TOT]        [float] NULL,
		[FACTEXPDET9#FED_PES_UNI]        [float] NULL,
		[FACTEXPDET9#FED_PES_NET]        [float] NULL,
		[FACTEXP9#CL_COMP]               [int] NULL,
		[FACTEXP9#DI_COMP]               [int] NULL,
		[FACTEXPDET9#FED_NOPARTEAUX]     [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FACTEXP9#CL_DESTFIN]            [int] NULL,
		[FACTEXP9#DI_DESTFIN]            [int] NULL,
		[FACTEXP9#CP_CODIGO]             [smallint] NULL,
		[FACTEXP9#CL_DESTINI]            [int] NULL,
		[FACTEXP9#FE_TIPO]               [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FACTEXP9#TQ_CODIGO]             [smallint] NULL,
		[FACTEXPDET9#PA_CODIGO]          [int] NULL,
		[FACTIMPDET9#FID_DEF_TIP]        [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FACTIMP9#DI_COMP]               [int] NULL,
		[FACTIMP9#CP_CODIGO]             [smallint] NULL,
		[FACTIMP9#CL_EXP]                [int] NULL,
		[FACTIMP9#DI_EXP]                [int] NULL,
		[FACTIMP9#DI_PROD]               [int] NULL,
		[FACTIMP9#CL_COMP]               [int] NULL,
		[FACTEXPDET9#FED_DEF_TIP]        [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FACTIMP9#FI_TIPO]               [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FACTIMP9#TQ_CODIGO]             [smallint] NULL,
		[FACTIMPDET9#FID_NOPARTEAUX]     [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FACTIMP9#DI_VEND]               [int] NULL,
		[FACTEXP9#CL_VEND]               [int] NULL,
		[FACTEXP9#DI_VEND]               [int] NULL,
		[FACTEXP9#DI_IMP]                [int] NULL,
		[FACTEXP9#DI_COMPFIN]            [int] NULL,
		[FACTEXP9#SPI_CODIGO]            [smallint] NULL,
		[FACTEXP9#FE_COMENTA]            [varchar](1100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FACTEXP9#FE_PINICIAL]           [datetime] NULL,
		[FACTIMP9#TF_CODIGO]             [smallint] NULL,
		[FACTIMP9#PR_CODIGO]             [int] NULL,
		[FACTIMP9#DI_PROVEE]             [int] NULL,
		[FACTIMP9#CL_VEND]               [int] NULL,
		[FACTIMP9#CL_PROD]               [int] NULL,
		[FACTIMP9#SPI_CODIGO]            [smallint] NULL,
		[FACTEXP9#TF_CODIGO]             [smallint] NULL,
		[FACTEXP9#DI_DESTINI]            [int] NULL,
		[FACTEXP9#CL_IMP]                [int] NULL,
		[FACTEXP9#CL_COMPFIN]            [int] NULL,
		[FACTEXP9#FE_PFINAL]             [datetime] NULL,
		[FACTEXP9#US_CODIGO]             [smallint] NULL,
		[FACTEXPDET9#SPI_CODIGO]         [smallint] NULL,
		[FACTIMP9#FI_FOLIO]              [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FACTEXP9#FE_FOLIO]              [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FACTEXP9#FE_FECHA]              [datetime] NULL,
		[FACTIMP9#FI_FECHA]              [datetime] NULL,
		[FACTIMPDET9#FID_NOPARTE]        [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FACTEXPDET9#FED_NOPARTE]        [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FACTEXPDET9#FED_CANT]           [float] NULL,
		[FACTIMPDET9#FID_CANT_ST]        [float] NULL,
		[FACTEXPDET9#FED_PES_BRULB]      [float] NULL,
		[FACTEXPDET9#FED_PES_BRU]        [float] NULL,
		[FACTIMPDET9#FID_COS_UNI]        [float] NULL,
		[FACTEXPDET9#FED_OBSERVA]        [varchar](1100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FACTIMPDET9#FID_COS_TOT]        [float] NULL,
		[FACTEXPDET9#FED_FAC_NUM]        [varchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FACTIMPDET9#FID_PES_BRULB]      [float] NULL,
		[Cod_4]                          [varchar](8000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Cod_3]                          [varchar](8000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TempImport144_9]
	ADD
	CONSTRAINT [DF__TempImpor__FACTE__3CF48AB3]
	DEFAULT (0) FOR [FACTEXPDET9#FED_COS_TOT]
GO
ALTER TABLE [dbo].[TempImport144_9]
	ADD
	CONSTRAINT [DF__TempImpor__FACTE__3DE8AEEC]
	DEFAULT (0) FOR [FACTEXPDET9#FED_PES_UNI]
GO
ALTER TABLE [dbo].[TempImport144_9]
	ADD
	CONSTRAINT [DF__TempImpor__FACTE__3EDCD325]
	DEFAULT (0) FOR [FACTEXPDET9#FED_PES_NET]
GO
ALTER TABLE [dbo].[TempImport144_9]
	ADD
	CONSTRAINT [DF__TempImpor__FACTI__3C00667A]
	DEFAULT (0) FOR [FACTIMPDET9#FID_PES_UNILB]
GO
