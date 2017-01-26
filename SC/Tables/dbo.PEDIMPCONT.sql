SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[PEDIMPCONT] (
		[PIC_INDICEC]          [int] NOT NULL,
		[PID_INDICED]          [int] NOT NULL,
		[PI_CODIGO]            [int] NULL,
		[PIC_MARCA]            [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[PIC_MODELO]           [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[PIC_SERIE]            [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[PIC_EQUIPADOCON]      [varchar](3100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[PIC_USO_DESCARGA]     [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[PIC_SEL]              [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[PIC_NOACTIVO]         [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		CONSTRAINT [IX_PEDIMPCONT]
		UNIQUE
		NONCLUSTERED
		([PIC_INDICEC])
		ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PEDIMPCONT]
	ADD
	CONSTRAINT [PK_PEDIMPCONT]
	PRIMARY KEY
	NONCLUSTERED
	([PIC_INDICEC])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[PEDIMPCONT]
	ADD
	CONSTRAINT [DF_PEDIMPCONT_PIC_EQUIPADOCON]
	DEFAULT ('') FOR [PIC_EQUIPADOCON]
GO
ALTER TABLE [dbo].[PEDIMPCONT]
	ADD
	CONSTRAINT [DF_PEDIMPCONT_PIC_USO_DESCARGA]
	DEFAULT ('N') FOR [PIC_USO_DESCARGA]
GO
