SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING OFF
GO
CREATE TABLE [dbo].[CTRANSPORPAGOTROS] (
		[CTPO_INDICED]     [int] IDENTITY(1, 1) NOT NULL,
		[CTP_CODIGO]       [int] NOT NULL,
		[CTPD_INDICED]     [int] NOT NULL,
		[IC_CODIGO]        [smallint] NOT NULL,
		[CTPO_VALOR]       [decimal](38, 6) NULL,
		CONSTRAINT [IX_CTRANSPORPAGOTROS]
		UNIQUE
		NONCLUSTERED
		([CTPO_INDICED])
		ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CTRANSPORPAGOTROS]
	ADD
	CONSTRAINT [PK_CTRANSPORPAGOTROS]
	PRIMARY KEY
	CLUSTERED
	([CTPD_INDICED], [IC_CODIGO])
	WITH FILLFACTOR=90
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[CTRANSPORPAGOTROS] SET (LOCK_ESCALATION = TABLE)
GO
