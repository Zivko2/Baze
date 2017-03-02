SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[CONFIGURASELDOC] (
		[IMT_CODIGO]        [int] NULL,
		[IMF_CODIGO]        [int] NULL,
		[CFS_CAMPO]         [varchar](60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CFS_FILTRO]        [varchar](60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CFS_SECUENCIA]     [int] NULL
) ON [PRIMARY]
GO