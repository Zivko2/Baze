SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [Staged].[ExchangeRateToUSDBaseForStaging] (
		[StartDate]          [datetime] NOT NULL,
		[SourceCurrency]     [char](3) COLLATE Latin1_General_CI_AS NOT NULL,
		[Rate]               [decimal](18, 4) NOT NULL
) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_StartDate_SourceCurrency]
	ON [Staged].[ExchangeRateToUSDBaseForStaging] ([StartDate], [SourceCurrency])
	ON [PRIMARY]
GO
ALTER TABLE [Staged].[ExchangeRateToUSDBaseForStaging] SET (LOCK_ESCALATION = TABLE)
GO
