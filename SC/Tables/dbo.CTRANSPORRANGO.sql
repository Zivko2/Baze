SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING OFF
GO
CREATE TABLE [dbo].[CTRANSPORRANGO] (
		[CTR_CODIGO]      [int] IDENTITY(1, 1) NOT NULL,
		[CT_CODIGO]       [int] NOT NULL,
		[CTR_CANTINI]     [decimal](38, 6) NOT NULL,
		[CTR_CANTFIN]     [decimal](38, 6) NOT NULL,
		[CTR_PRECIO]      [decimal](38, 6) NULL,
		CONSTRAINT [IX_CTRANSPORRANGO]
		UNIQUE
		NONCLUSTERED
		([CTR_CODIGO])
		ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CTRANSPORRANGO]
	ADD
	CONSTRAINT [PK_CTRANSPORRANGO]
	PRIMARY KEY
	CLUSTERED
	([CT_CODIGO], [CTR_CANTINI], [CTR_CANTFIN])
	ON [PRIMARY]
GO