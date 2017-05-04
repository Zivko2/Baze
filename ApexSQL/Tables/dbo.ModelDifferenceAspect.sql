SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ModelDifferenceAspect] (
		[Oid]                     [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[Name]                    [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[Xml]                     [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
		[Owner]                   [uniqueidentifier] NULL,
		[OptimisticLockField]     [int] NULL,
		[GCRecord]                [int] NULL,
		CONSTRAINT [PK_ModelDifferenceAspect]
		PRIMARY KEY
		CLUSTERED
		([Oid])
	ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[ModelDifferenceAspect]
	WITH NOCHECK
	ADD CONSTRAINT [FK_ModelDifferenceAspect_Owner]
	FOREIGN KEY ([Owner]) REFERENCES [dbo].[ModelDifference] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[ModelDifferenceAspect]
	CHECK CONSTRAINT [FK_ModelDifferenceAspect_Owner]

GO
CREATE NONCLUSTERED INDEX [iGCRecord_ModelDifferenceAspect]
	ON [dbo].[ModelDifferenceAspect] ([GCRecord])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iOwner_ModelDifferenceAspect]
	ON [dbo].[ModelDifferenceAspect] ([Owner])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[ModelDifferenceAspect] SET (LOCK_ESCALATION = TABLE)
GO
