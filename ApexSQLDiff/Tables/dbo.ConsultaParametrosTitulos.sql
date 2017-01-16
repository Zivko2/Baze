SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ConsultaParametrosTitulos] (
		[CPAT_Codigo]     [int] IDENTITY(1, 1) NOT NULL,
		[CPA_Codigo]      [int] NOT NULL,
		[CPAT_Campo]      [varchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CPAT_Titulo]     [varchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		CONSTRAINT [IX_ConsultaParametrosTitulos]
		UNIQUE
		NONCLUSTERED
		([CPAT_Codigo])
		ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ConsultaParametrosTitulos]
	ADD
	CONSTRAINT [PK_ConsultaParametrosTitulos]
	PRIMARY KEY
	CLUSTERED
	([CPAT_Codigo])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[ConsultaParametrosTitulos] SET (LOCK_ESCALATION = TABLE)
GO
