SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING OFF
GO
CREATE TABLE [dbo].[ENTSALALMNOINTEGRA] (
		[EN_CODIGO]                [int] NOT NULL,
		[END_INDICED]              [int] NOT NULL,
		[END_CANTALMNOINTEGRA]     [decimal](38, 6) NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ENTSALALMNOINTEGRA]
	ADD
	CONSTRAINT [DF_ENTSALALMNOINTEGRA_END_CANTALMNOINTEGRA]
	DEFAULT (0) FOR [END_CANTALMNOINTEGRA]
GO
ALTER TABLE [dbo].[ENTSALALMNOINTEGRA] SET (LOCK_ESCALATION = TABLE)
GO
