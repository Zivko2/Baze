SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[RUTAPROCESO] (
		[RUT_CODIGO]        [int] NULL,
		[PRC_CODIGO]        [int] NOT NULL,
		[RUT_SECUENCIA]     [smallint] NULL,
		[RUT_HORASST]       [decimal](38, 6) NULL,
		[MA_CODIGO]         [int] NULL,
		[RUT_NOPARTE]       [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[RUT_INCORPOR]      [decimal](38, 6) NULL,
		[ME_CODIGO]         [int] NULL,
		[ME_GEN]            [int] NULL,
		[FACTCONV]          [decimal](28, 14) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[RUTAPROCESO] SET (LOCK_ESCALATION = TABLE)
GO
