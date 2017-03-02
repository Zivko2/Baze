SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING OFF
GO
CREATE TABLE [dbo].[PEDIMPRECT] (
		[PI_CODIGO]      [int] NOT NULL,
		[PI_NO_RECT]     [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PEDIMPRECT]
	ADD
	CONSTRAINT [PK_PEDIMPRECT]
	PRIMARY KEY
	NONCLUSTERED
	([PI_NO_RECT])
	ON [PRIMARY]
GO