SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING OFF
GO
CREATE TABLE [dbo].[CicladoTemp] (
		[fe_codigo]       [int] NULL,
		[fed_indiced]     [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CicladoTemp] SET (LOCK_ESCALATION = TABLE)
GO
