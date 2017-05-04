SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING OFF
GO
CREATE TABLE [dbo].[ItemCrossReference] (
		[Oid]                     [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[Item]                    [uniqueidentifier] NULL,
		[CrossReferenceType]      [uniqueidentifier] NULL,
		[CrossReferencedItem]     [uniqueidentifier] NULL,
		[OptimisticLockField]     [int] NULL,
		[GCRecord]                [int] NULL,
		CONSTRAINT [PK_ItemCrossReference]
		PRIMARY KEY
		CLUSTERED
		([Oid])
	ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ItemCrossReference]
	WITH NOCHECK
	ADD CONSTRAINT [FK_ItemCrossReference_CrossReferencedItem]
	FOREIGN KEY ([CrossReferencedItem]) REFERENCES [dbo].[Item] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[ItemCrossReference]
	CHECK CONSTRAINT [FK_ItemCrossReference_CrossReferencedItem]

GO
ALTER TABLE [dbo].[ItemCrossReference]
	WITH NOCHECK
	ADD CONSTRAINT [FK_ItemCrossReference_CrossReferenceType]
	FOREIGN KEY ([CrossReferenceType]) REFERENCES [dbo].[CrossReferenceType] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[ItemCrossReference]
	CHECK CONSTRAINT [FK_ItemCrossReference_CrossReferenceType]

GO
ALTER TABLE [dbo].[ItemCrossReference]
	WITH NOCHECK
	ADD CONSTRAINT [FK_ItemCrossReference_Item]
	FOREIGN KEY ([Item]) REFERENCES [dbo].[Item] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[ItemCrossReference]
	CHECK CONSTRAINT [FK_ItemCrossReference_Item]

GO
CREATE NONCLUSTERED INDEX [iCrossReferencedItem_ItemCrossReference]
	ON [dbo].[ItemCrossReference] ([CrossReferencedItem])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iCrossReferenceType_ItemCrossReference]
	ON [dbo].[ItemCrossReference] ([CrossReferenceType])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iGCRecord_ItemCrossReference]
	ON [dbo].[ItemCrossReference] ([GCRecord])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iItem_ItemCrossReference]
	ON [dbo].[ItemCrossReference] ([Item])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[ItemCrossReference] SET (LOCK_ESCALATION = TABLE)
GO
