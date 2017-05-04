SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING OFF
GO
CREATE TABLE [dbo].[KpiScorecardScorecards_KpiInstanceIndicators] (
		[Indicators]              [uniqueidentifier] NULL,
		[Scorecards]              [uniqueidentifier] NULL,
		[OID]                     [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[OptimisticLockField]     [int] NULL,
		CONSTRAINT [PK_KpiScorecardScorecards_KpiInstanceIndicators]
		PRIMARY KEY
		CLUSTERED
		([OID])
	ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[KpiScorecardScorecards_KpiInstanceIndicators]
	WITH NOCHECK
	ADD CONSTRAINT [FK_KpiScorecardScorecards_KpiInstanceIndicators_Indicators]
	FOREIGN KEY ([Indicators]) REFERENCES [dbo].[KpiInstance] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[KpiScorecardScorecards_KpiInstanceIndicators]
	CHECK CONSTRAINT [FK_KpiScorecardScorecards_KpiInstanceIndicators_Indicators]

GO
ALTER TABLE [dbo].[KpiScorecardScorecards_KpiInstanceIndicators]
	WITH NOCHECK
	ADD CONSTRAINT [FK_KpiScorecardScorecards_KpiInstanceIndicators_Scorecards]
	FOREIGN KEY ([Scorecards]) REFERENCES [dbo].[KpiScorecard] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[KpiScorecardScorecards_KpiInstanceIndicators]
	CHECK CONSTRAINT [FK_KpiScorecardScorecards_KpiInstanceIndicators_Scorecards]

GO
CREATE NONCLUSTERED INDEX [iIndicators_KpiScorecardScorecards_KpiInstanceIndicators]
	ON [dbo].[KpiScorecardScorecards_KpiInstanceIndicators] ([Indicators])
	ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [iIndicatorsScorecards_KpiScorecardScorecards_KpiInstanceIndicators]
	ON [dbo].[KpiScorecardScorecards_KpiInstanceIndicators] ([Indicators], [Scorecards])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iScorecards_KpiScorecardScorecards_KpiInstanceIndicators]
	ON [dbo].[KpiScorecardScorecards_KpiInstanceIndicators] ([Scorecards])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[KpiScorecardScorecards_KpiInstanceIndicators] SET (LOCK_ESCALATION = TABLE)
GO
