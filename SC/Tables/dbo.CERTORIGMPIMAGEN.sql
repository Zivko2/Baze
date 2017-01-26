SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[CERTORIGMPIMAGEN] (
		[CMP_CODIGO]            [int] NOT NULL,
		[CMP_IMAGEN]            [image] NULL,
		[CMP_ORDEN]             [int] NOT NULL,
		[CMP_NOMBREARCHIVO]     [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[CERTORIGMPIMAGEN]
	ADD
	CONSTRAINT [PK_CERTORIGMPIMAGEN]
	PRIMARY KEY
	CLUSTERED
	([CMP_CODIGO], [CMP_ORDEN])
	ON [PRIMARY]
GO
