SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[IMPEXCELPERMISO] (
		[ORDEN]            [int] IDENTITY(1, 1) NOT NULL,
		[NOPARTE]          [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[NOPARTEPADRE]     [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[TIPO]             [char](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FRACCION]         [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CANTIDAD]         [decimal](38, 6) NULL,
		[SECTOR]           [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[COSTOUNIT]        [decimal](38, 6) NULL,
		[CASNUM]           [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		CONSTRAINT [IX_IMPEXCELPERMISO]
		UNIQUE
		NONCLUSTERED
		([ORDEN])
		ON [PRIMARY]
) ON [PRIMARY]
GO
