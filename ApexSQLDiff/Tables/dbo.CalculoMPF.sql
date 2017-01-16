SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[CalculoMPF] (
		[Nafta?]                 [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[Invoice]                [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[Manifiesto]             [varchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Date]                   [datetime] NULL,
		[Qty]                    [decimal](38, 6) NULL,
		[ExtendedForeign]        [decimal](38, 6) NULL,
		[ExtendedUS]             [decimal](38, 6) NULL,
		[ExtendedMX]             [decimal](38, 6) NULL,
		[ExtendedPackaging]      [decimal](38, 6) NULL,
		[ExtendedKits]           [decimal](38, 6) NULL,
		[ExtendedAddedValue]     [decimal](38, 6) NULL,
		[TotalExtendedCost]      [decimal](38, 6) NULL,
		[MPFDutyKit]             [decimal](38, 6) NULL,
		[MPFDuty]                [decimal](38, 6) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CalculoMPF] SET (LOCK_ESCALATION = TABLE)
GO
