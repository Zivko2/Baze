SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING OFF
GO
CREATE TABLE [dbo].[BatchTask] (
		[Oid]               [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[BatchTaskType]     [int] NULL,
		[Batch]             [uniqueidentifier] NULL,
		CONSTRAINT [PK_BatchTask]
		PRIMARY KEY
		CLUSTERED
		([Oid])
	ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[BatchTask]
	WITH NOCHECK
	ADD CONSTRAINT [FK_BatchTask_Batch]
	FOREIGN KEY ([Batch]) REFERENCES [dbo].[Batch] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[BatchTask]
	CHECK CONSTRAINT [FK_BatchTask_Batch]

GO
ALTER TABLE [dbo].[BatchTask]
	WITH NOCHECK
	ADD CONSTRAINT [FK_BatchTask_Oid]
	FOREIGN KEY ([Oid]) REFERENCES [dbo].[Task] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[BatchTask]
	CHECK CONSTRAINT [FK_BatchTask_Oid]

GO
CREATE NONCLUSTERED INDEX [iBatch_BatchTask]
	ON [dbo].[BatchTask] ([Batch])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[BatchTask] SET (LOCK_ESCALATION = TABLE)
GO
