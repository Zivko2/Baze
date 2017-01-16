SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[FACTEXPDETIDENTIFICA] (
		[FEID_CODIGO]      [int] NOT NULL,
		[FED_INDICED]      [int] NOT NULL,
		[IDE_CODIGO]       [int] NOT NULL,
		[IDED_CODIGO]      [int] NULL,
		[FEID_DESC]        [varchar](40) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[FEID_DESC2]       [varchar](40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IDED_CODIGO2]     [int] NULL,
		[FEID_DESC3]       [varchar](40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IDED_CODIGO3]     [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FACTEXPDETIDENTIFICA]
	ADD
	CONSTRAINT [PK_FACTEXPDETIDENTIFICA]
	PRIMARY KEY
	CLUSTERED
	([FED_INDICED], [IDE_CODIGO])
	WITH FILLFACTOR=90
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[FACTEXPDETIDENTIFICA]
	ADD
	CONSTRAINT [DF_FACTEXPDETIDENTIFICA_FEID_DESC]
	DEFAULT ('') FOR [FEID_DESC]
GO
ALTER TABLE [dbo].[FACTEXPDETIDENTIFICA] SET (LOCK_ESCALATION = TABLE)
GO
