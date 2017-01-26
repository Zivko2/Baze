SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING OFF
GO
CREATE TABLE [dbo].[CONTROLRETRABAJO] (
		[CR_Codigo]             [int] IDENTITY(1, 1) NOT NULL,
		[CR_Fecha]              [datetime] NOT NULL,
		[CR_Cantidad]           [decimal](38, 6) NOT NULL,
		[CR_Saldo]              [decimal](38, 6) NOT NULL,
		[MA_Codigo]             [int] NOT NULL,
		[MA_CodigoEspecial]     [int] NULL,
		[CR_FechaDescarga]      [datetime] NULL,
		CONSTRAINT [IX_CONTROLRETRABAJO]
		UNIQUE
		NONCLUSTERED
		([CR_Codigo])
		ON [PRIMARY],
		CONSTRAINT [IX_CONTROLRETRABAJO_1]
		UNIQUE
		NONCLUSTERED
		([CR_Fecha], [MA_Codigo])
		ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CONTROLRETRABAJO]
	ADD
	CONSTRAINT [PK_CONTROLRETRABAJO]
	PRIMARY KEY
	CLUSTERED
	([CR_Codigo])
	ON [PRIMARY]
GO
