SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[PCKLISTDEF] (
		[PL_CODIGO]      [int] NOT NULL,
		[PL_DEFTXT1]     [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[PL_DEFTXT2]     [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[PL_DEFNO1]      [int] NOT NULL,
		[PL_DEFNO2]      [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PCKLISTDEF]
	ADD
	CONSTRAINT [PK_PCKLISTDEF]
	PRIMARY KEY
	CLUSTERED
	([PL_CODIGO])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[PCKLISTDEF]
	ADD
	CONSTRAINT [DF_PCKLISTDEF_PL_DEFNO1]
	DEFAULT (0) FOR [PL_DEFNO1]
GO
ALTER TABLE [dbo].[PCKLISTDEF]
	ADD
	CONSTRAINT [DF_PCKLISTDEF_PL_DEFNO2]
	DEFAULT (0) FOR [PL_DEFNO2]
GO
ALTER TABLE [dbo].[PCKLISTDEF]
	ADD
	CONSTRAINT [DF_PCKLISTDEF_PL_DEFTXT1]
	DEFAULT ('') FOR [PL_DEFTXT1]
GO
ALTER TABLE [dbo].[PCKLISTDEF]
	ADD
	CONSTRAINT [DF_PCKLISTDEF_PL_DEFTXT2]
	DEFAULT ('') FOR [PL_DEFTXT2]
GO