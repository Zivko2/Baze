SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[XpoWorkflowDefinition] (
		[Oid]                                 [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[Name]                                [nvarchar](255) COLLATE Latin1_General_CI_AS NULL,
		[Xaml]                                [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
		[TargetObjectType]                    [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[Criteria]                            [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
		[IsActive]                            [bit] NULL,
		[AutoStartWhenObjectIsCreated]        [bit] NULL,
		[AutoStartWhenObjectFitsCriteria]     [bit] NULL,
		[OptimisticLockField]                 [int] NULL,
		[GCRecord]                            [int] NULL,
		CONSTRAINT [PK_XpoWorkflowDefinition]
		PRIMARY KEY
		CLUSTERED
		([Oid])
	ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iGCRecord_XpoWorkflowDefinition]
	ON [dbo].[XpoWorkflowDefinition] ([GCRecord])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[XpoWorkflowDefinition] SET (LOCK_ESCALATION = TABLE)
GO
