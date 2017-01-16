SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SP_ACTUALIZATIPOCOSTOBOMREP] (@spi_codigo int, @bst_pt int)    as

SET NOCOUNT ON 


	exec sp_droptable 'TempBomGravableRep'


	exec sp_droptable 'TempPaisTLC'

	select pa_codigo 
	into dbo.TempPaisTLC
	from pais where spi_codigo=@spi_codigo and pa_codigo<>233
	
	if (SELECT CF_CONFERIRORIGEN FROM CONFIGURACION)='C' 
	begin
		SELECT  BOM_REP.BST_CODIGO, 
		esGravable=case when (bst_trans = 'N') and bst_hijo in (SELECT CERTORIGMPDET.MA_CODIGO
					         FROM  CERTORIGMPDET INNER JOIN CERTORIGMP ON CERTORIGMPDET.CMP_CODIGO = CERTORIGMP.CMP_CODIGO 
					         WHERE CERTORIGMP.SPI_CODIGO = @spi_codigo and CERTORIGMPDET.PA_CLASE=pa_codigo and LEFT(REPLACE(CERTORIGMPDET.CMP_FRACCION,'.',''),6)=LEFT(REPLACE(ISNULL((SELECT AR_FRACCION FROM ARANCEL WHERE AR_CODIGO=MAESTRO.AR_EXPMX), (SELECT AR_FRACCION FROM ARANCEL WHERE AR_CODIGO=MAESTRO.AR_IMPMX)),'.',''),6)
						 AND CERTORIGMP.CMP_ESTATUS='V' AND CERTORIGMP.CMP_IFECHA <= getdate() AND CERTORIGMP.CMP_VFECHA >= getdate()) then
	  				         (case when pa_codigo in (SELECT pa_codigo FROM TempPaisTLC) then
						(case when maestro.ma_consta='S'/*pa_codigo in (select cf_pais_mx from configuracion)*/ then 'Z' else 'X' end) else 'N' end) else (case when ma_servicio='S' then 'X' else 'S' end) end,
		esAnadido=case when MAESTRO.MA_REPARA <>'A' then 'N' else 'S' end,
			esMP=case when BOM_REP.TI_CODIGO in ('R', 'L', 'M', 'O') or (BOM_REP.TI_CODIGO ='S' and BOM_REP.MA_TIP_ENS='C') then 'S' else 'N' end,
			esSUB=case when BOM_REP.TI_CODIGO ='S' and BOM_REP.MA_TIP_ENS<>'C' then 'S' else 'N' end, 'Z' as bst_tipocosto
			into dbo.TempBomGravableRep
			FROM         BOM_REP INNER JOIN
			                      MAESTRO ON BOM_REP.BST_HIJO = MAESTRO.MA_CODIGO 
			WHERE BOM_REP.BST_PT=@bst_pt
		
	end
	else
	begin

		SELECT  BOM_REP.BST_CODIGO, 
		esGravable=CASE WHEN  bst_trans = 'N'  and (MAESTRO.ma_def_tip='P' and MAESTRO.spi_codigo=@spi_codigo) then
		(case when BOM_REP.pa_codigo in (SELECT pa_codigo FROM TempPaisTLC) then
		  (case when maestro.ma_consta='S'/*pa_codigo in (select cf_pais_mx from configuracion)*/ then 'Z' else 'X' end) else 'N' end) 
		else
		(case when MAESTRO.ma_servicio='S' then 'X' else 'S' end)
		end, esAnadido=case when MAESTRO.MA_REPARA <>'A' then 'N' else 'S' end,
		esMP=case when BOM_REP.TI_CODIGO in ('R', 'L', 'M', 'O') or (BOM_REP.TI_CODIGO ='S' and BOM_REP.MA_TIP_ENS='C') then 'S' else 'N' end,
		esSUB=case when BOM_REP.TI_CODIGO ='S' and BOM_REP.MA_TIP_ENS<>'C' then 'S' else 'N' end, 'Z' as bst_tipocosto
		into dbo.TempBomGravableRep
		FROM         BOM_REP INNER JOIN
		                      MAESTRO ON BOM_REP.BST_HIJO = MAESTRO.MA_CODIGO 
		WHERE BOM_REP.BST_PT=@bst_pt	
	end
	


		/* Se asigna el tipo de costo */   

	update TempBomGravableRep
	set bst_tipocosto='A'
	where esMP = 'S' and esGravable = 'S' and esAnadido = 'N' 
	
	
	update TempBomGravableRep
	set bst_tipocosto='B'
	where esMP = 'S' and esGravable = 'S' and esAnadido = 'S' 
	
	
	update TempBomGravableRep
	set bst_tipocosto='C'
	where esMP = 'S' and esGravable = 'N' and esAnadido = 'N' 
	
	
	update TempBomGravableRep
	set bst_tipocosto='D'
	where esMP = 'S' and esGravable = 'N' and esAnadido = 'S' 
	
	
	update TempBomGravableRep
	set bst_tipocosto='N'
	where esMP = 'S' and esGravable = 'X' and esAnadido = 'N' 
	
	
	update TempBomGravableRep
	set bst_tipocosto='P'
	where esMP = 'S' and esGravable = 'X' and esAnadido = 'S' 
	

	update TempBomGravableRep
	set bst_tipocosto='Z'
	where esMP = 'S' and esGravable = 'Z' and esAnadido = 'N' 
	
	
	update TempBomGravableRep
	set bst_tipocosto='G'
	where esMP = 'S' and esGravable = 'Z' and esAnadido = 'S' 
	
	update TempBomGravableRep
	set bst_tipocosto='S'
	where esSUB = 'S'  
	
	
	update TempBomGravableRep
	set bst_tipocosto='E'
	where esMP = 'N' and esSUB = 'N' and
	(esGravable = 'S' or  esGravable = 'X') 
	
	
	update TempBomGravableRep
	set bst_tipocosto='H'
	where esMP = 'N' and esSUB = 'N' and
	(esGravable = 'Z') 
	

	update TempBomGravableRep
	set bst_tipocosto='F'
	where esMP = 'N' and esSUB = 'N' and
	(esGravable <> 'S' and  esGravable <> 'X') 



	
	update BOM_REP
	set bst_tipocosto=TempBomGravableRep.bst_tipocosto
	from TempBomGravableRep inner join BOM_REP on TempBomGravableRep.bst_codigo=BOM_REP.bst_codigo
	where BOM_REP.bst_tipocosto is null or BOM_REP.bst_tipocosto<>TempBomGravableRep.bst_tipocosto

	exec sp_droptable 'TempBomGravableRep'

	exec sp_droptable 'TempPaisTLC'













GO
