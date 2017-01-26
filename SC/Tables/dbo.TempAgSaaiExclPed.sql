SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[TempAgSaaiExclPed] (
		[Codigo]               [int] IDENTITY(1, 1) NOT NULL,
		[Pedimento]            [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[PedimentoObserva]     [varchar](1100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		CONSTRAINT [IX_TempAgSaaiExclPed]
		UNIQUE
		NONCLUSTERED
		([Codigo])
		ON [PRIMARY]
) ON [PRIMARY]
GO
