SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[VINCULA] (
		[VI_CODIGO]      [smallint] IDENTITY(1, 1) NOT NULL,
		[VI_CORTO]       [varchar](5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[VI_DESCRIP]     [varchar](60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		CONSTRAINT [IX_VINCULA]
		UNIQUE
		NONCLUSTERED
		([VI_CODIGO])
		ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VINCULA]
	ADD
	CONSTRAINT [PK_VINCULA]
	PRIMARY KEY
	NONCLUSTERED
	([VI_CORTO])
	ON [PRIMARY]
GO
