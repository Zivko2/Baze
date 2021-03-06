SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[VALIDADORBANCO] (
		[VAL_CODIGO]             [int] NOT NULL,
		[BAN_CODIGO]             [smallint] NOT NULL,
		[VALB_RUTAREMOTA]        [varchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[VALB_RUTALOCAL]         [varchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[VALB_RUTAREMOTARES]     [varchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[VALB_RUTALOCALRES]      [varchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[VALB_ANTES]             [varchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[VALB_ANTESRES]          [varchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[VALB_PAGOMAXIMO]        [decimal](38, 6) NULL,
		[VALB_BANGENERA]         [varchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[VALB_BANANTES]          [varchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[VALB_BANDESPUES]        [varchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[VALB_IDCUENTAB]         [varchar](5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VALIDADORBANCO]
	ADD
	CONSTRAINT [PK_VALIDADORBANCO]
	PRIMARY KEY
	CLUSTERED
	([VAL_CODIGO], [BAN_CODIGO])
	ON [PRIMARY]
GO
