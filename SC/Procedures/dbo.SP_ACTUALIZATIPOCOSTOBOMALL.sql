SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO










































CREATE PROCEDURE [dbo].[SP_ACTUALIZATIPOCOSTOBOMALL] (@spi_codigo int=22)    as

SET NOCOUNT ON 
DECLARE @FechaActual datetime

	alter table MAESTRO disable TRIGGER [Update_Maestro] 

	exec sp_droptable 'TempBomGravable'

	exec sp_droptable 'TempPaisTLC'

	select pa_codigo 
	into dbo.TempPaisTLC
	from pais where spi_codigo=@spi_codigo and pa_codigo<>233
	

	set @FechaActual = convert(datetime, convert(varchar(11), getdate(),101))

	if (SELECT CF_CONFERIRORIGEN FROM CONFIGURACION)='C' 
	begin
		SELECT  BOM_STRUCT.BST_HIJO, 
		esGravable=case when bst_trans = 'N' and bst_hijo in (SELECT CERTORIGMPDET.MA_CODIGO
					         FROM  CERTORIGMPDET INNER JOIN CERTORIGMP ON CERTORIGMPDET.CMP_CODIGO = CERTORIGMP.CMP_CODIGO
					         WHERE CERTORIGMP.SPI_CODIGO = @spi_codigo and CERTORIGMPDET.PA_CLASE=maestro.pa_origen and LEFT(REPLACE(CERTORIGMPDET.CMP_FRACCION,'.',''),6)=LEFT(REPLACE(ISNULL((SELECT AR_FRACCION FROM ARANCEL WHERE AR_CODIGO=MAESTRO.AR_EXPMX), (SELECT AR_FRACCION FROM ARANCEL WHERE AR_CODIGO=MAESTRO.AR_IMPMX)),'.',''),6)
						 AND CERTORIGMP.CMP_ESTATUS='V' AND CERTORIGMP.CMP_IFECHA <= getdate() AND CERTORIGMP.CMP_VFECHA >= getdate()) then
	  				         (case when maestro.pa_origen in (SELECT pa_codigo FROM TempPaisTLC) then
						(case when maestro.ma_consta='S'/*pa_codigo in (select cf_pais_mx from configuracion)*/ then 'Z' else 'X' end) else 'N' end) else (case when ma_servicio='S' then 'X' else 'S' end) end,
		esAnadido=case when MAESTRO.MA_REPARA <>'A' then 'N' else 'S' end,
			esMP=case when CFT_TIPO in ('R', 'L', 'M', 'O') or (CFT_TIPO ='S' and BOM_STRUCT.BST_TIP_ENS='C') then 'S' else 'N' end,
			esSUB=case when CFT_TIPO ='S' and BOM_STRUCT.BST_TIP_ENS<>'C' then 'S' else 'N' end, 'Z' as bst_tipocosto
			into dbo.TempBomGravable
			FROM         BOM_STRUCT INNER JOIN
			                      MAESTRO ON BOM_STRUCT.BST_HIJO = MAESTRO.MA_CODIGO INNER JOIN CONFIGURATIPO
				ON MAESTRO.TI_CODIGO = CONFIGURATIPO.TI_CODIGO 
			WHERE bst_perini<=@FechaActual and bst_perfin>=@FechaActual
	
	end
	else
	begin
		SELECT  BOM_STRUCT.BST_HIJO, 
		esGravable=CASE WHEN bst_trans = 'N' and (MAESTRO.ma_def_tip='P'  and MAESTRO.spi_codigo =@spi_codigo) then
		(case when MAESTRO.pa_origen in (SELECT pa_codigo FROM TempPaisTLC)  then
		 (case when maestro.ma_consta='S'/*pa_codigo in (select cf_pais_mx from configuracion)*/ then 'Z' else 'X' end) else 'N' end) 
		else
		(case when MAESTRO.ma_servicio='S' then 'X' else 'S' end)
		end, esAnadido=case when MAESTRO.MA_REPARA <>'A' then 'N' else 'S' end,
		esMP=case when cft_Tipo in ('R', 'L', 'M', 'O') or (CFT_TIPO ='S' and BOM_STRUCT.BST_TIP_ENS='C') then 'S' else 'N' end,
		esSUB=case when cft_Tipo ='S' and BOM_STRUCT.BST_TIP_ENS<>'C' then 'S' else 'N' end, 'Z' as bst_tipocosto
		into dbo.TempBomGravable
		FROM         BOM_STRUCT INNER JOIN
		                      MAESTRO ON BOM_STRUCT.BST_HIJO = MAESTRO.MA_CODIGO LEFT OUTER JOIN
		                      CONFIGURATIPO ON MAESTRO.TI_CODIGO = CONFIGURATIPO.TI_CODIGO
		WHERE bst_perini<=@FechaActual and bst_perfin>=@FechaActual
	end
	


	

	

	
	/* Se asigna el tipo de costo */   

	update TempBomGravable
	set bst_tipocosto='A'
	where esMP = 'S' and esGravable = 'S' and esAnadido = 'N' 
	
	
	update TempBomGravable
	set bst_tipocosto='B'
	where esMP = 'S' and esGravable = 'S' and esAnadido = 'S' 
	
	
	update TempBomGravable
	set bst_tipocosto='C'
	where esMP = 'S' and esGravable = 'N' and esAnadido = 'N' 
	
	
	update TempBomGravable
	set bst_tipocosto='D'
	where esMP = 'S' and esGravable = 'N' and esAnadido = 'S' 
	
	
	update TempBomGravable
	set bst_tipocosto='N'
	where esMP = 'S' and esGravable = 'X' and esAnadido = 'N' 
	
	
	update TempBomGravable
	set bst_tipocosto='P'
	where esMP = 'S' and esGravable = 'X' and esAnadido = 'S' 

	update TempBomGravable
	set bst_tipocosto='Z'
	where esMP = 'S' and esGravable = 'Z' and esAnadido = 'N' 
	
	
	update TempBomGravable
	set bst_tipocosto='G'
	where esMP = 'S' and esGravable = 'Z' and esAnadido = 'S' 
	
	
	update TempBomGravable
	set bst_tipocosto='S'
	where esSUB = 'S'  
	
	
	update TempBomGravable
	set bst_tipocosto='E'
	where esMP = 'N' and esSUB = 'N' and
	(esGravable = 'S' or  esGravable = 'X') 

	update TempBomGravable
	set bst_tipocosto='H'
	where esMP = 'N' and esSUB = 'N' and
	(esGravable = 'Z') 
	
	
	update TempBomGravable
	set bst_tipocosto='F'
	where esMP = 'N' and esSUB = 'N' and
	(esGravable <> 'S' and  esGravable <> 'X') 




	update maestro
	set bst_tipocosto=TempBomGravable.bst_tipocosto
	from TempBomGravable inner join maestro on TempBomGravable.bst_hijo=maestro.ma_codigo 
	where maestro.bst_tipocosto is null or maestro.bst_tipocosto<>TempBomGravable.bst_tipocosto

	alter table MAESTRO enable TRIGGER [Update_Maestro] 
	exec sp_droptable 'TempBomGravable'

	exec sp_droptable 'TempPaisTLC'







GO
