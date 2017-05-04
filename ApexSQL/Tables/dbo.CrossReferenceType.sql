SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[CrossReferenceType] (
		[Oid]                     [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[Description]             [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[OptimisticLockField]     [int] NULL,
		[GCRecord]                [int] NULL,
		CONSTRAINT [PK_CrossReferenceType]
		PRIMARY KEY
		CLUSTERED
		([Oid])
	ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iGCRecord_CrossReferenceType]
	ON [dbo].[CrossReferenceType] ([GCRecord])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[CrossReferenceType] SET (LOCK_ESCALATION = TABLE)
GO
