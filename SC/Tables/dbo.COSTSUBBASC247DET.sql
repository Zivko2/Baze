SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[COSTSUBBASC247DET] (
		[CS_CODIGO]             [int] NOT NULL,
		[AR_CODIGO]             [int] NULL,
		[PA_CODIGO]             [int] NULL,
		[CSBD_RATE]             [decimal](18, 6) NOT NULL,
		[MA_NAFTA]              [varchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CSBD_DUTVALWOMPF]      [decimal](38, 6) NULL,
		[CSBD_DUTVALWMPF]       [decimal](38, 6) NULL,
		[CSBD_DUTVAL]           [decimal](38, 6) NULL,
		[CSBD_3PORCENTW]        [decimal](38, 6) NULL,
		[CSBD_3PORCENTO]        [decimal](38, 6) NULL,
		[CSBD_3TOT]             [decimal](38, 6) NULL,
		[CSBD_4ACTUAL]          [decimal](38, 6) NULL,
		[CSBD_5PRORATIO]        [decimal](38, 6) NULL,
		[CSBD_5PRORATIW]        [decimal](38, 6) NULL,
		[CSBD_5TOT]             [decimal](38, 6) NULL,
		[CSBD_6DUTYACTUALO]     [decimal](38, 6) NULL,
		[CSBD_6DUTYACTUALW]     [decimal](38, 6) NULL,
		[CSBD_6TOT]             [decimal](38, 6) NULL,
		[CSBD_7DUTYPAIDO]       [decimal](38, 6) NULL,
		[CSBD_7DUTYPAIDW]       [decimal](38, 6) NULL,
		[CSBD_7TOT]             [decimal](38, 6) NULL,
		[SPI_CODIGO]            [smallint] NULL,
		[CSBD_CANT]             [decimal](38, 6) NULL,
		[PU_CODIGO]             [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[COSTSUBBASC247DET]
	ADD
	CONSTRAINT [DF_COSTSUBBASC247DET_CSBD_RATE]
	DEFAULT (0) FOR [CSBD_RATE]
GO
