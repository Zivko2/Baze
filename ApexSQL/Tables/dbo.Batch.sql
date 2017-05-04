SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Batch] (
		[Oid]                      [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[BatchStatus]              [int] NULL,
		[BatchNumber]              [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[Source]                   [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[CreatedOn]                [datetime] NULL,
		[SubmittedForReviewOn]     [datetime] NULL,
		[Note]                     [nvarchar](1000) COLLATE Latin1_General_CI_AS NULL,
		[OptimisticLockField]      [int] NULL,
		[GCRecord]                 [int] NULL,
		CONSTRAINT [PK_Batch]
		PRIMARY KEY
		CLUSTERED
		([Oid])
	ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iGCRecord_Batch]
	ON [dbo].[Batch] ([GCRecord])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[Batch] SET (LOCK_ESCALATION = TABLE)
GO
