SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[WorkOrderGroup] (
		[Oid]                        [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[Name]                       [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[Description]                [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[WorkOrderGroupCategory]     [uniqueidentifier] NULL,
		[WorkOrderSuffix]            [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[OptimisticLockField]        [int] NULL,
		[GCRecord]                   [int] NULL,
		CONSTRAINT [PK_WorkOrderGroup]
		PRIMARY KEY
		CLUSTERED
		([Oid])
	ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[WorkOrderGroup]
	WITH NOCHECK
	ADD CONSTRAINT [FK_WorkOrderGroup_WorkOrderGroupCategory]
	FOREIGN KEY ([WorkOrderGroupCategory]) REFERENCES [dbo].[WorkOrderGroupCategory] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[WorkOrderGroup]
	CHECK CONSTRAINT [FK_WorkOrderGroup_WorkOrderGroupCategory]

GO
CREATE NONCLUSTERED INDEX [iGCRecord_WorkOrderGroup]
	ON [dbo].[WorkOrderGroup] ([GCRecord])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iWorkOrderGroupCategory_WorkOrderGroup]
	ON [dbo].[WorkOrderGroup] ([WorkOrderGroupCategory])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[WorkOrderGroup] SET (LOCK_ESCALATION = TABLE)
GO
