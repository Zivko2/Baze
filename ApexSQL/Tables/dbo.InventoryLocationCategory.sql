SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[InventoryLocationCategory] (
		[Oid]                     [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[Code]                    [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[Description]             [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[OptimisticLockField]     [int] NULL,
		[GCRecord]                [int] NULL,
		CONSTRAINT [PK_InventoryLocationCategory]
		PRIMARY KEY
		CLUSTERED
		([Oid])
	ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iGCRecord_InventoryLocationCategory]
	ON [dbo].[InventoryLocationCategory] ([GCRecord])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[InventoryLocationCategory] SET (LOCK_ESCALATION = TABLE)
GO
