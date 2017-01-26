SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[IDENTIFICACLIENTE] (
		[IDEC_CODIGO]         [int] IDENTITY(1, 1) NOT NULL,
		[CL_CODIGO]           [int] NOT NULL,
		[IDE_CODIGO]          [int] NOT NULL,
		[IDEC_NIVEL]          [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IDEC_MOVIMIENTO]     [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IDED_CODIGO]         [int] NULL,
		[IDEC_DESC]           [varchar](40) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[IDEC_DESC2]          [varchar](40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IDED_CODIGO2]        [int] NULL,
		[IDEC_DESC3]          [varchar](40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IDED_CODIGO3]        [int] NULL,
		CONSTRAINT [IX_IDENTIFICACLIENTE]
		UNIQUE
		NONCLUSTERED
		([IDEC_CODIGO])
		ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[IDENTIFICACLIENTE]
	ADD
	CONSTRAINT [PK_IDENTIFICACLIENTE]
	PRIMARY KEY
	CLUSTERED
	([CL_CODIGO], [IDE_CODIGO])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[IDENTIFICACLIENTE]
	ADD
	CONSTRAINT [DF_IDENTIFICACLIENTE_IDEC_DESC]
	DEFAULT ('') FOR [IDEC_DESC]
GO
ALTER TABLE [dbo].[IDENTIFICACLIENTE]
	ADD
	CONSTRAINT [DF_IDENTIFICACLIENTE_IDEC_NIVEL]
	DEFAULT ('G') FOR [IDEC_NIVEL]
GO
