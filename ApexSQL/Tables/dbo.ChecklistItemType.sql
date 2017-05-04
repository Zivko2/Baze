SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ChecklistItemType] (
		[Oid]                           [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[LineNumber]                    [int] NULL,
		[Name]                          [nvarchar](200) COLLATE Latin1_General_CI_AS NULL,
		[Description]                   [nvarchar](1000) COLLATE Latin1_General_CI_AS NULL,
		[ChecklistType]                 [int] NULL,
		[RequiredType]                  [int] NULL,
		[IncompleteInstructionText]     [nvarchar](1000) COLLATE Latin1_General_CI_AS NULL,
		[ScanOptionIfYes]               [bit] NULL,
		[OptimisticLockField]           [int] NULL,
		[GCRecord]                      [int] NULL,
		CONSTRAINT [PK_ChecklistItemType]
		PRIMARY KEY
		CLUSTERED
		([Oid])
	ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iGCRecord_ChecklistItemType]
	ON [dbo].[ChecklistItemType] ([GCRecord])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[ChecklistItemType] SET (LOCK_ESCALATION = TABLE)
GO
