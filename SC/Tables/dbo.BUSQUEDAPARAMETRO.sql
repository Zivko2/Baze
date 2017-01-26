SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[BUSQUEDAPARAMETRO] (
		[BUP_CODIGO]             [int] IDENTITY(1, 1) NOT NULL,
		[BUS_CODIGO]             [int] NOT NULL,
		[IMF_FIELD]              [int] NOT NULL,
		[BUP_LABELPARAMETRO]     [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[BUP_ORDEN]              [smallint] NOT NULL,
		[BUP_OPERADOR]           [varchar](8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[BUP_DISPLAYFIELDS]      [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[BUP_PROCSOLO]           [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		CONSTRAINT [IX_BUSQUEDAPARAMETRO]
		UNIQUE
		NONCLUSTERED
		([BUP_CODIGO])
		ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[BUSQUEDAPARAMETRO]
	ADD
	CONSTRAINT [PK_BUSQUEDAPARAMETRO]
	PRIMARY KEY
	NONCLUSTERED
	([BUS_CODIGO], [BUP_LABELPARAMETRO])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[BUSQUEDAPARAMETRO]
	ADD
	CONSTRAINT [DF_BUSQUEDAPARAMETRO_BUP_OPERADOR]
	DEFAULT ('=') FOR [BUP_OPERADOR]
GO
ALTER TABLE [dbo].[BUSQUEDAPARAMETRO]
	ADD
	CONSTRAINT [DF_BUSQUEDAPARAMETRO_BUP_PROCSOLO]
	DEFAULT ('N') FOR [BUP_PROCSOLO]
GO
