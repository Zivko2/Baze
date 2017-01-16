SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING OFF
GO
CREATE TABLE [dbo].[PERMISOGRAL] (
		[PE_CODIGO]          [int] NOT NULL,
		[PGR_APLICA]         [decimal](38, 6) NULL,
		[PGR_PESOSAF]        [decimal](38, 6) NULL,
		[PGR_TIPCAMAF]       [decimal](38, 6) NULL,
		[PGR_DOLARAF]        [decimal](38, 6) NULL,
		[PGR_PESOSME]        [decimal](38, 6) NULL,
		[PGR_TIPCAMME]       [decimal](38, 6) NULL,
		[PGR_DOLARME]        [decimal](38, 6) NULL,
		[PGR_PERIODO]        [decimal](38, 6) NULL,
		[PGR_NACIONAL]       [decimal](38, 6) NULL,
		[PGR_IMPOTEMP]       [decimal](38, 6) NULL,
		[PGR_NOEMPACT]       [decimal](38, 6) NULL,
		[PGR_NOOBRACT]       [decimal](38, 6) NULL,
		[PGR_NOADMACT]       [decimal](38, 6) NULL,
		[PGR_NOEMPFUT]       [decimal](38, 6) NULL,
		[PGR_NOOBRFUT]       [decimal](38, 6) NULL,
		[PGR_NOADMFUT]       [decimal](38, 6) NULL,
		[PGR_PORCNAL]        [decimal](38, 6) NULL,
		[PGR_TIPO_PROGR]     [smallint] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PERMISOGRAL]
	ADD
	CONSTRAINT [PK_PERMISOVENTAS]
	PRIMARY KEY
	NONCLUSTERED
	([PE_CODIGO])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_PERMISOGRAL]
	ON [dbo].[PERMISOGRAL] ([PE_CODIGO])
	WITH ( FILLFACTOR = 90)
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[PERMISOGRAL] SET (LOCK_ESCALATION = TABLE)
GO
