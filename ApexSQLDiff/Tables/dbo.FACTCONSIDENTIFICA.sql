SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[FACTCONSIDENTIFICA] (
		[FCI_CODIGO]       [int] NOT NULL,
		[FC_CODIGO]        [int] NOT NULL,
		[IDE_CODIGO]       [int] NOT NULL,
		[IDED_CODIGO]      [int] NULL,
		[FCI_DESC]         [varchar](40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FCI_DESC2]        [varchar](40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IDED_CODIGO2]     [int] NULL,
		[FCI_DESC3]        [varchar](40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IDED_CODIGO3]     [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FACTCONSIDENTIFICA]
	ADD
	CONSTRAINT [PK_FACTCONSIDENTIFICA]
	PRIMARY KEY
	CLUSTERED
	([FCI_CODIGO])
	WITH FILLFACTOR=90
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[FACTCONSIDENTIFICA]
	ADD
	CONSTRAINT [DF_FACTCONSIDENTIFICA_FCI_DESC]
	DEFAULT ('') FOR [FCI_DESC]
GO
ALTER TABLE [dbo].[FACTCONSIDENTIFICA] SET (LOCK_ESCALATION = TABLE)
GO
