SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ENTRACAMION] (
		[EC_CODIGO]        [int] NOT NULL,
		[EC_FOLIO]         [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[FI_CODIGO]        [int] NOT NULL,
		[CE_CODIGO]        [int] NOT NULL,
		[EC_TIPO]          [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[EC_CONTENIDO]     [smallint] NOT NULL,
		[EC_TRACTOR]       [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[EC_RECIBO]        [varchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[EC_FECHA]         [datetime] NULL,
		[EC_CHOFER]        [varchar](80) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CA_CODIGO]        [int] NOT NULL,
		[EC_TRAC_MX]       [varchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[EC_TRAC_US]       [varchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CT_CODIGO]        [int] NOT NULL,
		[EC_ESTATUS]       [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CJ_CODIGO]        [int] NOT NULL,
		[EC_CONT_REG]      [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[EC_CONT_MX]       [varchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[EC_CONT_US]       [varchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[EC_SELLO]         [varchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[YA_CODIGO]        [int] NOT NULL,
		[EC_COMENTA]       [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		CONSTRAINT [IX_ENTRACAMION]
		UNIQUE
		NONCLUSTERED
		([EC_CODIGO])
		ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[ENTRACAMION]
	ADD
	CONSTRAINT [PK_ENTRACAMION]
	PRIMARY KEY
	NONCLUSTERED
	([EC_FOLIO])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[ENTRACAMION] SET (LOCK_ESCALATION = TABLE)
GO
