SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING OFF
GO
CREATE TABLE [dbo].[RELCLAVEPEDIDENTIFICA] (
		[CP_CODIGO]      [int] NOT NULL,
		[IDE_CODIGO]     [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[RELCLAVEPEDIDENTIFICA]
	ADD
	CONSTRAINT [PK_RELCLAVEPEDIDENTIFICA]
	PRIMARY KEY
	NONCLUSTERED
	([CP_CODIGO], [IDE_CODIGO])
	ON [PRIMARY]
GO
