SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[IMPORTACIONRESINAS] (
		[IR_Codigo]                    [int] IDENTITY(1, 1) NOT NULL,
		[IR_NoPartePlantaOrigen]       [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IR_DivisionPlantaOrigen]      [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IR_NoPartePlantaDestino]      [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IR_DivisionPlantaDestino]     [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IR_FechaInicial]              [datetime] NULL,
		[IR_FechaFinal]                [datetime] NULL,
		CONSTRAINT [IX_IMPORTACIONRESINAS]
		UNIQUE
		NONCLUSTERED
		([IR_Codigo])
		ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[IMPORTACIONRESINAS]
	ADD
	CONSTRAINT [PK_IMPORTACIONRESINAS]
	PRIMARY KEY
	CLUSTERED
	([IR_Codigo])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[IMPORTACIONRESINAS] SET (LOCK_ESCALATION = TABLE)
GO
