SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING OFF
GO
CREATE TABLE [dbo].[TempBOMSUBCOSTO] (
		[BSU_SUBENSAMBLE]     [int] NOT NULL,
		[FORANEO]             [decimal](38, 6) NULL,
		[ORIGINARIO]          [int] NOT NULL
) ON [PRIMARY]
GO
