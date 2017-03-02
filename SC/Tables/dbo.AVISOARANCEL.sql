SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[AVISOARANCEL] (
		[AR_CODIGO]     [int] NOT NULL,
		[AV_TIPO]       [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AVISOARANCEL]
	ADD
	CONSTRAINT [PK_AVISOARANCEL]
	PRIMARY KEY
	CLUSTERED
	([AR_CODIGO], [AV_TIPO])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[AVISOARANCEL]
	ADD
	CONSTRAINT [DF_AVISOARANCEL_AV_TIPO]
	DEFAULT ('E') FOR [AV_TIPO]
GO