SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Currency] (
		[Oid]                        [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[IsoCode]                    [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[Name]                       [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[Symbol]                     [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[DecimalPlacesDisplayed]     [int] NULL,
		[OptimisticLockField]        [int] NULL,
		[GCRecord]                   [int] NULL,
		CONSTRAINT [PK_Currency]
		PRIMARY KEY
		CLUSTERED
		([Oid])
	ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iGCRecord_Currency]
	ON [dbo].[Currency] ([GCRecord])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[Currency] SET (LOCK_ESCALATION = TABLE)
GO
