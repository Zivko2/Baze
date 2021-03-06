SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[FACTEXPDESTRUCCION] (
		[FE_CODIGO]              [int] NOT NULL,
		[FET_NONOTARIA]          [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FET_TESTIGONOTARIA]     [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FET_ENCARGADOEMP1]      [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FET_ENCARGADOEMP2]      [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FET_DIRENCARGADO1]      [varchar](800) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FET_DIRENCARGADO2]      [varchar](800) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FET_HECHOS]             [varchar](1100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FET_FECHA]              [datetime] NULL,
		[FET_HORA]               [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FACTEXPDESTRUCCION]
	ADD
	CONSTRAINT [PK_FACTEXPDESTRUCCION]
	PRIMARY KEY
	CLUSTERED
	([FE_CODIGO])
	ON [PRIMARY]
GO
