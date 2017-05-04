SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[InventoryLocation] (
		[Oid]                           [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[Name]                          [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[Description]                   [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[InventoryLocationCategory]     [uniqueidentifier] NULL,
		[BarCode]                       [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[OptimisticLockField]           [int] NULL,
		[GCRecord]                      [int] NULL,
		CONSTRAINT [PK_InventoryLocation]
		PRIMARY KEY
		CLUSTERED
		([Oid])
	ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[InventoryLocation]
	WITH NOCHECK
	ADD CONSTRAINT [FK_InventoryLocation_InventoryLocationCategory]
	FOREIGN KEY ([InventoryLocationCategory]) REFERENCES [dbo].[InventoryLocationCategory] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[InventoryLocation]
	CHECK CONSTRAINT [FK_InventoryLocation_InventoryLocationCategory]

GO
CREATE NONCLUSTERED INDEX [iGCRecord_InventoryLocation]
	ON [dbo].[InventoryLocation] ([GCRecord])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iInventoryLocationCategory_InventoryLocation]
	ON [dbo].[InventoryLocation] ([InventoryLocationCategory])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[InventoryLocation] SET (LOCK_ESCALATION = TABLE)
GO
