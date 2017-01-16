SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING OFF
GO
CREATE TABLE [dbo].[KARDESPEDCONT] (
		[FE_CODIGO]       [int] NULL,
		[FED_INDICED]     [int] NOT NULL,
		[FEC_INDICEC]     [int] NOT NULL,
		[PIC_INDICEC]     [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[KARDESPEDCONT]
	ADD
	CONSTRAINT [PK_KARDESPEDCONT]
	PRIMARY KEY
	NONCLUSTERED
	([FEC_INDICEC], [PIC_INDICEC])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[KARDESPEDCONT] SET (LOCK_ESCALATION = TABLE)
GO
