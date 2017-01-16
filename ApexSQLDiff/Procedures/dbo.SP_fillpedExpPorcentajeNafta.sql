SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SP_fillpedExpPorcentajeNafta] (@picodigo int)   as

SET NOCOUNT ON 
declare 	@porcentajenonafta decimal(38,6), @foraneo decimal(38,6), @todo decimal(38,6), @porcentajenafta decimal(38,6)


if exists (SELECT    *  FROM         dbo.FACTEXP LEFT OUTER JOIN
                      dbo.FACTEXPDET ON dbo.FACTEXP.FE_CODIGO = dbo.FACTEXPDET.FE_CODIGO LEFT OUTER JOIN
                      dbo.DIR_CLIENTE ON dbo.FACTEXP.DI_DESTFIN = dbo.DIR_CLIENTE.DI_INDICE RIGHT OUTER JOIN
                      dbo.PEDIMP ON dbo.FACTEXP.PI_CODIGO = dbo.PEDIMP.PI_CODIGO
WHERE     (dbo.PEDIMP.PI_CODIGO = @picodigo))

begin
	--TODO
	SELECT     @TODO=SUM(ISNULL(dbo.FACTEXPDET.FED_COS_TOT, 0)) 
	FROM         dbo.FACTEXP LEFT OUTER JOIN
	                      dbo.FACTEXPDET ON dbo.FACTEXP.FE_CODIGO = dbo.FACTEXPDET.FE_CODIGO LEFT OUTER JOIN
	                      dbo.DIR_CLIENTE ON dbo.FACTEXP.DI_DESTFIN = dbo.DIR_CLIENTE.DI_INDICE RIGHT OUTER JOIN
	                      dbo.PEDIMP ON dbo.FACTEXP.PI_CODIGO = dbo.PEDIMP.PI_CODIGO
	WHERE     (dbo.PEDIMP.PI_CODIGO = @picodigo)
	
	
	--FORANEO
	SELECT     @FORANEO=SUM(ISNULL(dbo.FACTEXPDET.FED_COS_TOT, 0)) 
	FROM         dbo.FACTEXP LEFT OUTER JOIN
	                      dbo.FACTEXPDET ON dbo.FACTEXP.FE_CODIGO = dbo.FACTEXPDET.FE_CODIGO LEFT OUTER JOIN
	                      dbo.DIR_CLIENTE ON dbo.FACTEXP.DI_DESTFIN = dbo.DIR_CLIENTE.DI_INDICE RIGHT OUTER JOIN
	                      dbo.PEDIMP ON dbo.FACTEXP.PI_CODIGO = dbo.PEDIMP.PI_CODIGO
	WHERE     (dbo.DIR_CLIENTE.PA_CODIGO NOT IN
	                          (SELECT     CF_PAIS_MX
	                            FROM          CONFIGURACION) OR
	                      dbo.DIR_CLIENTE.PA_CODIGO NOT IN
	                          (SELECT     CF_PAIS_USA
	                            FROM          CONFIGURACION) OR
	                      dbo.DIR_CLIENTE.PA_CODIGO NOT IN
	                          (SELECT     CF_PAIS_CA
	                            FROM          CONFIGURACION)) AND (dbo.PEDIMP.PI_CODIGO = @picodigo)

		set @porcentajenonafta=(@foraneo*100)/@todo
		set @porcentajenafta=100-@porcentajenonafta
	
		update pedimp
		set pi_porcennafta=@porcentajenafta
		where pi_codigo=@picodigo
end



GO
