SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING OFF
GO
CREATE TABLE [dbo].[ItemTask] (
		[Oid]      [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[Item]     [uniqueidentifier] NULL,
		CONSTRAINT [PK_ItemTask]
		PRIMARY KEY
		CLUSTERED
		([Oid])
	ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ItemTask]
	WITH NOCHECK
	ADD CONSTRAINT [FK_ItemTask_Item]
	FOREIGN KEY ([Item]) REFERENCES [dbo].[Item] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[ItemTask]
	CHECK CONSTRAINT [FK_ItemTask_Item]

GO
ALTER TABLE [dbo].[ItemTask]
	WITH NOCHECK
	ADD CONSTRAINT [FK_ItemTask_Oid]
	FOREIGN KEY ([Oid]) REFERENCES [dbo].[Task] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[ItemTask]
	CHECK CONSTRAINT [FK_ItemTask_Oid]

GO
CREATE NONCLUSTERED INDEX [iItem_ItemTask]
	ON [dbo].[ItemTask] ([Item])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[ItemTask] SET (LOCK_ESCALATION = TABLE)
GO
