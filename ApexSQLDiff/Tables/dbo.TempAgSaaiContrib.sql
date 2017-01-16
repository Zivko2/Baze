SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[TempAgSaaiContrib] (
		[Patente]          [varchar](4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Pedimento]        [varchar](7) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Aduana]           [varchar](4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Fraccion]         [varchar](8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Sec]              [int] NULL,
		[Contribucion]     [smallint] NULL,
		[FPago]            [smallint] NULL,
		[Importe]          [decimal](38, 6) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TempAgSaaiContrib] SET (LOCK_ESCALATION = TABLE)
GO
