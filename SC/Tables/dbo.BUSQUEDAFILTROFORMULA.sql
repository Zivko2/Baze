SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[BUSQUEDAFILTROFORMULA] (
		[BFIF_CODIGO]       [int] NOT NULL,
		[BUS_CODIGO]        [int] NOT NULL,
		[BFIF_FORMULA]      [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[BFIF_OPERADOR]     [int] NOT NULL,
		[BFIF_IGUAL]        [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[BFIF_MIN]          [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[BFIF_MAX]          [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[BFIF_NULL]         [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[BUSQUEDAFILTROFORMULA]
	ADD
	CONSTRAINT [PK_BUSQUEDAFILTROFORMULA]
	PRIMARY KEY
	NONCLUSTERED
	([BFIF_CODIGO])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[BUSQUEDAFILTROFORMULA]
	ADD
	CONSTRAINT [DF_BUSQUEDAFILTROFORMULA_BFIF_NULL]
	DEFAULT ('N') FOR [BFIF_NULL]
GO
