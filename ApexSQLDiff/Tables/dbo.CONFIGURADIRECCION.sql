SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[CONFIGURADIRECCION] (
		[CL_CODIGO]      [int] NOT NULL,
		[CL_SIMILAR]     [int] NOT NULL,
		[DI_INDICE]      [int] NOT NULL,
		[CDIR_TIPO]      [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CONFIGURADIRECCION]
	ADD
	CONSTRAINT [PK_CONFIGURADIRECCION]
	PRIMARY KEY
	NONCLUSTERED
	([CL_CODIGO], [CL_SIMILAR], [CDIR_TIPO])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[CONFIGURADIRECCION] SET (LOCK_ESCALATION = TABLE)
GO
