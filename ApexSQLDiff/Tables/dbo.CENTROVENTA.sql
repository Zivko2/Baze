SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[CENTROVENTA] (
		[CAV_CODIGO]      [int] NULL,
		[CAV_CORTO]       [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CAV_NOMBRE]      [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[ALM_SURTIDO]     [int] NULL,
		[CAV_OBSERVA]     [varchar](1100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[TCO_CODIGO]      [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CENTROVENTA] SET (LOCK_ESCALATION = TABLE)
GO
