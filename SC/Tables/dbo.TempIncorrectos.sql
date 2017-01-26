SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[TempIncorrectos] (
		[DIFFORANEO]          [decimal](38, 6) NULL,
		[FIDORIGINARIO]       [decimal](38, 6) NULL,
		[BSU_NOPARTE]         [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[BSU_SUBENSAMBLE]     [int] NOT NULL
) ON [PRIMARY]
GO
