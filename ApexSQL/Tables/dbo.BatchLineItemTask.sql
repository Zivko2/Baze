SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING OFF
GO
CREATE TABLE [dbo].[BatchLineItemTask] (
		[Oid]                       [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[BatchLineItemTaskType]     [int] NULL,
		[BatchLineItem]             [uniqueidentifier] NULL,
		CONSTRAINT [PK_BatchLineItemTask]
		PRIMARY KEY
		CLUSTERED
		([Oid])
	ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[BatchLineItemTask]
	WITH NOCHECK
	ADD CONSTRAINT [FK_BatchLineItemTask_BatchLineItem]
	FOREIGN KEY ([BatchLineItem]) REFERENCES [dbo].[BatchLineItem] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[BatchLineItemTask]
	CHECK CONSTRAINT [FK_BatchLineItemTask_BatchLineItem]

GO
ALTER TABLE [dbo].[BatchLineItemTask]
	WITH NOCHECK
	ADD CONSTRAINT [FK_BatchLineItemTask_Oid]
	FOREIGN KEY ([Oid]) REFERENCES [dbo].[Task] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[BatchLineItemTask]
	CHECK CONSTRAINT [FK_BatchLineItemTask_Oid]

GO
CREATE NONCLUSTERED INDEX [iBatchLineItem_BatchLineItemTask]
	ON [dbo].[BatchLineItemTask] ([BatchLineItem])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[BatchLineItemTask] SET (LOCK_ESCALATION = TABLE)
GO
