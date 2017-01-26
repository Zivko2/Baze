SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ValorAgregado] (
		[NoParte]      [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[ValorAgr]     [decimal](38, 6) NOT NULL
) ON [PRIMARY]
GO
