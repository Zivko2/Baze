SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[TempOrdCompAbiertas] (
		[Codigo]            [int] IDENTITY(1, 1) NOT NULL,
		[Vendor]            [varchar](7) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[VendorName]        [varchar](35) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Prod]              [varchar](5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[DockDate]          [datetime] NULL,
		[DueDate]           [datetime] NULL,
		[ContractNbr]       [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[ItemNbr]           [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Descr]             [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Abc]               [varchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[ReqQty]            [decimal](38, 6) NULL,
		[UM]                [varchar](2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[RecvQty]           [decimal](38, 6) NULL,
		[OutstdQty]         [decimal](38, 6) NULL,
		[OPN]               [varchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[PST]               [varchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[PlaceDate]         [datetime] NULL,
		[RevisionLevel]     [varchar](5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[UnitPrice]         [decimal](38, 6) NULL,
		[SaldoQty]          [decimal](38, 6) NULL,
		CONSTRAINT [IX_TempOrdCompAbiertas]
		UNIQUE
		NONCLUSTERED
		([Codigo])
		ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TempOrdCompAbiertas] SET (LOCK_ESCALATION = TABLE)
GO
