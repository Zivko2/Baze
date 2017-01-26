SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[CONTROLRESINAS] (
		[CRS_Codigo]            [int] IDENTITY(1, 1) NOT NULL,
		[MA_CodigoOrigen]       [int] NOT NULL,
		[MA_CodigoDestino]      [int] NOT NULL,
		[CRS_FechaInicial]      [datetime] NOT NULL,
		[CRS_FechaFinal]        [datetime] NOT NULL,
		[TI_CodigoOrigen]       [int] NULL,
		[TI_CodigoDestino]      [int] NULL,
		[MA_Tip_EnsDestino]     [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		CONSTRAINT [IX_ControlResinas]
		UNIQUE
		NONCLUSTERED
		([CRS_Codigo])
		ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CONTROLRESINAS]
	ADD
	CONSTRAINT [PK_ControlResinas]
	PRIMARY KEY
	CLUSTERED
	([CRS_Codigo])
	ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_ControlResinas_1]
	ON [dbo].[CONTROLRESINAS] ([MA_CodigoOrigen], [MA_CodigoDestino], [CRS_FechaInicial], [CRS_FechaFinal])
	ON [PRIMARY]
GO
