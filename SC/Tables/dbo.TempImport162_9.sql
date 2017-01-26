SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[TempImport162_9] (
		[FACTEXP9#FE_TIPO]               [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FACTEXP9#TQ_CODIGO]             [smallint] NULL,
		[FACTEXP9#TF_CODIGO]             [smallint] NULL,
		[FACTEXPDET9#FED_NOPARTEAUX]     [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FACTEXPDET9#FED_COS_TOT]        [float] NULL,
		[FACTEXP9#TN_CODIGO]             [smallint] NULL,
		[FACTEXP9#CL_DESTINI]            [int] NULL,
		[FACTEXP9#DI_DESTINI]            [int] NULL,
		[FACTEXP9#US_CODIGO]             [smallint] NULL,
		[FACTEXP9#FE_FECHA]              [datetime] NULL,
		[FACTEXP9#FE_FOLIO]              [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FACTEXP9#FE_CONT1_SELL]         [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FACTEXP9#FE_ORD_COMP]           [varchar](60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FACTEXP9#FE_TRAC_MX1]           [varchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FACTEXP9#FE_TRAC_US1]           [varchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FACTEXP9#FE_GUIA1]              [varchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FACTEXP9#FE_CONT1_US]           [varchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FACTEXP9#FE_LIM1]               [varchar](40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FACTEXP9#CT_COMPANY1]           [int] NULL,
		[FACTEXP9#FE_TRAC_CHO1]          [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FACTEXP9#FE_FIRMS]              [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FACTEXPDET9#FED_NOPARTE]        [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FACTEXPDET9#FED_CANT]           [float] NULL,
		[FACTEXPDET9#FED_CANTEMP]        [float] NULL,
		[FACTEXPDET9#MA_EMPAQUE]         [int] NULL,
		[Cod_11]                         [varchar](8000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Cod_15]                         [varchar](8000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Cod_20]                         [varchar](8000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Cod_0]                          [varchar](8000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
