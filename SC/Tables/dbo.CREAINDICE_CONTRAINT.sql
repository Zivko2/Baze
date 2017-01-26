SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[CREAINDICE_CONTRAINT] (
		[IND_CODIGO]             [int] IDENTITY(1, 1) NOT NULL,
		[IND_ENUNCIADO]          [varchar](8000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IND_NOMBRE]             [varchar](800) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IND_TABLA]              [varchar](250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IND_COLUMNAS]           [varchar](8000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IND_UNIQUE]             [smallint] NULL,
		[IND_CLUSTERED]          [smallint] NULL,
		[IND_ENUNCIADOBORRA]     [varchar](8000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
