SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[PEDIMPFACT] (
		[PIF_CODIGO]           [int] IDENTITY(1, 1) NOT NULL,
		[PI_CODIGO]            [int] NOT NULL,
		[FI_FOLIO]             [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[FI_FECHA]             [datetime] NULL,
		[IT_CODIGO]            [smallint] NULL,
		[MO_CODIGO]            [smallint] NULL,
		[PIF_VALMONEXT]        [decimal](38, 6) NULL,
		[PIF_FACTORMONEXT]     [decimal](38, 6) NULL,
		[PIF_VALDLLS]          [decimal](38, 6) NULL,
		[PR_CODIGO]            [int] NULL,
		[DI_CODIGO]            [int] NULL,
		CONSTRAINT [IX_PEDIMPFACT]
		UNIQUE
		NONCLUSTERED
		([PIF_CODIGO])
		ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PEDIMPFACT]
	ADD
	CONSTRAINT [PK_PEDIMPFACT]
	PRIMARY KEY
	CLUSTERED
	([PI_CODIGO], [FI_FOLIO])
	WITH FILLFACTOR=90
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[PEDIMPFACT] SET (LOCK_ESCALATION = TABLE)
GO
