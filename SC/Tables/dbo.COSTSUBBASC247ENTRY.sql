SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[COSTSUBBASC247ENTRY] (
		[CS_CODIGO]           [int] NOT NULL,
		[ET_CODIGO]           [int] NULL,
		[AR_CODIGO]           [int] NULL,
		[PA_CODIGO]           [int] NULL,
		[SPI_CODIGO]          [smallint] NULL,
		[CSBE_RATE]           [decimal](38, 6) NOT NULL,
		[PU_CODIGO]           [int] NULL,
		[CSBE_CANT]           [decimal](38, 6) NULL,
		[MA_NAFTA]            [varchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CSBE_DUTVAL]         [decimal](38, 6) NULL,
		[CSBE_DUTVALREC]      [decimal](38, 6) NULL,
		[CSBE_PRORATIW]       [decimal](38, 6) NULL,
		[CSBE_MPFDLLS]        [decimal](38, 6) NULL,
		[CSBE_DUTVALWMPF]     [decimal](38, 6) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[COSTSUBBASC247ENTRY]
	ADD
	CONSTRAINT [DF_COSTSUBBASC247ENTRY_CSBE_RATE]
	DEFAULT (0) FOR [CSBE_RATE]
GO
