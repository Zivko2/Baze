SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ScannerSetting] (
		[Oid]                          [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[UseDocumentFeeder]            [bit] NULL,
		[UseDuplex]                    [bit] NULL,
		[BlackAndWhite]                [bit] NULL,
		[ShowProgressIndicator]        [bit] NULL,
		[AutomaticRotate]              [bit] NULL,
		[AutomaticBorderDetection]     [bit] NULL,
		[BoxArea]                      [bit] NULL,
		[ActiveSourceName]             [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[ComputerName]                 [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[ShowTwainUI]                  [bit] NULL,
		[OptimisticLockField]          [int] NULL,
		[GCRecord]                     [int] NULL,
		CONSTRAINT [PK_ScannerSetting]
		PRIMARY KEY
		CLUSTERED
		([Oid])
	ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iGCRecord_ScannerSetting]
	ON [dbo].[ScannerSetting] ([GCRecord])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[ScannerSetting] SET (LOCK_ESCALATION = TABLE)
GO
