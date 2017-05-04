SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[XpoUserActivityVersion] (
		[Oid]                     [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[WorkflowUniqueId]        [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[Xaml]                    [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
		[Version]                 [int] NULL,
		[OptimisticLockField]     [int] NULL,
		[GCRecord]                [int] NULL,
		CONSTRAINT [PK_XpoUserActivityVersion]
		PRIMARY KEY
		CLUSTERED
		([Oid])
	ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iGCRecord_XpoUserActivityVersion]
	ON [dbo].[XpoUserActivityVersion] ([GCRecord])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[XpoUserActivityVersion] SET (LOCK_ESCALATION = TABLE)
GO
