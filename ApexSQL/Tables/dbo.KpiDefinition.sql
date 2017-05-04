SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[KpiDefinition] (
		[Oid]                               [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[TargetObjectType]                  [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[Changed]                           [datetime] NULL,
		[KpiInstance]                       [uniqueidentifier] NULL,
		[Name]                              [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[Active]                            [bit] NULL,
		[Criteria]                          [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
		[Expression]                        [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
		[GreenZone]                         [float] NULL,
		[RedZone]                           [float] NULL,
		[Range]                             [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[Compare]                           [bit] NULL,
		[RangeToCompare]                    [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[MeasurementFrequency]              [int] NULL,
		[MeasurementMode]                   [int] NULL,
		[Direction]                         [int] NULL,
		[ChangedOn]                         [datetime] NULL,
		[SuppressedSeries]                  [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[EnableCustomizeRepresentation]     [bit] NULL,
		[OptimisticLockField]               [int] NULL,
		[GCRecord]                          [int] NULL,
		CONSTRAINT [PK_KpiDefinition]
		PRIMARY KEY
		CLUSTERED
		([Oid])
	ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[KpiDefinition]
	WITH NOCHECK
	ADD CONSTRAINT [FK_KpiDefinition_KpiInstance]
	FOREIGN KEY ([KpiInstance]) REFERENCES [dbo].[KpiInstance] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[KpiDefinition]
	CHECK CONSTRAINT [FK_KpiDefinition_KpiInstance]

GO
CREATE NONCLUSTERED INDEX [iGCRecord_KpiDefinition]
	ON [dbo].[KpiDefinition] ([GCRecord])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iKpiInstance_KpiDefinition]
	ON [dbo].[KpiDefinition] ([KpiInstance])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[KpiDefinition] SET (LOCK_ESCALATION = TABLE)
GO
