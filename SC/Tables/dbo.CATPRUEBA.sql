SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[CATPRUEBA] (
		[PRU_CODIGO]     [smallint] IDENTITY(1, 1) NOT NULL,
		[PRU_DESC]       [varchar](250) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		CONSTRAINT [IX_CATPRUEBA]
		UNIQUE
		CLUSTERED
		([PRU_CODIGO])
		ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CATPRUEBA]
	ADD
	CONSTRAINT [PK_CATPRUEBA]
	PRIMARY KEY
	NONCLUSTERED
	([PRU_DESC])
	ON [PRIMARY]
GO