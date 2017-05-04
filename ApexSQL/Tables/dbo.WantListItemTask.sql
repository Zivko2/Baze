SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING OFF
GO
CREATE TABLE [dbo].[WantListItemTask] (
		[Oid]              [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[WantListItem]     [uniqueidentifier] NULL,
		CONSTRAINT [PK_WantListItemTask]
		PRIMARY KEY
		CLUSTERED
		([Oid])
	ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[WantListItemTask]
	WITH NOCHECK
	ADD CONSTRAINT [FK_WantListItemTask_Oid]
	FOREIGN KEY ([Oid]) REFERENCES [dbo].[Task] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[WantListItemTask]
	CHECK CONSTRAINT [FK_WantListItemTask_Oid]

GO
ALTER TABLE [dbo].[WantListItemTask]
	WITH NOCHECK
	ADD CONSTRAINT [FK_WantListItemTask_WantListItem]
	FOREIGN KEY ([WantListItem]) REFERENCES [dbo].[WantListItem] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[WantListItemTask]
	CHECK CONSTRAINT [FK_WantListItemTask_WantListItem]

GO
CREATE NONCLUSTERED INDEX [iWantListItem_WantListItemTask]
	ON [dbo].[WantListItemTask] ([WantListItem])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[WantListItemTask] SET (LOCK_ESCALATION = TABLE)
GO
