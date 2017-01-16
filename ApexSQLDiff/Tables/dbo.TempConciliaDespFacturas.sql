SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[TempConciliaDespFacturas] (
		[RE_INDICER]            [int] NULL,
		[TIPO_FACTRANS]         [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[FETR_CODIGO]           [int] NOT NULL,
		[FETR_INDICED]          [int] NOT NULL,
		[MA_HIJO]               [int] NOT NULL,
		[RE_NOPARTE]            [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[RE_INCORPOR]           [decimal](38, 6) NULL,
		[TI_HIJO]               [smallint] NULL,
		[ME_CODIGO]             [int] NULL,
		[MA_GENERICO]           [int] NULL,
		[ME_GEN]                [int] NULL,
		[RE_INCORPORGEN]        [decimal](38, 6) NULL,
		[FACTCONV]              [decimal](28, 14) NULL,
		[FETR_RETRABAJODES]     [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[FETR_NAFTA]            [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[PA_ORIGEN]             [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TempConciliaDespFacturas] SET (LOCK_ESCALATION = TABLE)
GO
