SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[CONTRIBUCION] (
		[CON_CODIGO]              [smallint] IDENTITY(1, 1) NOT NULL,
		[CON_CLAVE]               [varchar](5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CON_ABREVIA]             [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CON_DESC]                [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CON_NIVEL]               [varchar](5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CON_COMPLEMENTARIO]      [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CON_PORMENOSTASA]        [decimal](38, 6) NOT NULL,
		[CON_APLICACUOTAFIJA]     [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CON_VALORMINXDOC]        [decimal](38, 6) NULL,
		[CON_TIPO]                [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		CONSTRAINT [IX_CONTRIBUCION]
		UNIQUE
		NONCLUSTERED
		([CON_CODIGO])
		ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CONTRIBUCION]
	ADD
	CONSTRAINT [PK_CONTRIBUCIONES]
	PRIMARY KEY
	NONCLUSTERED
	([CON_CLAVE])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[CONTRIBUCION]
	ADD
	CONSTRAINT [DF_CONTRIBUCION_CON_ABREVIA]
	DEFAULT ('') FOR [CON_ABREVIA]
GO
ALTER TABLE [dbo].[CONTRIBUCION]
	ADD
	CONSTRAINT [DF_CONTRIBUCION_CON_COMPLEMENTARIO]
	DEFAULT ('N') FOR [CON_COMPLEMENTARIO]
GO
ALTER TABLE [dbo].[CONTRIBUCION]
	ADD
	CONSTRAINT [DF_CONTRIBUCION_CON_DESC]
	DEFAULT ('') FOR [CON_DESC]
GO
ALTER TABLE [dbo].[CONTRIBUCION]
	ADD
	CONSTRAINT [DF_CONTRIBUCION_CON_PORMENOSTASA]
	DEFAULT (0) FOR [CON_PORMENOSTASA]
GO
ALTER TABLE [dbo].[CONTRIBUCION]
	ADD
	CONSTRAINT [DF_CONTRIBUCION_CON_TIPO]
	DEFAULT ('N') FOR [CON_TIPO]
GO
