SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[UnitOfMeasure] (
		[Oid]                     [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[Name]                    [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[Description]             [nvarchar](1000) COLLATE Latin1_General_CI_AS NULL,
		[OptimisticLockField]     [int] NULL,
		[GCRecord]                [int] NULL,
		CONSTRAINT [PK_UnitOfMeasure]
		PRIMARY KEY
		CLUSTERED
		([Oid])
	ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iGCRecord_UnitOfMeasure]
	ON [dbo].[UnitOfMeasure] ([GCRecord])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[UnitOfMeasure] SET (LOCK_ESCALATION = TABLE)
GO
