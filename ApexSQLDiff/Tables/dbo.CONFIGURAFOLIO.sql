SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[CONFIGURAFOLIO] (
		[CFO_ENTSAL]              [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CFO_USATDOC]             [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CFO_TIPODOC]             [varchar](2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CFO_USATFACTURA]         [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CFO_USATEMBARQUE]        [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CFO_USAPROVECLIENTE]     [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CONFIGURAFOLIO]
	ADD
	CONSTRAINT [PK_CONFIGURAFOLIO_1]
	PRIMARY KEY
	NONCLUSTERED
	([CFO_ENTSAL], [CFO_USATDOC], [CFO_TIPODOC], [CFO_USATFACTURA], [CFO_USATEMBARQUE], [CFO_USAPROVECLIENTE])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[CONFIGURAFOLIO] SET (LOCK_ESCALATION = TABLE)
GO
