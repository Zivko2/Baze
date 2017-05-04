SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ReportDataV2] (
		[Oid]                          [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[ObjectTypeName]               [nvarchar](512) COLLATE Latin1_General_CI_AS NULL,
		[Content]                      [varbinary](max) NULL,
		[Name]                         [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[ParametersObjectTypeName]     [nvarchar](512) COLLATE Latin1_General_CI_AS NULL,
		[IsInplaceReport]              [bit] NULL,
		[PredefinedReportType]         [nvarchar](512) COLLATE Latin1_General_CI_AS NULL,
		[OptimisticLockField]          [int] NULL,
		[GCRecord]                     [int] NULL,
		CONSTRAINT [PK_ReportDataV2]
		PRIMARY KEY
		CLUSTERED
		([Oid])
	ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iGCRecord_ReportDataV2]
	ON [dbo].[ReportDataV2] ([GCRecord])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[ReportDataV2] SET (LOCK_ESCALATION = TABLE)
GO
