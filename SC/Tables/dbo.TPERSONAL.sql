SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[TPERSONAL] (
		[UT_CODIGO]     [smallint] IDENTITY(1, 1) NOT NULL,
		[UT_NOMBRE]     [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UT_NAME]       [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		CONSTRAINT [IX_TPERSONAL]
		UNIQUE
		NONCLUSTERED
		([UT_CODIGO])
		ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TPERSONAL]
	ADD
	CONSTRAINT [PK_TPERSONAL]
	PRIMARY KEY
	NONCLUSTERED
	([UT_NOMBRE])
	ON [PRIMARY]
GO
