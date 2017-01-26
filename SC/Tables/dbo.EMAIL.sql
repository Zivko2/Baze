SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[EMAIL] (
		[CE_CODIGO]      [int] IDENTITY(1, 1) NOT NULL,
		[CE_FECHA]       [datetime] NOT NULL,
		[CE_ARCHIVO]     [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CE_RUTA]        [varchar](1100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		CONSTRAINT [IX_EMAIL]
		UNIQUE
		NONCLUSTERED
		([CE_CODIGO])
		ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[EMAIL]
	ADD
	CONSTRAINT [PK_EMAIL]
	PRIMARY KEY
	NONCLUSTERED
	([CE_FECHA], [CE_ARCHIVO])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[EMAIL]
	ADD
	CONSTRAINT [DF_EMAIL_CE_FECHA]
	DEFAULT (getdate()) FOR [CE_FECHA]
GO
