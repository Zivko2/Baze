SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[WorkOrderGroupCategory] (
		[Oid]                     [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[Code]                    [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[Description]             [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[CostCenter]              [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[OptimisticLockField]     [int] NULL,
		[GCRecord]                [int] NULL,
		CONSTRAINT [PK_WorkOrderGroupCategory]
		PRIMARY KEY
		CLUSTERED
		([Oid])
	ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iGCRecord_WorkOrderGroupCategory]
	ON [dbo].[WorkOrderGroupCategory] ([GCRecord])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[WorkOrderGroupCategory] SET (LOCK_ESCALATION = TABLE)
GO
