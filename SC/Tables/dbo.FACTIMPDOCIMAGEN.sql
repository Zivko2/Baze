SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[FACTIMPDOCIMAGEN] (
		[FIR_CODIGO]            [int] NOT NULL,
		[FIM_ORDEN]             [int] NOT NULL,
		[FIM_NOMBREARCHIVO]     [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[FIM_RUTAARCHIVO]       [varchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FACTIMPDOCIMAGEN]
	ADD
	CONSTRAINT [PK_FACTIMPDOCIMAGEN]
	PRIMARY KEY
	CLUSTERED
	([FIR_CODIGO], [FIM_NOMBREARCHIVO])
	ON [PRIMARY]
GO
