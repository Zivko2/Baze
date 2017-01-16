SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[DescNegativas] (
		[KAP_FACTRANS]         [int] NULL,
		[KAP_INDICED_FACT]     [int] NULL,
		[KAP_ESTATUS]          [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CantXDescargar]       [decimal](38, 6) NULL,
		[MA_HIJO]              [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DescNegativas] SET (LOCK_ESCALATION = TABLE)
GO
