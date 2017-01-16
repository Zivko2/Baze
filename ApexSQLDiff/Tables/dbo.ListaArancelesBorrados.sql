SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ListaArancelesBorrados] (
		[ar_codigo]       [int] NOT NULL,
		[ar_fraccion]     [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ListaArancelesBorrados] SET (LOCK_ESCALATION = TABLE)
GO
