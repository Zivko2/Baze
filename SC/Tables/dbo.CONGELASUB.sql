SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING OFF
GO
CREATE TABLE [dbo].[CONGELASUB] (
		[COS_CODIGO]      [int] IDENTITY(1, 1) NOT NULL,
		[FE_CODIGO]       [int] NULL,
		[FED_INDICED]     [int] NULL,
		[PID_INDICED]     [int] NULL,
		[COS_CANT]        [decimal](38, 6) NULL,
		CONSTRAINT [IX_CONGELASUB]
		UNIQUE
		NONCLUSTERED
		([COS_CODIGO])
		ON [PRIMARY]
) ON [PRIMARY]
GO
