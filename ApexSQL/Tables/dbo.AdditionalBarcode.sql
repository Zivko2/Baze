SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[AdditionalBarcode] (
		[Oid]                     [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[BarCode]                 [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[EntityName]              [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[EntityID]                [uniqueidentifier] NULL,
		[OptimisticLockField]     [int] NULL,
		[GCRecord]                [int] NULL,
		CONSTRAINT [PK_AdditionalBarcode]
		PRIMARY KEY
		CLUSTERED
		([Oid])
	ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iGCRecord_AdditionalBarcode]
	ON [dbo].[AdditionalBarcode] ([GCRecord])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[AdditionalBarcode] SET (LOCK_ESCALATION = TABLE)
GO
