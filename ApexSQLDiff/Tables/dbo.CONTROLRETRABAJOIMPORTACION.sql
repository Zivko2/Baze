SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[CONTROLRETRABAJOIMPORTACION] (
		[CRI_Codigo]                    [int] IDENTITY(1, 1) NOT NULL,
		[CRI_NoPartePT]                 [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CRI_NoParteAuxPT]              [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CRI_NoParteComponente]         [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CRI_NoParteAuxComponente]      [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CRI_CantidadIncorporacion]     [decimal](38, 6) NULL,
		[CRI_CantidadDescargar]         [decimal](38, 6) NULL,
		[CRI_Fecha]                     [datetime] NULL,
		[MA_CodigoEspecial]             [int] NULL,
		CONSTRAINT [IX_CONTROLRETRABAJOIMPORTACION]
		UNIQUE
		NONCLUSTERED
		([CRI_Codigo])
		ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CONTROLRETRABAJOIMPORTACION]
	ADD
	CONSTRAINT [PK_CONTROLRETRABAJOIMPORTACION]
	PRIMARY KEY
	CLUSTERED
	([CRI_Codigo])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[CONTROLRETRABAJOIMPORTACION] SET (LOCK_ESCALATION = TABLE)
GO
