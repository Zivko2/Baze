SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[SALIDACAMION] (
		[SC_CODIGO]        [int] NOT NULL,
		[SC_FOLIO]         [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[FE_CODIGO]        [int] NOT NULL,
		[TR_CODIGO]        [int] NOT NULL,
		[SC_CONTENIDO]     [smallint] NOT NULL,
		[SC_CHOFER]        [varchar](80) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[SC_TRACTOR]       [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[SC_RECIBO]        [varchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[SC_FECHA]         [datetime] NULL,
		[SC_TIPO]          [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CA_CODIGO]        [int] NOT NULL,
		[SC_TRAC_MX]       [varchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[SC_TRAC_US]       [varchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CT_CODIGO]        [int] NOT NULL,
		[SC_ESTATUS]       [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CJ_CODIGO]        [int] NOT NULL,
		[SC_CONT_REG]      [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[SC_CONT_MX]       [varchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[SC_CONT_US]       [varchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[SC_SELLO]         [varchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[YA_CODIGO]        [int] NOT NULL,
		[SC_COMENTA]       [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		CONSTRAINT [IX_SALIDACAMION]
		UNIQUE
		NONCLUSTERED
		([SC_CODIGO])
		ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[SALIDACAMION]
	ADD
	CONSTRAINT [PK_SALIDACAMION]
	PRIMARY KEY
	NONCLUSTERED
	([SC_FOLIO])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[SALIDACAMION] SET (LOCK_ESCALATION = TABLE)
GO
