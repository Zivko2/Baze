SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO





CREATE PROCEDURE [dbo].[SP_ACTUALIZA_FACTEXPAFECT] (@fe_codigo int)   as

SET NOCOUNT ON 
declare @fe_descargada char(1), @fe_fecha datetime

if exists (select * from factexpent where fed_indiced in (select fed_indiced from factexpdet where fe_codigo=@fe_codigo))
delete from factexpent where fed_indiced in (select fed_indiced from factexpdet where fe_codigo=@fe_codigo)


select @fe_descargada=fe_descargada, @fe_fecha=fe_fecha  from factexp where fe_codigo=@fe_codigo

if @fe_descargada='S'
begin

	--J=Retrabajo, I=Insertos, E=Empaque, R=Retorno, T=Tela
	-- inserta los componentes originarios (empaque originario)
	INSERT INTO FACTEXPENT (FED_INDICED, FEN_FEC_ENT, MA_HIJO, PA_CODIGO, FEN_COS_UNI, FEN_CANT, ME_CODIGO, FEN_TIPO)

	SELECT     dbo.VFACTEXPPEDBase.KAP_INDICED_FACT, MIN(dbo.VFACTEXPPEDBase.KAP_FECHAPED), dbo.VFACTEXPPEDBase.MA_HIJO, 
	                      dbo.VFACTEXPPEDBase.PA_ORIGEN, MIN(dbo.VFACTEXPPEDBase.PID_COS_UNI), SUM(dbo.VFACTEXPPEDBase.KAP_CANTDESCHIJO), 
	                      dbo.VFACTEXPPEDBase.ME_CODIGO, 'E'
	FROM         dbo.VFACTEXPPEDBase LEFT OUTER JOIN
	                      dbo.MAESTRO ON dbo.VFACTEXPPEDBase.MA_HIJO = dbo.MAESTRO.MA_CODIGO LEFT OUTER JOIN
	                      dbo.FACTEXPDET ON dbo.VFACTEXPPEDBase.KAP_INDICED_FACT = dbo.FACTEXPDET.FED_INDICED
	WHERE     (dbo.VFACTEXPPEDBase.KAP_FACTRANS = @fe_codigo) AND (dbo.MAESTRO.TI_CODIGO IN
	                          (SELECT     ti_codigo
	                            FROM          configuratipo
	                            WHERE      cft_tipo = 'E')) AND (dbo.VFACTEXPPEDBase.SPI_CODIGO = 22) AND (dbo.VFACTEXPPEDBase.PID_DEF_TIP = 'P')
	GROUP BY dbo.VFACTEXPPEDBase.KAP_INDICED_FACT, dbo.VFACTEXPPEDBase.MA_HIJO, dbo.VFACTEXPPEDBase.PA_ORIGEN, 
	                      dbo.VFACTEXPPEDBase.ME_CODIGO

	-- inserta los componentes originarios (insertos)
	INSERT INTO FACTEXPENT (FED_INDICED, FEN_FEC_ENT, MA_HIJO, PA_CODIGO, FEN_COS_UNI, FEN_CANT, ME_CODIGO, FEN_TIPO)
	SELECT     dbo.VFACTEXPPEDBase.KAP_INDICED_FACT, MIN(dbo.VFACTEXPPEDBase.KAP_FECHAPED), dbo.VFACTEXPPEDBase.MA_HIJO, 
	                      dbo.VFACTEXPPEDBase.PA_ORIGEN, MIN(dbo.VFACTEXPPEDBase.PID_COS_UNI), SUM(dbo.VFACTEXPPEDBase.KAP_CANTDESCHIJO), 
	                      dbo.VFACTEXPPEDBase.ME_CODIGO, 'I'
	FROM         dbo.VFACTEXPPEDBase LEFT OUTER JOIN
	                      dbo.MAESTRO ON dbo.VFACTEXPPEDBase.MA_HIJO = dbo.MAESTRO.MA_CODIGO LEFT OUTER JOIN
	                      dbo.FACTEXPDET ON dbo.VFACTEXPPEDBase.KAP_INDICED_FACT = dbo.FACTEXPDET.FED_INDICED
	WHERE     (dbo.VFACTEXPPEDBase.KAP_FACTRANS = @fe_codigo) AND (dbo.MAESTRO.TI_CODIGO IN
	                          (SELECT     ti_codigo
	                            FROM          configuratipo
	                            WHERE      cft_tipo <> 'E' and cft_tipo <> 'S' and cft_tipo <> 'P')) AND (dbo.VFACTEXPPEDBase.SPI_CODIGO = 22) AND (dbo.VFACTEXPPEDBase.PID_DEF_TIP = 'P')
		and dbo.VFACTEXPPEDBase.MA_HIJO <>(select ma_codigo from factexpdet where fed_indiced=dbo.VFACTEXPPEDBase.KAP_INDICED_FACT)
	GROUP BY dbo.VFACTEXPPEDBase.KAP_INDICED_FACT, dbo.VFACTEXPPEDBase.MA_HIJO, dbo.VFACTEXPPEDBase.PA_ORIGEN, 
	                      dbo.VFACTEXPPEDBase.ME_CODIGO

	-- inserta los retornos
	INSERT INTO FACTEXPENT (FED_INDICED, FEN_FEC_ENT, MA_HIJO, PA_CODIGO, FEN_COS_UNI, FEN_CANT, ME_CODIGO, FEN_TIPO)
	SELECT     dbo.VFACTEXPPEDBase.KAP_INDICED_FACT, MIN(dbo.VFACTEXPPEDBase.KAP_FECHAPED), dbo.VFACTEXPPEDBase.MA_HIJO, 
	                      dbo.VFACTEXPPEDBase.PA_ORIGEN, MIN(dbo.VFACTEXPPEDBase.PID_COS_UNI), SUM(dbo.VFACTEXPPEDBase.KAP_CANTDESCHIJO), 
	                      dbo.VFACTEXPPEDBase.ME_CODIGO, 'R'
	FROM         dbo.VFACTEXPPEDBase LEFT OUTER JOIN
	                      dbo.MAESTRO ON dbo.VFACTEXPPEDBase.MA_HIJO = dbo.MAESTRO.MA_CODIGO LEFT OUTER JOIN
	                      dbo.FACTEXPDET ON dbo.VFACTEXPPEDBase.KAP_INDICED_FACT = dbo.FACTEXPDET.FED_INDICED
	WHERE     (dbo.VFACTEXPPEDBase.KAP_FACTRANS = @fe_codigo) AND (dbo.MAESTRO.TI_CODIGO IN
	                          (SELECT     ti_codigo
	                            FROM          configuratipo
	                            WHERE     cft_tipo <> 'S' and cft_tipo <> 'P')) AND (dbo.VFACTEXPPEDBase.SPI_CODIGO = 22) AND (dbo.VFACTEXPPEDBase.PID_DEF_TIP = 'P')
		and dbo.VFACTEXPPEDBase.MA_HIJO =(select ma_codigo from factexpdet where fed_indiced=dbo.VFACTEXPPEDBase.KAP_INDICED_FACT)
	GROUP BY dbo.VFACTEXPPEDBase.KAP_INDICED_FACT, dbo.VFACTEXPPEDBase.MA_HIJO, dbo.VFACTEXPPEDBase.PA_ORIGEN, 
	                      dbo.VFACTEXPPEDBase.ME_CODIGO

	-- inserta los retrabajos
	INSERT INTO FACTEXPENT (FED_INDICED, FEN_FEC_ENT, MA_HIJO, PA_CODIGO, FEN_COS_UNI, FEN_CANT, ME_CODIGO, FEN_TIPO)
	SELECT     dbo.VFACTEXPPEDBase.KAP_INDICED_FACT, MIN(dbo.VFACTEXPPEDBase.KAP_FECHAPED), dbo.VFACTEXPPEDBase.MA_HIJO, 
	                      dbo.VFACTEXPPEDBase.PA_ORIGEN, MIN(dbo.VFACTEXPPEDBase.PID_COS_UNI), SUM(dbo.VFACTEXPPEDBase.KAP_CANTDESCHIJO), 
	                      dbo.VFACTEXPPEDBase.ME_CODIGO, 'J'
	FROM         dbo.VFACTEXPPEDBase LEFT OUTER JOIN
	                      dbo.MAESTRO ON dbo.VFACTEXPPEDBase.MA_HIJO = dbo.MAESTRO.MA_CODIGO LEFT OUTER JOIN
	                      dbo.FACTEXPDET ON dbo.VFACTEXPPEDBase.KAP_INDICED_FACT = dbo.FACTEXPDET.FED_INDICED
	WHERE     (dbo.VFACTEXPPEDBase.KAP_FACTRANS = @fe_codigo) AND (dbo.MAESTRO.TI_CODIGO IN
	                          (SELECT     ti_codigo
	                            FROM          configuratipo
	                            WHERE     cft_tipo = 'S' or cft_tipo = 'P')) and dbo.VFACTEXPPEDBase.MA_HIJO =(select ma_codigo from factexpdet where fed_indiced=dbo.VFACTEXPPEDBase.KAP_INDICED_FACT)
		and dbo.VFACTEXPPEDBase.KAP_INDICED_FACT in (select fed_indiced from factexpdet where fed_retrabajo='R' and fe_codigo=@fe_codigo)
	GROUP BY dbo.VFACTEXPPEDBase.KAP_INDICED_FACT, dbo.VFACTEXPPEDBase.MA_HIJO, dbo.VFACTEXPPEDBase.PA_ORIGEN, 
	                      dbo.VFACTEXPPEDBase.ME_CODIGO

	-- inserta los tela
	INSERT INTO FACTEXPENT (FED_INDICED, FEN_FEC_ENT, MA_HIJO, PA_CODIGO, FEN_COS_UNI, FEN_CANT, ME_CODIGO, FEN_TIPO)
	SELECT     dbo.VFACTEXPPEDBase.KAP_INDICED_FACT, min(dbo.VFACTEXPPEDBase.KAP_FECHAPED), dbo.VFACTEXPPEDBase.MA_HIJO, 
	                      dbo.VFACTEXPPEDBase.PA_ORIGEN, min(dbo.VFACTEXPPEDBase.PID_COS_UNI),  SUM(dbo.VFACTEXPPEDBase.KAP_CANTDESCHIJO), 
		dbo.VFACTEXPPEDBase.ME_CODIGO, 'T'
	FROM         dbo.VFACTEXPPEDBase LEFT OUTER JOIN
	                      dbo.MAESTRO ON dbo.VFACTEXPPEDBase.MA_HIJO = dbo.MAESTRO.MA_CODIGO LEFT OUTER JOIN
	                      dbo.FACTEXPDET ON dbo.VFACTEXPPEDBase.KAP_INDICED_FACT = dbo.FACTEXPDET.FED_INDICED LEFT OUTER JOIN
	                      dbo.ARANCEL ON dbo.FACTEXPDET.AR_IMPFO = dbo.ARANCEL.AR_CODIGO
	WHERE (KAP_FACTRANS = @fe_codigo) AND ((dbo.MAESTRO.MA_NOMBRE LIKE 'tela%' OR dbo.MAESTRO.MA_NOMBRE LIKE '%tela%' 
		OR dbo.MAESTRO.MA_NOMBRE LIKE '%tela') and dbo.MAESTRO.TI_CODIGO IN (SELECT ti_codigo 
		FROM configuratipo WHERE cft_tipo <> 'P' and cft_tipo <> 'S')) and dbo.VFACTEXPPEDBase.MA_HIJO not in
		(select MA_HIJO from FACTEXPENT where FED_INDICED=dbo.VFACTEXPPEDBase.KAP_INDICED_FACT)
		and (dbo.MAESTRO.MA_NOMBRE NOT LIKE 'etiqueta%' and dbo.MAESTRO.MA_NOMBRE NOT LIKE '%etiqueta%' 
		and dbo.MAESTRO.MA_NOMBRE NOT LIKE '%etiqueta')
	GROUP BY dbo.VFACTEXPPEDBase.KAP_INDICED_FACT, dbo.VFACTEXPPEDBase.MA_HIJO, 
	                      dbo.VFACTEXPPEDBase.PA_ORIGEN, dbo.VFACTEXPPEDBase.ME_CODIGO

end
else
begin
	if exists (select * from bom_desctemp where fe_codigo=@FE_CODIGO)
	delete from bom_desctemp where fe_codigo=@FE_CODIGO

	EXEC SP_DescExplosionFactExp @FE_CODIGO, 1


	EXEC SP_ACTUALIZATIPOCOSTOBOM_DESCTEMP @FE_CODIGO
	

	-- inserta los componentes originarios (empaque originario)
	INSERT INTO FACTEXPENT (FED_INDICED, FEN_FEC_ENT, MA_HIJO, PA_CODIGO, FEN_COS_UNI, FEN_CANT, ME_CODIGO, FEN_TIPO)
	
	SELECT     dbo.BOM_DESCTEMP.FED_INDICED, (SELECT MIN(PI_FEC_ENT)
	FROM VPEDIMPDESCPOSIBLE WHERE (PI_FEC_ENT <= @fe_fecha) AND (MA_CODIGO = dbo.BOM_DESCTEMP.BST_HIJO)),
	dbo.BOM_DESCTEMP.BST_HIJO, dbo.MAESTRO.PA_ORIGEN, (SELECT MIN(PID_COS_UNI)
	FROM VPEDIMPDESCPOSIBLE WHERE (PI_FEC_ENT <= @fe_fecha) AND (MA_CODIGO = dbo.BOM_DESCTEMP.BST_HIJO)
	AND PI_FEC_ENT IN (SELECT MIN(PI_FEC_ENT)
	FROM VPEDIMPDESCPOSIBLE WHERE (PI_FEC_ENT <= @fe_fecha) AND (MA_CODIGO = dbo.BOM_DESCTEMP.BST_HIJO))),
	(dbo.BOM_DESCTEMP.FED_CANT*dbo.BOM_DESCTEMP.BST_INCORPOR*dbo.BOM_DESCTEMP.FACTCONV), dbo.BOM_DESCTEMP.ME_CODIGO, 'E'
	FROM         dbo.ARANCEL RIGHT OUTER JOIN
	                      dbo.FACTEXPDET ON dbo.ARANCEL.AR_CODIGO = dbo.FACTEXPDET.AR_IMPFO RIGHT OUTER JOIN
	                      dbo.BOM_DESCTEMP ON dbo.FACTEXPDET.FED_INDICED = dbo.BOM_DESCTEMP.FED_INDICED LEFT OUTER JOIN
	                      dbo.MAESTRO ON dbo.BOM_DESCTEMP.BST_HIJO = dbo.MAESTRO.MA_CODIGO
	WHERE (dbo.BOM_DESCTEMP.FE_CODIGO = @fe_codigo) AND dbo.MAESTRO.TI_CODIGO IN (SELECT ti_codigo 
		FROM configuratipo WHERE cft_tipo = 'E') and dbo.BOM_DESCTEMP.BST_TIPOCOSTO='F'
	GROUP BY dbo.BOM_DESCTEMP.FED_INDICED, dbo.BOM_DESCTEMP.BST_HIJO, dbo.MAESTRO.PA_ORIGEN, dbo.MAESTRO.MA_NOMBRE,
	(dbo.BOM_DESCTEMP.FED_CANT*dbo.BOM_DESCTEMP.BST_INCORPOR*dbo.BOM_DESCTEMP.FACTCONV), dbo.BOM_DESCTEMP.ME_CODIGO

	-- inserta los componentes originarios (insertos)
	INSERT INTO FACTEXPENT (FED_INDICED, FEN_FEC_ENT, MA_HIJO, PA_CODIGO, FEN_COS_UNI, FEN_CANT, ME_CODIGO, FEN_TIPO)
	
	SELECT     dbo.BOM_DESCTEMP.FED_INDICED, (SELECT MIN(PI_FEC_ENT)
	FROM VPEDIMPDESCPOSIBLE WHERE (PI_FEC_ENT <= @fe_fecha) AND (MA_CODIGO = dbo.BOM_DESCTEMP.BST_HIJO)),
	dbo.BOM_DESCTEMP.BST_HIJO, dbo.MAESTRO.PA_ORIGEN, (SELECT MIN(PID_COS_UNI)
	FROM VPEDIMPDESCPOSIBLE WHERE (PI_FEC_ENT <= @fe_fecha) AND (MA_CODIGO = dbo.BOM_DESCTEMP.BST_HIJO)
	AND PI_FEC_ENT IN (SELECT MIN(PI_FEC_ENT)
	FROM VPEDIMPDESCPOSIBLE WHERE (PI_FEC_ENT <= @fe_fecha) AND (MA_CODIGO = dbo.BOM_DESCTEMP.BST_HIJO))),
	(dbo.BOM_DESCTEMP.FED_CANT*dbo.BOM_DESCTEMP.BST_INCORPOR*dbo.BOM_DESCTEMP.FACTCONV), dbo.BOM_DESCTEMP.ME_CODIGO, 'I'
	FROM         dbo.ARANCEL RIGHT OUTER JOIN
	                      dbo.FACTEXPDET ON dbo.ARANCEL.AR_CODIGO = dbo.FACTEXPDET.AR_IMPFO RIGHT OUTER JOIN
	                      dbo.BOM_DESCTEMP ON dbo.FACTEXPDET.FED_INDICED = dbo.BOM_DESCTEMP.FED_INDICED LEFT OUTER JOIN
	                      dbo.MAESTRO ON dbo.BOM_DESCTEMP.BST_HIJO = dbo.MAESTRO.MA_CODIGO
	WHERE (dbo.BOM_DESCTEMP.FE_CODIGO = @fe_codigo) AND dbo.MAESTRO.TI_CODIGO IN (SELECT ti_codigo 
		FROM configuratipo WHERE cft_tipo <> 'E' and cft_tipo <> 'P' and cft_tipo <> 'S'  ) and dbo.BOM_DESCTEMP.BST_TIPOCOSTO='C'
		and dbo.BOM_DESCTEMP.BST_HIJO <>(select ma_codigo from factexpdet where fed_indiced=dbo.BOM_DESCTEMP.FED_INDICED)
	GROUP BY dbo.BOM_DESCTEMP.FED_INDICED, dbo.BOM_DESCTEMP.BST_HIJO, dbo.MAESTRO.PA_ORIGEN, dbo.MAESTRO.MA_NOMBRE,
	(dbo.BOM_DESCTEMP.FED_CANT*dbo.BOM_DESCTEMP.BST_INCORPOR*dbo.BOM_DESCTEMP.FACTCONV), dbo.BOM_DESCTEMP.ME_CODIGO


	-- inserta los retornos
	INSERT INTO FACTEXPENT (FED_INDICED, FEN_FEC_ENT, MA_HIJO, PA_CODIGO, FEN_COS_UNI, FEN_CANT, ME_CODIGO, FEN_TIPO)
	
	SELECT     dbo.BOM_DESCTEMP.FED_INDICED, (SELECT MIN(PI_FEC_ENT)
	FROM VPEDIMPDESCPOSIBLE WHERE (PI_FEC_ENT <= @fe_fecha) AND (MA_CODIGO = dbo.BOM_DESCTEMP.BST_HIJO)),
	dbo.BOM_DESCTEMP.BST_HIJO, dbo.MAESTRO.PA_ORIGEN, (SELECT MIN(PID_COS_UNI)
	FROM VPEDIMPDESCPOSIBLE WHERE (PI_FEC_ENT <= @fe_fecha) AND (MA_CODIGO = dbo.BOM_DESCTEMP.BST_HIJO)
	AND PI_FEC_ENT IN (SELECT MIN(PI_FEC_ENT)
	FROM VPEDIMPDESCPOSIBLE WHERE (PI_FEC_ENT <= @fe_fecha) AND (MA_CODIGO = dbo.BOM_DESCTEMP.BST_HIJO))),
	(dbo.BOM_DESCTEMP.FED_CANT*dbo.BOM_DESCTEMP.BST_INCORPOR*dbo.BOM_DESCTEMP.FACTCONV), dbo.BOM_DESCTEMP.ME_CODIGO, 'R'
	FROM         dbo.ARANCEL RIGHT OUTER JOIN
	                      dbo.FACTEXPDET ON dbo.ARANCEL.AR_CODIGO = dbo.FACTEXPDET.AR_IMPFO RIGHT OUTER JOIN
	                      dbo.BOM_DESCTEMP ON dbo.FACTEXPDET.FED_INDICED = dbo.BOM_DESCTEMP.FED_INDICED LEFT OUTER JOIN
	                      dbo.MAESTRO ON dbo.BOM_DESCTEMP.BST_HIJO = dbo.MAESTRO.MA_CODIGO
	WHERE (dbo.BOM_DESCTEMP.FE_CODIGO = @fe_codigo) AND dbo.MAESTRO.TI_CODIGO IN (SELECT ti_codigo 
		FROM configuratipo WHERE cft_tipo <> 'E' and cft_tipo <> 'P' and cft_tipo <> 'S'  ) and dbo.BOM_DESCTEMP.BST_TIPOCOSTO='C'
		and dbo.BOM_DESCTEMP.BST_HIJO in (select ma_codigo from factexpdet where fed_indiced=dbo.BOM_DESCTEMP.FED_INDICED)
	GROUP BY dbo.BOM_DESCTEMP.FED_INDICED, dbo.BOM_DESCTEMP.BST_HIJO, dbo.MAESTRO.PA_ORIGEN, dbo.MAESTRO.MA_NOMBRE,
	(dbo.BOM_DESCTEMP.FED_CANT*dbo.BOM_DESCTEMP.BST_INCORPOR*dbo.BOM_DESCTEMP.FACTCONV), dbo.BOM_DESCTEMP.ME_CODIGO


	INSERT INTO FACTEXPENT (FED_INDICED, FEN_FEC_ENT, MA_HIJO, PA_CODIGO, FEN_COS_UNI, FEN_CANT, ME_CODIGO, FEN_TIPO)
	
	SELECT     dbo.BOM_DESCTEMP.FED_INDICED, (SELECT MIN(PI_FEC_ENT)
	FROM VPEDIMPDESCPOSIBLE WHERE (PI_FEC_ENT <= @fe_fecha) AND (MA_CODIGO = dbo.BOM_DESCTEMP.BST_HIJO)),
	dbo.BOM_DESCTEMP.BST_HIJO, dbo.MAESTRO.PA_ORIGEN, (SELECT MIN(PID_COS_UNI)
	FROM VPEDIMPDESCPOSIBLE WHERE (PI_FEC_ENT <= @fe_fecha) AND (MA_CODIGO = dbo.BOM_DESCTEMP.BST_HIJO)
	AND PI_FEC_ENT IN (SELECT MIN(PI_FEC_ENT)
	FROM VPEDIMPDESCPOSIBLE WHERE (PI_FEC_ENT <= @fe_fecha) AND (MA_CODIGO = dbo.BOM_DESCTEMP.BST_HIJO))),
	(dbo.BOM_DESCTEMP.FED_CANT*dbo.BOM_DESCTEMP.BST_INCORPOR*dbo.BOM_DESCTEMP.FACTCONV), dbo.BOM_DESCTEMP.ME_CODIGO, 'J'
	FROM         dbo.ARANCEL RIGHT OUTER JOIN
	                      dbo.FACTEXPDET ON dbo.ARANCEL.AR_CODIGO = dbo.FACTEXPDET.AR_IMPFO RIGHT OUTER JOIN
	                      dbo.BOM_DESCTEMP ON dbo.FACTEXPDET.FED_INDICED = dbo.BOM_DESCTEMP.FED_INDICED LEFT OUTER JOIN
	                      dbo.MAESTRO ON dbo.BOM_DESCTEMP.BST_HIJO = dbo.MAESTRO.MA_CODIGO
	WHERE (dbo.BOM_DESCTEMP.FE_CODIGO = @fe_codigo) AND dbo.MAESTRO.TI_CODIGO IN (SELECT ti_codigo 
		FROM configuratipo WHERE cft_tipo = 'P' or cft_tipo = 'S'  ) 
		and dbo.BOM_DESCTEMP.BST_HIJO in (select ma_codigo from factexpdet where fed_indiced=dbo.BOM_DESCTEMP.FED_INDICED)
		and dbo.BOM_DESCTEMP.FED_INDICED in (select fed_indiced from factexpdet where fed_retrabajo='R' and fe_codigo=@fe_codigo)
	GROUP BY dbo.BOM_DESCTEMP.FED_INDICED, dbo.BOM_DESCTEMP.BST_HIJO, dbo.MAESTRO.PA_ORIGEN, dbo.MAESTRO.MA_NOMBRE,
	(dbo.BOM_DESCTEMP.FED_CANT*dbo.BOM_DESCTEMP.BST_INCORPOR*dbo.BOM_DESCTEMP.FACTCONV), dbo.BOM_DESCTEMP.ME_CODIGO

	-- inserta la tela
	INSERT INTO FACTEXPENT (FED_INDICED, FEN_FEC_ENT, MA_HIJO, PA_CODIGO, FEN_PAISLETRA, FEN_COS_UNI, FEN_CANT, ME_CODIGO, FEN_TIPO)
	SELECT     dbo.BOM_DESCTEMP.FED_INDICED, (SELECT MIN(PI_FEC_ENT)
	FROM VPEDIMPDESCPOSIBLE WHERE (PI_FEC_ENT <= @fe_fecha) AND (MA_CODIGO = dbo.BOM_DESCTEMP.BST_HIJO)),
	dbo.BOM_DESCTEMP.BST_HIJO, dbo.MAESTRO.PA_ORIGEN, letra=case when dbo.MAESTRO.PA_ORIGEN in (select cf_pais_usa from configuracion)
	then 'B' when dbo.MAESTRO.PA_ORIGEN in (select cf_pais_mx from configuracion) then 'A' 
	when dbo.MAESTRO.PA_ORIGEN in (select cf_pais_ca from configuracion) then 'C' else '' end, (SELECT MIN(PID_COS_UNI)
	FROM VPEDIMPDESCPOSIBLE WHERE (PI_FEC_ENT <= @fe_fecha) AND (MA_CODIGO = dbo.BOM_DESCTEMP.BST_HIJO)
	AND PI_FEC_ENT IN (SELECT MIN(PI_FEC_ENT)
	FROM VPEDIMPDESCPOSIBLE WHERE (PI_FEC_ENT <= @fe_fecha) AND (MA_CODIGO = dbo.BOM_DESCTEMP.BST_HIJO))),
	(dbo.BOM_DESCTEMP.FED_CANT*dbo.BOM_DESCTEMP.BST_INCORPOR*dbo.BOM_DESCTEMP.FACTCONV), dbo.BOM_DESCTEMP.ME_CODIGO, 'T'
	FROM         dbo.ARANCEL RIGHT OUTER JOIN
	                      dbo.FACTEXPDET ON dbo.ARANCEL.AR_CODIGO = dbo.FACTEXPDET.AR_IMPFO RIGHT OUTER JOIN
	                      dbo.BOM_DESCTEMP ON dbo.FACTEXPDET.FED_INDICED = dbo.BOM_DESCTEMP.FED_INDICED LEFT OUTER JOIN
	                      dbo.MAESTRO ON dbo.BOM_DESCTEMP.BST_HIJO = dbo.MAESTRO.MA_CODIGO
	WHERE (dbo.BOM_DESCTEMP.FE_CODIGO = @fe_codigo) AND ((dbo.MAESTRO.MA_NOMBRE LIKE 'tela%' OR dbo.MAESTRO.MA_NOMBRE LIKE '%tela%' 
		OR dbo.MAESTRO.MA_NOMBRE LIKE '%tela') and dbo.MAESTRO.TI_CODIGO IN (SELECT ti_codigo 
		FROM configuratipo WHERE cft_tipo <> 'P' and cft_tipo <> 'S') and (dbo.MAESTRO.MA_NOMBRE NOT LIKE 'etiqueta%' and dbo.MAESTRO.MA_NOMBRE NOT LIKE '%etiqueta%' 
		and dbo.MAESTRO.MA_NOMBRE NOT LIKE '%etiqueta'))
	GROUP BY dbo.BOM_DESCTEMP.FED_INDICED, dbo.BOM_DESCTEMP.BST_HIJO, dbo.MAESTRO.PA_ORIGEN, dbo.MAESTRO.MA_NOMBRE,
	(dbo.BOM_DESCTEMP.FED_CANT*dbo.BOM_DESCTEMP.BST_INCORPOR*dbo.BOM_DESCTEMP.FACTCONV), dbo.BOM_DESCTEMP.ME_CODIGO

end






































GO
