SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[IDENTIFICADOR] (
		[MA_CODIGO]         [int] NOT NULL,
		[IDENTIFICADOR]     [varchar](222) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[IDENTIFICADOR] SET (LOCK_ESCALATION = TABLE)
GO
