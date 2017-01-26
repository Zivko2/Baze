SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING OFF
GO
CREATE TABLE [dbo].[TempRevisionCostos] (
		[BSU_SUBENSAMBLE]     [int] NOT NULL,
		[FORANEO]             [decimal](38, 6) NULL,
		[SUMFORANEO]          [decimal](38, 6) NULL,
		[ORIGINARIO]          [int] NULL,
		[SUMORIGINARIO]       [decimal](38, 6) NULL
) ON [PRIMARY]
GO
