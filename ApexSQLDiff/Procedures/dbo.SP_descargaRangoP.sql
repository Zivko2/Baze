SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

-- procedimiento de seleccion por rango pedimento para ejecutable de descargas
CREATE PROCEDURE dbo.SP_descargaRangoP (@FolioIni sysname, @FolioFin sysname)   as

SET NOCOUNT ON 

declare @fecodigoini integer, @fecodigofin integer, @fechaini datetime, @fechafin datetime,
        @sizeini integer, @sizefin integer, @folioini2 sysname

	select @fecodigoini=pi_codigo from vpedexp where [patente-folio]=@folioini
	select @fecodigofin=pi_codigo from vpedexp where [patente-folio]=@foliofin
	select @fechaini= min(pi_fec_ent) from vpedexp where pi_codigo=@fecodigoini
	select @fechafin= max(pi_fec_ent) from vpedexp where pi_codigo=@fecodigofin


	set @sizeini = len(@folioini)
	set @sizefin =len(@foliofin)

	if @sizefin>@sizeini
	begin
		set @folioini2=replicate('0', @sizefin-@sizeini)+@folioini
	end
	else
		set @folioini2=@folioini


		SELECT     dbo.FACTEXP.FE_CODIGO, dbo.CONFIGURATFACT.CFF_TIPO
		FROM         dbo.FACTEXP LEFT OUTER JOIN
		                      dbo.VPEDEXP ON dbo.FACTEXP.PI_CODIGO = dbo.VPEDEXP.PI_CODIGO LEFT OUTER JOIN
		                      dbo.CONFIGURATFACT ON dbo.FACTEXP.TF_CODIGO = dbo.CONFIGURATFACT.TF_CODIGO LEFT OUTER JOIN
		                      dbo.FACTEXPDET ON dbo.FACTEXP.FE_CODIGO = dbo.FACTEXPDET.FE_CODIGO LEFT OUTER JOIN
		                      dbo.CONFIGURATIPO ON dbo.FACTEXPDET.TI_CODIGO = dbo.CONFIGURATIPO.TI_CODIGO
		WHERE      (dbo.FACTEXP.FE_CANCELADO = 'N') AND (dbo.FACTEXP.FE_DESCARGADA = 'N') 
				AND (dbo.CONFIGURATFACT.CFF_TRAT = 'D') AND (dbo.CONFIGURATFACT.CFF_TIPODESCARGA = 'A') and (dbo.VPEDEXP.PI_FEC_ENT >= @fechaini) AND (dbo.VPEDEXP.PI_FEC_ENT <= @fechafin)
		GROUP BY dbo.FACTEXP.FE_CODIGO, dbo.VPEDEXP.PI_FEC_ENT, dbo.CONFIGURATFACT.CFF_TIPO, dbo.FACTEXP.FE_CANCELADO, 
		                      dbo.FACTEXP.FE_DESCARGADA, dbo.CONFIGURATFACT.CFF_TRAT, dbo.CONFIGURATFACT.CFF_TIPODESCARGA
		ORDER BY dbo.VPEDEXP.PI_FEC_ENT, dbo.FACTEXP.FE_CODIGO



























GO
