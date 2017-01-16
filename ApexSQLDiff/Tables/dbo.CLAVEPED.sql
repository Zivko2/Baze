SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[CLAVEPED] (
		[CP_CODIGO]          [smallint] IDENTITY(1, 1) NOT NULL,
		[CP_CLAVE]           [varchar](5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CP_NOMBRE]          [varchar](60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CP_DESC]            [varchar](1100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CP_TIPO]            [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CP_APLICACION]      [varchar](8000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CP_BASELEGAL]       [varchar](1100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CP_DESCARGABLE]     [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CP_CONSOLIDADO]     [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CP_ART303]          [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CP_TPAGOIGI]        [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CP_TPAGOCC]         [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CP_TPAGODTA]        [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CP_TPAGODTI]        [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CP_TPAGOIEPS]       [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CP_TPAGOISAN]       [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CP_TPAGOIVA]        [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CP_TPAGOREC]        [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CP_TPAGOBBS]        [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CP_TPAGOIGE]        [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CP_TPAGOCCE]        [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CP_TPAGODTAE]       [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CP_TPAGODTIE]       [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CP_TPAGOIEPSE]      [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CP_TPAGOISANE]      [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CP_TPAGOIVAE]       [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CP_TPAGORECE]       [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CP_TPAGOBBSE]       [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CP_PAGODTA]         [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CP_DESCARGO]        [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CP_USANAFTADTA]     [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[LDE_CODIGO]         [smallint] NULL,
		CONSTRAINT [IX_CLAVEPED]
		UNIQUE
		NONCLUSTERED
		([CP_CODIGO])
		ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CLAVEPED]
	ADD
	CONSTRAINT [PK_CLAVEPED]
	PRIMARY KEY
	NONCLUSTERED
	([CP_CLAVE])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[CLAVEPED]
	ADD
	CONSTRAINT [DF_CLAVEPED_CP_ART303]
	DEFAULT ('S') FOR [CP_ART303]
GO
ALTER TABLE [dbo].[CLAVEPED]
	ADD
	CONSTRAINT [DF_CLAVEPED_CP_CONSOLIDADO]
	DEFAULT ('N') FOR [CP_CONSOLIDADO]
GO
ALTER TABLE [dbo].[CLAVEPED]
	ADD
	CONSTRAINT [DF_CLAVEPED_CP_DESCARGABLE]
	DEFAULT ('N') FOR [CP_DESCARGABLE]
GO
ALTER TABLE [dbo].[CLAVEPED]
	ADD
	CONSTRAINT [DF_CLAVEPED_CP_DESCARGO]
	DEFAULT ('N') FOR [CP_DESCARGO]
GO
ALTER TABLE [dbo].[CLAVEPED]
	ADD
	CONSTRAINT [DF_CLAVEPED_CP_PAGODTA]
	DEFAULT ('C') FOR [CP_PAGODTA]
GO
ALTER TABLE [dbo].[CLAVEPED]
	ADD
	CONSTRAINT [DF_CLAVEPED_CP_USANAFTADTA]
	DEFAULT ('N') FOR [CP_USANAFTADTA]
GO
CREATE CLUSTERED INDEX [IX_CLAVEPED_1]
	ON [dbo].[CLAVEPED] ([CP_CODIGO], [CP_CLAVE])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[CLAVEPED] SET (LOCK_ESCALATION = TABLE)
GO
