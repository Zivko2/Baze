SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING OFF
GO
CREATE TABLE [dbo].[EQUIVALE] (
		[ME_CODIGO1]     [int] NOT NULL,
		[ME_CODIGO2]     [int] NOT NULL,
		[EQ_CANT]        [decimal](28, 14) NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[EQUIVALE]
	ADD
	CONSTRAINT [PK_EQUIVALE]
	PRIMARY KEY
	NONCLUSTERED
	([ME_CODIGO1], [ME_CODIGO2])
	ON [PRIMARY]
GO