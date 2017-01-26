SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[LOOKUPTABLE] (
		[LT_CODIGO]       [int] NOT NULL,
		[LT_FIELD]        [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LT_SIZE]         [smallint] NULL,
		[LT_DESC]         [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LT_ENGLISH]      [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LT_DESC_ENG]     [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LT_KEYFIELD]     [varchar](60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LT_TABLE]        [varchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LOOKUPTABLE]
	ADD
	CONSTRAINT [PK_LOOKUPTABLE]
	PRIMARY KEY
	NONCLUSTERED
	([LT_CODIGO])
	ON [PRIMARY]
GO
