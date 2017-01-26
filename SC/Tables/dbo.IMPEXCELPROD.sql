SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[IMPEXCELPROD] (
		[ORDEN]        [int] IDENTITY(1, 1) NOT NULL,
		[NOPARTE]      [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CANTIDAD]     [decimal](38, 6) NULL,
		[COSTO]        [decimal](38, 6) NULL,
		[PRECIO]       [decimal](38, 6) NULL,
		[PESO]         [decimal](38, 6) NULL,
		CONSTRAINT [IX_IMPEXCELPROD]
		UNIQUE
		NONCLUSTERED
		([ORDEN])
		ON [PRIMARY]
) ON [PRIMARY]
GO
