SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING OFF
GO
CREATE TABLE [dbo].[RELCTRANSPORMEDIOTRAN] (
		[MT_CODIGO]     [smallint] NOT NULL,
		[CT_CODIGO]     [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[RELCTRANSPORMEDIOTRAN]
	ADD
	CONSTRAINT [PK_RELCTRANSPORMEDIOTRAN]
	PRIMARY KEY
	NONCLUSTERED
	([MT_CODIGO], [CT_CODIGO])
	ON [PRIMARY]
GO