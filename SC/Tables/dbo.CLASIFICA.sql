SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[CLASIFICA] (
		[CS_CODIGO]     [smallint] IDENTITY(1, 1) NOT NULL,
		[CS_DESC]       [varchar](80) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CS_TRAT]       [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		CONSTRAINT [IX_CLASIFICA]
		UNIQUE
		NONCLUSTERED
		([CS_CODIGO])
		ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CLASIFICA]
	ADD
	CONSTRAINT [PK_CLASIFICA]
	PRIMARY KEY
	NONCLUSTERED
	([CS_DESC])
	ON [PRIMARY]
GO