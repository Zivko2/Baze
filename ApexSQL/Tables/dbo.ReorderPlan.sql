SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ReorderPlan] (
		[Oid]                             [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[Name]                            [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[Description]                     [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[StatisticsPeriodStartOffset]     [int] NULL,
		[StatisticsPeriodEndOffset]       [int] NULL,
		[OrderIntervalDays]               [int] NULL,
		[LeadTimeAdjustment]              [int] NULL,
		[SafetyStockPeriodDays]           [int] NULL,
		[OptimisticLockField]             [int] NULL,
		[GCRecord]                        [int] NULL,
		CONSTRAINT [PK_ReorderPlan]
		PRIMARY KEY
		CLUSTERED
		([Oid])
	ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iGCRecord_ReorderPlan]
	ON [dbo].[ReorderPlan] ([GCRecord])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[ReorderPlan] SET (LOCK_ESCALATION = TABLE)
GO
