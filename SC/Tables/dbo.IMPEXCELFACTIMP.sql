SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[IMPEXCELFACTIMP] (
		[ORDEN]          [int] IDENTITY(1, 1) NOT NULL,
		[NOPARTE]        [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CANTIDAD]       [decimal](38, 6) NULL,
		[COSTO]          [decimal](38, 6) NULL,
		[PESO]           [decimal](38, 6) NULL,
		[ORIGEN]         [varchar](5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[NOPARTEAUX]     [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		CONSTRAINT [IX_IMPEXCELFACTIMP]
		UNIQUE
		NONCLUSTERED
		([ORDEN])
		ON [PRIMARY]
) ON [PRIMARY]
GO
