SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[AVISOTRASLADO] (
		[ATI_CODIGO]              [int] NOT NULL,
		[ATI_FOLIO]               [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[ATI_FECHAEMISION]        [datetime] NULL,
		[ATI_TIPOOPERA]           [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[ATI_TIPOTRASLADO]        [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[ATI_BARCODE]             [image] NULL,
		[ATI_TEXTO]               [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[US_CODIGO]               [smallint] NULL,
		[ATI_FIRMA]               [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[ATI_ESTATUS]             [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[DI_ORIGEN]               [int] NULL,
		[DI_DESTINO]              [int] NULL,
		[ATI_ACUSEDERECIBO]       [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[ATI_FIRMAELECTAVANZ]     [varchar](300) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[AGT_CODIGO]              [int] NULL,
		[ATI_ENTRADA]             [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[ATI_OBSERVA]             [varchar](1100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[ATI_FECHADESCARGA]       [datetime] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[AVISOTRASLADO]
	ADD
	CONSTRAINT [PK_AVISOTRASLADO]
	PRIMARY KEY
	CLUSTERED
	([ATI_FOLIO])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[AVISOTRASLADO]
	ADD
	CONSTRAINT [DF_AVISOTRASLADO_ATI_ESTATUS]
	DEFAULT ('S') FOR [ATI_ESTATUS]
GO
