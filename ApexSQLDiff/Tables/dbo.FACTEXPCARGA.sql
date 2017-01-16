SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[FACTEXPCARGA] (
		[FEG_CODIGO]              [int] NOT NULL,
		[FEG_FOLIO]               [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[FEG_FECHAEMISION]        [datetime] NULL,
		[FEG_BARCODE]             [image] NULL,
		[FEG_TEXTO]               [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CT_CODIGO]               [int] NULL,
		[US_CODIGO]               [smallint] NULL,
		[FEG_FIRMA]               [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[VAL_ADMX]                [int] NULL,
		[VAL_ADUSA]               [int] NULL,
		[FEG_ESTATUS]             [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FEG_ESTATUSUSA]          [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FEG_CONSECTRANS]         [smallint] NULL,
		[FEG_FECHAHORA]           [datetime] NULL,
		[FEG_NOMBREARCH]          [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FEG_NOVIAJE]             [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FEG_TIPO]                [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FEG_BARCODECRUCE]        [image] NULL,
		[FEG_TEXTOCRUCE]          [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FEG_ADUANAMARITIMA]      [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[FEG_FIRMAELECTAVANZ]     [varchar](300) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[FACTEXPCARGA]
	ADD
	CONSTRAINT [PK_FACTEXPCARGA]
	PRIMARY KEY
	CLUSTERED
	([FEG_FOLIO])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[FACTEXPCARGA]
	ADD
	CONSTRAINT [DF_FACTEXPCARGA_FEG_ADUANAMARITIMA]
	DEFAULT ('N') FOR [FEG_ADUANAMARITIMA]
GO
ALTER TABLE [dbo].[FACTEXPCARGA] SET (LOCK_ESCALATION = TABLE)
GO
