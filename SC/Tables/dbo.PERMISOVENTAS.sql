SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING OFF
GO
CREATE TABLE [dbo].[PERMISOVENTAS] (
		[PE_CODIGO]         [int] NOT NULL,
		[PV_ANIO_OPER]      [smallint] NOT NULL,
		[PV_VTPESOS]        [decimal](38, 6) NULL,
		[PV_VTDOLARES]      [decimal](38, 6) NULL,
		[PV_EXPORTA]        [decimal](38, 6) NULL,
		[PV_IMPORTA]        [decimal](38, 6) NULL,
		[PV_PORCE_EXP]      [decimal](38, 6) NULL,
		[PV_TIPO_CAM]       [decimal](38, 6) NULL,
		[PV_INSUEMPNAC]     [decimal](38, 6) NULL,
		[PV_INSUEMPEXT]     [decimal](38, 6) NULL,
		[PV_VALORAGRE]      [decimal](38, 6) NULL,
		[PV_VALOREXPO]      [decimal](38, 6) NULL,
		[PV_TIPO_EXP]       [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PERMISOVENTAS]
	ADD
	CONSTRAINT [PK_PERMISOVENTAS_1]
	PRIMARY KEY
	NONCLUSTERED
	([PE_CODIGO], [PV_ANIO_OPER])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_PERMISOVENTAS]
	ON [dbo].[PERMISOVENTAS] ([PE_CODIGO])
	ON [PRIMARY]
GO
