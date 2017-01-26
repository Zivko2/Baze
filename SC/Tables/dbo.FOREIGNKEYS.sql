SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[FOREIGNKEYS] (
		[IFK_CODIGO]                 [int] IDENTITY(1, 1) NOT NULL,
		[IFK_TABLAFUENTE]            [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[IFK_CAMPOFUENTE]            [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[IFK_TABLADESTINO]           [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[IFK_CAMPODESTINO]           [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[IFK_CAMPOENTERO]            [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[IFK_TABLADESTNOMBRE]        [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IFK_TABLADESTNAME]          [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IFK_CAMPODESTINONOMBRE]     [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IFK_CAMPODESTINONAME]       [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		CONSTRAINT [IX_FOREIGNKEYS]
		UNIQUE
		NONCLUSTERED
		([IFK_CODIGO])
		ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FOREIGNKEYS]
	ADD
	CONSTRAINT [PK_FOREIGNKEYS]
	PRIMARY KEY
	NONCLUSTERED
	([IFK_TABLADESTINO], [IFK_CAMPODESTINO])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[FOREIGNKEYS]
	ADD
	CONSTRAINT [DF_FOREIGNKEYS_IFK_CAMPOENTERO]
	DEFAULT ('S') FOR [IFK_CAMPOENTERO]
GO
CREATE CLUSTERED INDEX [IX_FOREIGNKEYS_1]
	ON [dbo].[FOREIGNKEYS] ([IFK_CAMPOFUENTE], [IFK_TABLAFUENTE])
	ON [PRIMARY]
GO
