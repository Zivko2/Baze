SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ConsultaParametrosDet] (
		[CPAD_Codigo]       [int] IDENTITY(1, 1) NOT NULL,
		[CPA_Codigo]        [int] NOT NULL,
		[CPAD_Etiqueta]     [varchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CPAD_Tipo]         [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		CONSTRAINT [IX_ConsultaParametrosDet]
		UNIQUE
		NONCLUSTERED
		([CPAD_Codigo])
		ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ConsultaParametrosDet]
	ADD
	CONSTRAINT [PK_ConsultaParametrosDet]
	PRIMARY KEY
	CLUSTERED
	([CPAD_Codigo])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[ConsultaParametrosDet] SET (LOCK_ESCALATION = TABLE)
GO
