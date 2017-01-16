SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[MAESTROAUX] (
		[MAX_CODIGO]                  [int] NOT NULL,
		[MA_CODIGO]                   [int] NOT NULL,
		[FCC_CODIGO]                  [smallint] NULL,
		[MAX_FCCQTYAPPROVAL]          [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[MAX_FCCIDENTIFIER]           [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[MAX_FCCTRADENAME]            [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[MAX_FCCPUBLICINSPECTION]     [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FDA_CODIGO]                  [smallint] NULL,
		[FDA_PRODCODE]                [varchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[MAX_FDASTORAGE]              [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[PA_FDACOUNTRYCODE]           [int] NULL,
		[MAX_FDAMARKER]               [char](3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MAESTROAUX]
	ADD
	CONSTRAINT [PK_MAESTROAUX]
	PRIMARY KEY
	NONCLUSTERED
	([MAX_CODIGO])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[MAESTROAUX] SET (LOCK_ESCALATION = TABLE)
GO
