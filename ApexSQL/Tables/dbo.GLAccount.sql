SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[GLAccount] (
		[Oid]                     [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[AccountID]               [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[AccountNumber]           [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[Name]                    [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[Description]             [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[OptimisticLockField]     [int] NULL,
		[GCRecord]                [int] NULL,
		CONSTRAINT [PK_GLAccount]
		PRIMARY KEY
		CLUSTERED
		([Oid])
	ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iGCRecord_GLAccount]
	ON [dbo].[GLAccount] ([GCRecord])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[GLAccount] SET (LOCK_ESCALATION = TABLE)
GO
