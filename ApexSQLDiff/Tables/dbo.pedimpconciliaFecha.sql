SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[pedimpconciliaFecha] (
		[Pedimento]     [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[TipoFecha]     [varchar](8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Fecha]         [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[pedimpconciliaFecha] SET (LOCK_ESCALATION = TABLE)
GO
