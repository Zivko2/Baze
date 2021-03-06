SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[PERMISOIMAGEN] (
		[PE_CODIGO]            [int] NOT NULL,
		[IM_IMAGEN]            [image] NULL,
		[IM_ORDEN]             [int] NOT NULL,
		[IM_NOMBREARCHIVO]     [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[PE_FOLIO]             [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[PERMISOIMAGEN]
	ADD
	CONSTRAINT [PK_PERMISOIMAGEN]
	PRIMARY KEY
	CLUSTERED
	([PE_CODIGO], [IM_ORDEN])
	ON [PRIMARY]
GO
