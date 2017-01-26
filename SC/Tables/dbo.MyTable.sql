SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[MyTable] (
		[ab_codigo]     [int] NULL,
		[AddDate]       [smalldatetime] NOT NULL,
		[mdefault]      [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MyTable]
	ADD
	CONSTRAINT [DF_MyTable_AddDate]
	DEFAULT (getdate()) FOR [AddDate]
GO
ALTER TABLE [dbo].[MyTable]
	ADD
	CONSTRAINT [DF_MyTable_mdefault]
	DEFAULT ('N') FOR [mdefault]
GO
