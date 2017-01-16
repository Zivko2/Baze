SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO



-- procedimiento de seleccion por rango para ejecutable de descargas
CREATE PROCEDURE dbo.SP_descargaRango  (@FolioIni sysname, @FolioFin sysname)   as

SET NOCOUNT ON 

declare @fecodigoini integer,@fecodigofin integer, @fechaini datetime, @fechafin datetime,
        @sizeini integer,@sizefin integer, @Folioini2 sysname, @CF_TIPODESCCAMBIOREG char(1)

	select @fecodigoini=fe_codigo from factexp where fe_folio=@folioini
	select @fecodigofin=fe_codigo from factexp where fe_folio=@foliofin
	select @fechaini= min(fe_fecha) from factexp where fe_codigo=@fecodigoini
	select @fechafin= max(fe_fecha) from factexp where fe_codigo=@fecodigofin


	SELECT @CF_TIPODESCCAMBIOREG = CF_TIPODESCCAMBIOREG
	FROM         dbo.CONFIGURACION

	set @sizeini = len(@folioini)
	set @sizefin =len(@foliofin)

	if @sizefin>@sizeini
	begin
		set @folioini2=replicate('0', @sizefin-@sizeini)+@folioini
	end
	else
		set @folioini2=@folioini


		SELECT     dbo.FACTEXP.FE_CODIGO, dbo.CONFIGURATFACT.CFF_TIPO
		FROM         dbo.CONFIGURATFACT RIGHT OUTER JOIN
		                      dbo.FACTEXP ON dbo.CONFIGURATFACT.TF_CODIGO = dbo.FACTEXP.TF_CODIGO LEFT OUTER JOIN
		                      dbo.CONFIGURATIPO RIGHT OUTER JOIN
		                      dbo.FACTEXPDET ON dbo.CONFIGURATIPO.TI_CODIGO = dbo.FACTEXPDET.TI_CODIGO ON 
		                      dbo.FACTEXP.FE_CODIGO = dbo.FACTEXPDET.FE_CODIGO
		GROUP BY dbo.FACTEXP.FE_CODIGO, dbo.FACTEXP.FE_FECHA, dbo.FACTEXP.FE_FOLIO, dbo.CONFIGURATFACT.CFF_TIPO, dbo.FACTEXP.FE_CANCELADO, 
		                      dbo.FACTEXP.FE_DESCARGADA, dbo.CONFIGURATFACT.CFF_TRAT, dbo.CONFIGURATFACT.CFF_TIPODESCARGA
		HAVING      (dbo.FACTEXP.FE_CANCELADO = 'N') AND (dbo.FACTEXP.FE_DESCARGADA = 'N') AND (dbo.CONFIGURATFACT.CFF_TRAT = 'D') AND 
		                      (dbo.CONFIGURATFACT.CFF_TIPODESCARGA = 'A') and (dbo.FACTEXP.FE_FOLIO >= @folioini2) AND (dbo.FACTEXP.FE_FOLIO <= @foliofin)
			and (dbo.FACTEXP.FE_FECHA >= @fechaini) AND (dbo.FACTEXP.FE_FECHA <= @fechafin)
		ORDER BY dbo.FACTEXP.FE_FECHA, dbo.FACTEXP.FE_FOLIO, dbo.FACTEXP.FE_CODIGO



























GO
