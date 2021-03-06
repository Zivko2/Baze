SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[IMPORTSPECDET] (
		[IMD_CODIGO]                [int] NOT NULL,
		[IMS_CODIGO]                [int] NOT NULL,
		[IMS_CBFORMA]               [int] NULL,
		[IMD_IMPORTAR]              [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[IMD_CAMPO_ORIGEN]          [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IMD_TIPO_ORIGEN]           [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IMD_POSINICIAL_ORIGEN]     [smallint] NULL,
		[IMD_LONGITUD_ORIGEN]       [smallint] NULL,
		[IMF_CODIGO]                [int] NOT NULL,
		[IMD_DEFAULT]               [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IMD_DEFAULT_CODE]          [int] NULL,
		[IMD_DEFAULTCHAR]           [varchar](5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IMD_ESCODIGO]              [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[IMD_MOSTRAR]               [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[IMD_NUMCOLUMNA]            [smallint] NOT NULL,
		[IMD_CAMPOTEXTO]            [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IMD_CALCULADO]             [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[IMD_CALCULOFORMULA]        [varchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IMD_AGRUP]                 [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[IMPORTSPECDET]
	ADD
	CONSTRAINT [DF_IMPORTSPECDET_IMD_CALCULADO]
	DEFAULT ('N') FOR [IMD_CALCULADO]
GO
ALTER TABLE [dbo].[IMPORTSPECDET]
	ADD
	CONSTRAINT [DF_IMPORTSPECDET_IMD_CODIGO]
	DEFAULT (0) FOR [IMD_CODIGO]
GO
ALTER TABLE [dbo].[IMPORTSPECDET]
	ADD
	CONSTRAINT [DF_IMPORTSPECDET_IMD_ESCODIGO]
	DEFAULT ('N') FOR [IMD_ESCODIGO]
GO
ALTER TABLE [dbo].[IMPORTSPECDET]
	ADD
	CONSTRAINT [DF_IMPORTSPECDET_IMD_IMPORTAR]
	DEFAULT ('S') FOR [IMD_IMPORTAR]
GO
ALTER TABLE [dbo].[IMPORTSPECDET]
	ADD
	CONSTRAINT [DF_IMPORTSPECDET_IMD_MOSTRAR]
	DEFAULT ('S') FOR [IMD_MOSTRAR]
GO
ALTER TABLE [dbo].[IMPORTSPECDET]
	ADD
	CONSTRAINT [DF_IMPORTSPECDET_IMD_NUMCOLUMNA]
	DEFAULT (0) FOR [IMD_NUMCOLUMNA]
GO
ALTER TABLE [dbo].[IMPORTSPECDET]
	ADD
	CONSTRAINT [DF_IMPORTSPECDET_IMD_TIPO_ORIGEN]
	DEFAULT ('T') FOR [IMD_TIPO_ORIGEN]
GO
ALTER TABLE [dbo].[IMPORTSPECDET]
	ADD
	CONSTRAINT [DF_IMPORTSPECDET_IMF_CODIGO]
	DEFAULT (0) FOR [IMF_CODIGO]
GO
