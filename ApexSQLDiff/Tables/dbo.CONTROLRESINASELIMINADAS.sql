SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[CONTROLRESINASELIMINADAS] (
		[CRE_Codigo]               [int] IDENTITY(1, 1) NOT NULL,
		[MA_CodigoOrigen]          [int] NULL,
		[MA_CodigoDestino]         [int] NULL,
		[CRE_FechaInicial]         [datetime] NULL,
		[CRE_FechaFinal]           [datetime] NULL,
		[TI_CodigoOrigen]          [int] NULL,
		[TI_CodigoDestino]         [int] NULL,
		[MA_Tip_EnsDestino]        [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CRE_FechaEliminacion]     [datetime] NULL,
		CONSTRAINT [IX_CONTROLRESINASELIMINADAS]
		UNIQUE
		NONCLUSTERED
		([CRE_Codigo])
		ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CONTROLRESINASELIMINADAS]
	ADD
	CONSTRAINT [PK_CONTROLRESINASELIMINADAS]
	PRIMARY KEY
	CLUSTERED
	([CRE_Codigo])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[CONTROLRESINASELIMINADAS] SET (LOCK_ESCALATION = TABLE)
GO
