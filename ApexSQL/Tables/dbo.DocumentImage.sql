SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[DocumentImage] (
		[Oid]                     [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[Title]                   [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[EntityName]              [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[EntityID]                [uniqueidentifier] NULL,
		[FileName]                [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[FileSize]                [bigint] NULL,
		[AcquiredBy]              [uniqueidentifier] NULL,
		[AcquiredOn]              [datetime] NULL,
		[FullPath]                [nvarchar](512) COLLATE Latin1_General_CI_AS NULL,
		[Notes]                   [nvarchar](1000) COLLATE Latin1_General_CI_AS NULL,
		[OptimisticLockField]     [int] NULL,
		[GCRecord]                [int] NULL,
		CONSTRAINT [PK_DocumentImage]
		PRIMARY KEY
		CLUSTERED
		([Oid])
	ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DocumentImage]
	WITH NOCHECK
	ADD CONSTRAINT [FK_DocumentImage_AcquiredBy]
	FOREIGN KEY ([AcquiredBy]) REFERENCES [dbo].[ExtendedSecurityUser] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[DocumentImage]
	CHECK CONSTRAINT [FK_DocumentImage_AcquiredBy]

GO
CREATE NONCLUSTERED INDEX [iAcquiredBy_DocumentImage]
	ON [dbo].[DocumentImage] ([AcquiredBy])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iGCRecord_DocumentImage]
	ON [dbo].[DocumentImage] ([GCRecord])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[DocumentImage] SET (LOCK_ESCALATION = TABLE)
GO
