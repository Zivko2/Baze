SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ESTADO] (
		[ES_CODIGO]       [int] IDENTITY(1, 1) NOT NULL,
		[PA_CODIGO]       [int] NOT NULL,
		[ES_CORTO]        [varchar](5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[ES_NOMBRE]       [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[ES_NAME]         [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[ES_ENTIDAD]      [varchar](5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[ES_CORTOUSA]     [varchar](5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		CONSTRAINT [IX_ESTADO]
		UNIQUE
		NONCLUSTERED
		([ES_CODIGO])
		ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ESTADO]
	ADD
	CONSTRAINT [PK_ESTADO]
	PRIMARY KEY
	NONCLUSTERED
	([PA_CODIGO], [ES_CORTO])
	ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [IX_ESTADO_1]
	ON [dbo].[ESTADO] ([ES_CODIGO], [ES_CORTO])
	ON [PRIMARY]
GO
