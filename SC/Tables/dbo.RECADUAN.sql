SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[RECADUAN] (
		[RN_CODIGO]      [int] NOT NULL,
		[RN_FOLIO]       [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[PI_CODIGO]      [int] NOT NULL,
		[RN_COLOR]       [smallint] NOT NULL,
		[RN_MULTA]       [decimal](38, 6) NOT NULL,
		[RN_COMENTA]     [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[RN_ADV]         [decimal](38, 6) NOT NULL,
		[RN_DTA]         [decimal](38, 6) NOT NULL,
		[RN_IVA]         [decimal](38, 6) NOT NULL,
		[RN_ISAN]        [decimal](38, 6) NOT NULL,
		[RN_IEPS]        [decimal](38, 6) NOT NULL,
		[RN_CC]          [decimal](38, 6) NOT NULL,
		[RN_REC]         [decimal](38, 6) NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
