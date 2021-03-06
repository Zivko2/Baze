SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING OFF
GO
CREATE TABLE [dbo].[CONTROLRETRABAJOSALDOPREVIO] (
		[CRP_Codigo]                 [int] IDENTITY(1, 1) NOT NULL,
		[CR_Codigo]                  [int] NOT NULL,
		[CRP_CantidadDescargada]     [decimal](38, 6) NOT NULL,
		[FED_Indiced]                [int] NOT NULL,
		CONSTRAINT [IX_CONTROLRETRABAJOSALDOPREVIO]
		UNIQUE
		NONCLUSTERED
		([CRP_Codigo])
		ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CONTROLRETRABAJOSALDOPREVIO]
	ADD
	CONSTRAINT [PK_CONTROLRETRABAJOSALDOPREVIO]
	PRIMARY KEY
	CLUSTERED
	([CRP_Codigo])
	ON [PRIMARY]
GO
