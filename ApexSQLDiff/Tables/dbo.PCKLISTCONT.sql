SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[PCKLISTCONT] (
		[PLC_INDICEC]         [int] IDENTITY(1, 1) NOT NULL,
		[PLD_INDICED]         [int] NOT NULL,
		[PL_CODIGO]           [int] NOT NULL,
		[PLC_MARCA]           [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[PLC_MODELO]          [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[PLC_SERIE]           [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[PLC_EQUIPADOCON]     [varchar](3100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[PLC_ENUSO]           [varchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[PLC_PELIGROSO]       [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[PLC_MILLAGE]         [int] NULL,
		[PLC_NOACTIVO]        [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PCKLISTCONT]
	ADD
	CONSTRAINT [PK_PCKLISTCONT]
	PRIMARY KEY
	NONCLUSTERED
	([PLC_INDICEC], [PLD_INDICED], [PL_CODIGO])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[PCKLISTCONT]
	ADD
	CONSTRAINT [DF_PCKLISTCONT_PLC_ENUSO]
	DEFAULT ('N') FOR [PLC_ENUSO]
GO
ALTER TABLE [dbo].[PCKLISTCONT]
	ADD
	CONSTRAINT [DF_PCKLISTCONT_PLC_EQUIPADOCON]
	DEFAULT ('') FOR [PLC_EQUIPADOCON]
GO
CREATE CLUSTERED INDEX [IX_PCKLISTCONT]
	ON [dbo].[PCKLISTCONT] ([PL_CODIGO], [PLD_INDICED])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[PCKLISTCONT] SET (LOCK_ESCALATION = TABLE)
GO
