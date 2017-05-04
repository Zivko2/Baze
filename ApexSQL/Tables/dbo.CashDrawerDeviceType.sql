SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[CashDrawerDeviceType] (
		[Oid]                          [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[Name]                         [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[OpenCode]                     [varbinary](max) NULL,
		[QueryDrawerStatusCode]        [varbinary](max) NULL,
		[DrawerIsOpenCode]             [varbinary](max) NULL,
		[StatusCodeComparisonType]     [int] NULL,
		[OptimisticLockField]          [int] NULL,
		[GCRecord]                     [int] NULL,
		CONSTRAINT [PK_CashDrawerDeviceType]
		PRIMARY KEY
		CLUSTERED
		([Oid])
	ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iGCRecord_CashDrawerDeviceType]
	ON [dbo].[CashDrawerDeviceType] ([GCRecord])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[CashDrawerDeviceType] SET (LOCK_ESCALATION = TABLE)
GO
