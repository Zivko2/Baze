SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[DETCEROR] (
		[NEW_FOLIO]        [varchar](8000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CMP_FOLIO]        [varchar](8000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[NoParte]          [varchar](8000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CMP_CLASE]        [varchar](8000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CMP_FABRICA]      [varchar](8000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CMP_CRITERIO]     [varchar](8000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
