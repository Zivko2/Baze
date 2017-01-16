SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[TempPedImpCont] (
		[PIC_INDICEC]          [int] IDENTITY(1, 1) NOT NULL,
		[PID_INDICED]          [int] NOT NULL,
		[PI_CODIGO]            [int] NULL,
		[PIC_MARCA]            [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[PIC_MODELO]           [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[PIC_SERIE]            [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[PIC_EQUIPADOCON]      [varchar](3100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[PIC_USO_DESCARGA]     [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[PIC_SEL]              [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[PIC_NOACTIVO]         [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		CONSTRAINT [IX_TempPedImpCont]
		UNIQUE
		NONCLUSTERED
		([PIC_INDICEC])
		WITH FILLFACTOR=90
		ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TempPedImpCont]
	ADD
	CONSTRAINT [DF_TempPedImpCont_PIC_EQUIPADOCON]
	DEFAULT ('') FOR [PIC_EQUIPADOCON]
GO
ALTER TABLE [dbo].[TempPedImpCont]
	ADD
	CONSTRAINT [DF_TempPedImpCont_PIC_USO_DESCARGA]
	DEFAULT ('N') FOR [PIC_USO_DESCARGA]
GO
ALTER TABLE [dbo].[TempPedImpCont] SET (LOCK_ESCALATION = TABLE)
GO
