SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[PAISARATIGIE1] (
		[PART_CODIGO]          [int] NOT NULL,
		[ART_CODIGO]           [int] NOT NULL,
		[PA_CODIGO]            [int] NOT NULL,
		[PART_BEN]             [float] NULL,
		[SPI_CODIGO]           [smallint] NOT NULL,
		[PART_CUOTA]           [smallint] NULL,
		[PART_IVA]             [float] NULL,
		[PART_TLC]             [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[PART_IEPS]            [float] NULL,
		[PART_ISAN]            [float] NULL,
		[ART_TIPOIMPUESTO]     [varchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PAISARATIGIE1]
	ADD
	CONSTRAINT [PK_PAISARATIGIE1]
	PRIMARY KEY
	NONCLUSTERED
	([PART_CODIGO])
	WITH FILLFACTOR=90
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[PAISARATIGIE1] SET (LOCK_ESCALATION = TABLE)
GO
