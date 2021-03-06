SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING OFF
GO
CREATE TABLE [dbo].[WELDER] (
		[WE_CODIGO]      [int] IDENTITY(1, 1) NOT NULL,
		[WE_WELDERS]     [decimal](38, 6) NOT NULL,
		[WE_FECHA]       [datetime] NOT NULL,
		CONSTRAINT [IX_WELDER]
		UNIQUE
		NONCLUSTERED
		([WE_CODIGO])
		ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[WELDER]
	ADD
	CONSTRAINT [PK_WELDER]
	PRIMARY KEY
	NONCLUSTERED
	([WE_WELDERS], [WE_FECHA])
	ON [PRIMARY]
GO
