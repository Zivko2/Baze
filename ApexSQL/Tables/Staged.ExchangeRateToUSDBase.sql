SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [Staged].[ExchangeRateToUSDBase] (
		[StartDate]          [datetime] NOT NULL,
		[Rate]               [money] NULL,
		[SourceCurrency]     [nvarchar](100) COLLATE Latin1_General_CI_AS NOT NULL,
		CONSTRAINT [PK_Staged_ExchangeRateToUSDBase_A8CC2AFD]
		PRIMARY KEY
		CLUSTERED
		([SourceCurrency], [StartDate])
	ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Staged].[ExchangeRateToUSDBase] SET (LOCK_ESCALATION = TABLE)
GO
