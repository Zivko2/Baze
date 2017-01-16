SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[FACTIMPPED] (
		[FIP_INDICEP]      [int] NOT NULL,
		[FID_INDICED]      [int] NULL,
		[FI_CODIGO]        [int] NULL,
		[FIP_AGENCIA]      [varchar](80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FIP_PEDIMP]       [varchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FIP_FECHA]        [datetime] NULL,
		[FIP_TIP_PED]      [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[AD_CODIGO]        [int] NULL,
		[CEX_CONSTAN]      [varchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CEX_CONS_RFC]     [varchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CEX_CONS_FEC]     [datetime] NULL,
		[FIP_TIPO]         [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FACTIMPPED]
	ADD
	CONSTRAINT [PK_FACTIMPPED]
	PRIMARY KEY
	NONCLUSTERED
	([FIP_INDICEP])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[FACTIMPPED]
	ADD
	CONSTRAINT [DF_FACTIMPPED_FIP_TIPO]
	DEFAULT ('P') FOR [FIP_TIPO]
GO
CREATE NONCLUSTERED INDEX [IX_FACTIMPPED]
	ON [dbo].[FACTIMPPED] ([FID_INDICED])
	WITH ( FILLFACTOR = 90)
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[FACTIMPPED] SET (LOCK_ESCALATION = TABLE)
GO
