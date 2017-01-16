SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[FACTIMPDETIDENTIFICA] (
		[FIID_CODIGO]      [int] NOT NULL,
		[FID_INDICED]      [int] NOT NULL,
		[IDE_CODIGO]       [int] NOT NULL,
		[IDED_CODIGO]      [int] NULL,
		[FIID_DESC]        [varchar](40) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[FIID_DESC2]       [varchar](40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IDED_CODIGO2]     [int] NULL,
		[FIID_DESC3]       [varchar](40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IDED_CODIGO3]     [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FACTIMPDETIDENTIFICA]
	ADD
	CONSTRAINT [PK_FACTIMPDETIDENTIFICA]
	PRIMARY KEY
	CLUSTERED
	([FIID_CODIGO])
	WITH FILLFACTOR=90
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[FACTIMPDETIDENTIFICA]
	ADD
	CONSTRAINT [DF_FACTIMPDETIDENTIFICA_FIID_DESC]
	DEFAULT ('') FOR [FIID_DESC]
GO
ALTER TABLE [dbo].[FACTIMPDETIDENTIFICA] SET (LOCK_ESCALATION = TABLE)
GO
