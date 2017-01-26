SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[CONFIGURATFACT] (
		[CFF_TIPO]             [char](2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[TF_CODIGO]            [smallint] NOT NULL,
		[CFF_TRAT]             [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CFF_TIPODESCARGA]     [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CONFIGURATFACT]
	ADD
	CONSTRAINT [PK_CONFIGURATFACT]
	PRIMARY KEY
	NONCLUSTERED
	([TF_CODIGO])
	ON [PRIMARY]
GO
