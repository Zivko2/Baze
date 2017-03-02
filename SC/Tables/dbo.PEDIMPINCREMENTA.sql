SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING OFF
GO
CREATE TABLE [dbo].[PEDIMPINCREMENTA] (
		[PI_CODIGO]     [int] NOT NULL,
		[IC_CODIGO]     [smallint] NOT NULL,
		[PII_VALOR]     [decimal](38, 6) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PEDIMPINCREMENTA]
	ADD
	CONSTRAINT [PK_PEDIMPINCREMENTA]
	PRIMARY KEY
	NONCLUSTERED
	([PI_CODIGO], [IC_CODIGO])
	ON [PRIMARY]
GO