SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ItemType] (
		[Oid]                     [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[Code]                    [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[Description]             [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[OptimisticLockField]     [int] NULL,
		[GCRecord]                [int] NULL,
		CONSTRAINT [PK_ItemType]
		PRIMARY KEY
		CLUSTERED
		([Oid])
	ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iGCRecord_ItemType]
	ON [dbo].[ItemType] ([GCRecord])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[ItemType] SET (LOCK_ESCALATION = TABLE)
GO
