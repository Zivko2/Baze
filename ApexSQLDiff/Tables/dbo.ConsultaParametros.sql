SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ConsultaParametros] (
		[CPA_Codigo]           [int] IDENTITY(1, 1) NOT NULL,
		[CPA_Descripcion]      [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CPA_SQL]              [varchar](4000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CPA_TipoBusqueda]     [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		CONSTRAINT [IX_ConsultaParametros]
		UNIQUE
		NONCLUSTERED
		([CPA_Codigo])
		ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ConsultaParametros]
	ADD
	CONSTRAINT [PK_ConsultaParametros]
	PRIMARY KEY
	CLUSTERED
	([CPA_Codigo])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[ConsultaParametros] SET (LOCK_ESCALATION = TABLE)
GO
