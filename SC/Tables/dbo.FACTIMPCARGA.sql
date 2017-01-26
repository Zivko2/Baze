SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[FACTIMPCARGA] (
		[FIG_CODIGO]              [int] NOT NULL,
		[FIG_FOLIO]               [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[FIG_FECHAEMISION]        [datetime] NULL,
		[FIG_BARCODE]             [image] NULL,
		[FIG_TEXTO]               [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CT_CODIGO]               [int] NULL,
		[US_CODIGO]               [smallint] NULL,
		[FIG_FIRMA]               [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[VAL_ADMX]                [int] NULL,
		[VAL_ADUSA]               [int] NULL,
		[FIG_ESTATUS]             [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FIG_ESTATUSUSA]          [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FIG_CONSECTRANS]         [smallint] NULL,
		[FIG_FECHAHORA]           [datetime] NULL,
		[FIG_NOMBREARCH]          [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FIG_NOVIAJE]             [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FIG_TIPO]                [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FIG_BARCODECRUCE]        [image] NULL,
		[FIG_TEXTOCRUCE]          [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FIG_ADUANAMARITIMA]      [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[FIG_FIRMAELECTAVANZ]     [varchar](300) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[FACTIMPCARGA]
	ADD
	CONSTRAINT [PK_FACTIMPCARGA]
	PRIMARY KEY
	CLUSTERED
	([FIG_FOLIO])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[FACTIMPCARGA]
	ADD
	CONSTRAINT [DF_FACTIMPCARGA_FIG_ADUANAMARITIMA]
	DEFAULT ('N') FOR [FIG_ADUANAMARITIMA]
GO
