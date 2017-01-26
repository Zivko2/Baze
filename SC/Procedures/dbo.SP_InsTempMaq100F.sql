SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO





CREATE PROCEDURE dbo.SP_InsTempMaq100F
	(
		@vNoOrden varchar(20),
		@vNoCatalogo varchar(20),
		@vDescripcion varchar(30),
		@fCantidad decimal(38,6),
		@vUM varchar(5),
		@vLocalizacion varchar(5),
		@dtFechaOrdCerrada datetime,
		@dtFechaOrdVencimiento datetime,
		@dtFechaOrdEntrada datetime,
		@fCostoStd decimal(38,6),
		@vFacturaQ2C varchar (15)
	)
AS
INSERT TempMaq100F (NoOrden, NoCatalogo, Descripcion, Cantidad, UM, Localizacion, FechaOrdCerrada, FechaOrdVencimiento, FechaOrdEntrada, CostoStd, FacturaQ2C)
VALUES(@vNoOrden, @vNoCatalogo, @vDescripcion, @fCantidad, @vUM, @vLocalizacion, @dtFechaOrdCerrada, @dtFechaOrdVencimiento, @dtFechaOrdEntrada, @fCostoStd, @vFacturaQ2C)




GO
