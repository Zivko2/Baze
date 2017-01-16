SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[pedimpconciliaDetIdentifica] (
		[PI_CODIGO]         [int] NULL,
		[Pedimento]         [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[RecordNum]         [int] NULL,
		[Identificator]     [varchar](3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Complement]        [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Complement2]       [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Complement3]       [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[pedimpconciliaDetIdentifica] SET (LOCK_ESCALATION = TABLE)
GO
