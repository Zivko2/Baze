SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[CambiosXInventario] (
		[FED_INDICED]     [int] NULL,
		[FACTCONV]        [float] NULL,
		[MA_CODIGO]       [int] NULL,
		[TIPO]            [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CambiosXInventario] SET (LOCK_ESCALATION = TABLE)
GO
