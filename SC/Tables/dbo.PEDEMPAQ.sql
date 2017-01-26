SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING OFF
GO
CREATE TABLE [dbo].[PEDEMPAQ] (
		[PI_CODIGO]       [int] NOT NULL,
		[PQ_INDICEE]      [int] NOT NULL,
		[MA_CODIGO]       [int] NOT NULL,
		[PQ_CANTIDAD]     [decimal](38, 6) NOT NULL,
		[PQ_SALDO]        [decimal](38, 6) NOT NULL,
		[FI_CODIGO]       [int] NOT NULL
) ON [PRIMARY]
GO
