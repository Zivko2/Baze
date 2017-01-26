SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[KARDATOSPEDEXPPAGOUSA] (
		[PIB_INDICEB]           [int] NULL,
		[FE_CODIGO]             [int] NULL,
		[FED_INDICED]           [int] NULL,
		[AR_EXPFO]              [int] NULL,
		[FED_RATEIMPFO]         [decimal](38, 6) NULL,
		[TOTALVALORGRAVUSA]     [decimal](38, 6) NULL,
		[TOTALVALORGRAVMN]      [decimal](38, 6) NULL,
		[TOTALARANUSAMN]        [decimal](38, 6) NULL,
		[TOTALARANUSA]          [decimal](38, 6) NULL,
		[PIB_SECUENCIA]         [int] NULL,
		[PI_CODIGO]             [int] NULL,
		[PIB_DESTNAFTA]         [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
