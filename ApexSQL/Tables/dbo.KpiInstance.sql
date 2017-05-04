SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[KpiInstance] (
		[Oid]                          [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[ForceMeasurementDateTime]     [datetime] NULL,
		[KpiDefinition]                [uniqueidentifier] NULL,
		[Settings]                     [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
		[OptimisticLockField]          [int] NULL,
		[GCRecord]                     [int] NULL,
		CONSTRAINT [PK_KpiInstance]
		PRIMARY KEY
		CLUSTERED
		([Oid])
	ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[KpiInstance]
	WITH NOCHECK
	ADD CONSTRAINT [FK_KpiInstance_KpiDefinition]
	FOREIGN KEY ([KpiDefinition]) REFERENCES [dbo].[KpiDefinition] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[KpiInstance]
	CHECK CONSTRAINT [FK_KpiInstance_KpiDefinition]

GO
CREATE NONCLUSTERED INDEX [iGCRecord_KpiInstance]
	ON [dbo].[KpiInstance] ([GCRecord])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iKpiDefinition_KpiInstance]
	ON [dbo].[KpiInstance] ([KpiDefinition])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[KpiInstance] SET (LOCK_ESCALATION = TABLE)
GO
