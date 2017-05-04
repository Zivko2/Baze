SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING OFF
GO
CREATE TABLE [dbo].[InventoryAccount] (
		[Oid]                     [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[InventoryGLAccount]      [uniqueidentifier] NULL,
		[CogsGLAccount]           [uniqueidentifier] NULL,
		[WritedownAccount]        [uniqueidentifier] NULL,
		[Enabled]                 [bit] NULL,
		[OptimisticLockField]     [int] NULL,
		[GCRecord]                [int] NULL,
		CONSTRAINT [PK_InventoryAccount]
		PRIMARY KEY
		CLUSTERED
		([Oid])
	ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[InventoryAccount]
	WITH NOCHECK
	ADD CONSTRAINT [FK_InventoryAccount_CogsGLAccount]
	FOREIGN KEY ([CogsGLAccount]) REFERENCES [dbo].[GLAccount] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[InventoryAccount]
	CHECK CONSTRAINT [FK_InventoryAccount_CogsGLAccount]

GO
ALTER TABLE [dbo].[InventoryAccount]
	WITH NOCHECK
	ADD CONSTRAINT [FK_InventoryAccount_InventoryGLAccount]
	FOREIGN KEY ([InventoryGLAccount]) REFERENCES [dbo].[GLAccount] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[InventoryAccount]
	CHECK CONSTRAINT [FK_InventoryAccount_InventoryGLAccount]

GO
ALTER TABLE [dbo].[InventoryAccount]
	WITH NOCHECK
	ADD CONSTRAINT [FK_InventoryAccount_WritedownAccount]
	FOREIGN KEY ([WritedownAccount]) REFERENCES [dbo].[GLAccount] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[InventoryAccount]
	CHECK CONSTRAINT [FK_InventoryAccount_WritedownAccount]

GO
CREATE NONCLUSTERED INDEX [iCogsGLAccount_InventoryAccount]
	ON [dbo].[InventoryAccount] ([CogsGLAccount])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iGCRecord_InventoryAccount]
	ON [dbo].[InventoryAccount] ([GCRecord])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iInventoryGLAccount_InventoryAccount]
	ON [dbo].[InventoryAccount] ([InventoryGLAccount])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iWritedownAccount_InventoryAccount]
	ON [dbo].[InventoryAccount] ([WritedownAccount])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[InventoryAccount] SET (LOCK_ESCALATION = TABLE)
GO
