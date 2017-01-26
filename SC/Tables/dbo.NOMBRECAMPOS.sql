SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[NOMBRECAMPOS] (
		[Tabla]                 [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[NombreAnterior]        [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[NombreNuevo]           [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[TipoActualizacion]     [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[NOMBRECAMPOS]
	ADD
	CONSTRAINT [PK_NombreCampos]
	PRIMARY KEY
	NONCLUSTERED
	([Tabla], [NombreAnterior], [NombreNuevo], [TipoActualizacion])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[NOMBRECAMPOS]
	ADD
	CONSTRAINT [DF_NOMBRECAMPOS_NombreAnterior]
	DEFAULT ('') FOR [NombreAnterior]
GO
ALTER TABLE [dbo].[NOMBRECAMPOS]
	ADD
	CONSTRAINT [DF_NOMBRECAMPOS_NombreNuevo]
	DEFAULT ('') FOR [NombreNuevo]
GO
