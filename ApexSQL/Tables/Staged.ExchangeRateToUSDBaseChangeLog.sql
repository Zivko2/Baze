SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [Staged].[ExchangeRateToUSDBaseChangeLog] (
		[Id]                    [int] IDENTITY(1, 1) NOT NULL,
		[ChangeTime]            [datetime] NOT NULL,
		[ChangeType]            [nvarchar](10) COLLATE Latin1_General_CI_AS NOT NULL,
		[NewSourceCurrency]     [char](3) COLLATE Latin1_General_CI_AS NULL,
		[NewStartDate]          [datetime] NULL,
		[NewRate]               [decimal](18, 4) NULL,
		[OldSourceCurrency]     [char](3) COLLATE Latin1_General_CI_AS NULL,
		[OldStartDate]          [datetime] NULL,
		[OldRate]               [decimal](18, 4) NULL,
		CONSTRAINT [PK_ExchangeRateToUSDBaseChangeLog]
		PRIMARY KEY
		CLUSTERED
		([Id])
	ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Staged].[ExchangeRateToUSDBaseChangeLog]
	ADD
	CONSTRAINT [DF_ExchangeRateToUSDBaseChangeLog_ChangeTime]
	DEFAULT (getdate()) FOR [ChangeTime]
GO
ALTER TABLE [Staged].[ExchangeRateToUSDBaseChangeLog] SET (LOCK_ESCALATION = TABLE)
GO
