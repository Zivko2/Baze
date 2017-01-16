SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[TempImport162_7] (
		[FACTEXP7#FE_TIPO]               [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FACTEXP7#TQ_CODIGO]             [smallint] NULL,
		[FACTEXP7#TF_CODIGO]             [smallint] NULL,
		[FACTEXPDET7#FED_NOPARTEAUX]     [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FACTEXPDET7#FED_COS_TOT]        [float] NULL,
		[FACTEXP7#FE_FOLIO]              [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FACTEXP7#FE_FECHA]              [datetime] NULL,
		[FACTEXPDET7#FED_NOPARTE]        [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FACTEXPDET7#FED_CANT]           [float] NULL,
		[Cod_3]                          [varchar](8000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TempImport162_7] SET (LOCK_ESCALATION = TABLE)
GO
