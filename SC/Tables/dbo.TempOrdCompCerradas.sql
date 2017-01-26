SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[TempOrdCompCerradas] (
		[CODIGO]               [int] IDENTITY(1, 1) NOT NULL,
		[ACCT_NBR]             [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[VENDOR_NUMBER]        [varchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[VENDOR_NAME]          [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[RECV_DATE]            [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[ITEM_NUMBER]          [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[QTY_RECVD]            [float] NULL,
		[UM]                   [varchar](2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[STD_COST]             [decimal](38, 6) NULL,
		[LAST_COST]            [decimal](38, 6) NULL,
		[EXT_COST]             [decimal](38, 6) NULL,
		[ORDER_NUMBER]         [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[BY]                   [varchar](2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[DOC_NBR]              [varchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[ITEM_DESCRIPTION]     [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[SaldoQty]             [decimal](38, 6) NULL,
		CONSTRAINT [IX_TempOrdCompCerradas]
		UNIQUE
		NONCLUSTERED
		([CODIGO])
		ON [PRIMARY]
) ON [PRIMARY]
GO
