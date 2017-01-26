SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING OFF
GO
CREATE TABLE [dbo].[A16DET] (
		[A16D_CODIGO]         [int] IDENTITY(1, 1) NOT NULL,
		[A16_CODIGO]          [int] NOT NULL,
		[MA_GENERICO]         [int] NOT NULL,
		[CL_CODIGO]           [int] NOT NULL,
		[PI_CODIGO]           [int] NOT NULL,
		[A16D_VALORTRANS]     [decimal](38, 6) NOT NULL,
		[A16D_VALORADQ0]      [decimal](38, 6) NOT NULL,
		[A16D_PROPORCION]     [decimal](38, 6) NULL,
		CONSTRAINT [IX_A16DET]
		UNIQUE
		NONCLUSTERED
		([A16D_CODIGO])
		ON [PRIMARY]
) ON [PRIMARY]
GO
