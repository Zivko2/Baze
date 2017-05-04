SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Country] (
		[Oid]                     [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[Name]                    [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[PhoneCode]               [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[OptimisticLockField]     [int] NULL,
		[GCRecord]                [int] NULL,
		CONSTRAINT [PK_Country]
		PRIMARY KEY
		CLUSTERED
		([Oid])
	ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iGCRecord_Country]
	ON [dbo].[Country] ([GCRecord])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[Country] SET (LOCK_ESCALATION = TABLE)
GO
