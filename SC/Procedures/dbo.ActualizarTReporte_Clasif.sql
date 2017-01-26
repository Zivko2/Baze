SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [ActualizarTReporte_Clasif]   as

update TReporte set TRE_ReporteClasif = A.CR_Codigo
from TReporte
	inner join
		(select original.dbo.TReporte.tre_nombre, original.dbo.TReporte.TRE_Nombre_RTM, original.dbo.TReporte.TRE_ReporteClasif,  original.dbo.TReporteClasif.CR_Codigo Original, original.dbo.TReporteClasif.CR_Descripcion,
			TReporteClasif.CR_Codigo
		from original.dbo.TReporteClasif
			left outer join TReporteClasif on original.dbo.TReporteClasif.CR_Descripcion = TReporteClasif.CR_Descripcion 
					and original.dbo.TReporteClasif.CR_Forma = TReporteClasif.CR_Forma
			left outer join original.dbo.TReporte on original.dbo.TReporteClasif.cr_codigo = original.dbo.TReporte.tre_reporteClasif
		
		where original.dbo.TReporte.tre_nombre is not null) A
	on TReporte.TRE_Nombre = A.TRE_Nombre and TReporte.TRE_Nombre_RTM = A.TRE_Nombre_RTM

GO
