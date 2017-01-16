SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SP_ACTUALIZATIPOCOSTOBOM_NIVELUno] (@spi_codigo int=22, @uservar varchar(50)='1')    as

SET NOCOUNT ON 

declare @spi_codigovar varchar(50)
	
	--select @user=convert(varchar(50),USER_ID (current_user))


	select @spi_codigovar=convert(varchar(50), @spi_codigo)

	alter table MAESTRO disable TRIGGER [Update_Maestro] 

	exec('exec sp_droptable ''TempBomGravableNivel'+@uservar+'''')
	


	if (SELECT CF_CONFERIRORIGEN FROM CONFIGURACION)='C' 
	begin
		exec('exec sp_droptable ''TempPaisTLC'+@uservar+'''')

		exec('select pa_codigo 
		into dbo.TempPaisTLC'+@uservar+'
		from pais where spi_codigo='+@spi_codigovar+' and pa_codigo<>233')

		exec('SELECT  BOM_STRUCT.BST_HIJO, 
		esGravable=case when (bst_trans = ''N'') and BOM_STRUCT.bst_hijo in (SELECT CERTORIGMPDET.MA_CODIGO
					         FROM  CERTORIGMPDET INNER JOIN CERTORIGMP ON CERTORIGMPDET.CMP_CODIGO = CERTORIGMP.CMP_CODIGO 
					         WHERE CERTORIGMP.SPI_CODIGO = '+@spi_codigovar+' and CERTORIGMPDET.PA_CLASE=maestro.pa_origen and LEFT(REPLACE(CERTORIGMPDET.CMP_FRACCION,''.'',''''),6)=LEFT(REPLACE(ISNULL((SELECT AR_FRACCION FROM ARANCEL WHERE AR_CODIGO=MAESTRO.AR_EXPMX), (SELECT AR_FRACCION FROM ARANCEL WHERE AR_CODIGO=MAESTRO.AR_IMPMX)),''.'',''''),6)
						 AND CERTORIGMP.CMP_ESTATUS=''V'' AND CERTORIGMP.CMP_IFECHA <= getdate() AND CERTORIGMP.CMP_VFECHA >= getdate()) then
	  				         (case when maestro.pa_origen in (SELECT pa_codigo FROM TempPaisTLC'+@uservar+') then
						(case when maestro.ma_consta=''S''/*pa_codigo in (select cf_pais_mx from configuracion)*/ then ''Z'' else ''X'' end)  else ''N'' end) else (case when ma_servicio=''S'' then ''X'' else ''S'' end) end,
		esAnadido=case when MAESTRO.MA_REPARA <>''A'' then ''N'' else ''S'' end,
			esMP=case when CFT_TIPO in (''R'', ''L'', ''M'', ''O'') or (CFT_TIPO =''S'' and BOM_STRUCT.BST_TIP_ENS=''C'') then ''S'' else ''N'' end,
			esSUB=case when CFT_TIPO =''S'' and BOM_STRUCT.BST_TIP_ENS<>''C'' then ''S'' else ''N'' end, ''Z'' as bst_tipocosto
			into dbo.TempBomGravableNivel'+@uservar+'
			FROM         BOM_STRUCT INNER JOIN
			                      MAESTRO ON BOM_STRUCT.BST_HIJO = MAESTRO.MA_CODIGO INNER JOIN
			                      CONFIGURATIPO ON MAESTRO.TI_CODIGO = CONFIGURATIPO.TI_CODIGO INNER JOIN
			                      BOM_NIVEL'+@uservar+' ON BOM_STRUCT.BSU_SUBENSAMBLE = BOM_NIVEL'+@uservar+'.BST_HIJO
			WHERE     (BOM_STRUCT.BST_PERINI <= GETDATE()) AND (BOM_STRUCT.BST_PERFIN >= GETDATE())')

	end
	else
	begin
		exec('exec sp_droptable ''TempBomGravableNivel'+@uservar+'''')


		exec('exec sp_droptable ''TempPaisTLC'+@uservar+'''')

		exec('select pa_codigo 
		into dbo.TempPaisTLC'+@uservar+'
		from pais where spi_codigo='+@spi_codigovar+' and pa_codigo<>233')

		exec('SELECT  BOM_STRUCT.BST_HIJO, 
		esGravable=CASE WHEN bst_trans = ''N'' and (MAESTRO.ma_def_tip=''P'' and MAESTRO.spi_codigo ='+@spi_codigovar+') then
		(case when MAESTRO.pa_origen in (SELECT pa_codigo FROM TempPaisTLC'+@uservar+')  then
		   (case when maestro.ma_consta=''S''/*pa_codigo in (select cf_pais_mx from configuracion)*/ then ''Z'' else ''X'' end) else ''N'' end) 
		else
		(case when MAESTRO.ma_servicio=''S'' then ''X'' else ''S'' end)
		end, esAnadido=case when MAESTRO.MA_REPARA <>''A'' then ''N'' else ''S'' end,
		esMP=case when cft_Tipo in (''R'', ''L'', ''M'', ''O'') or (CFT_TIPO =''S'' and BOM_STRUCT.BST_TIP_ENS=''C'') then ''S'' else ''N'' end,
		esSUB=case when cft_Tipo =''S'' and BOM_STRUCT.BST_TIP_ENS<>''C'' then ''S'' else ''N'' end, ''Z'' as bst_tipocosto
		into dbo.TempBomGravableNivel'+@uservar+'
		FROM         BOM_STRUCT INNER JOIN
		                      MAESTRO ON BOM_STRUCT.BST_HIJO = MAESTRO.MA_CODIGO LEFT OUTER JOIN
		                      CONFIGURATIPO ON MAESTRO.TI_CODIGO = CONFIGURATIPO.TI_CODIGO INNER JOIN
		                      BOM_NIVEL'+@uservar+' ON BOM_STRUCT.BSU_SUBENSAMBLE = BOM_NIVEL'+@uservar+'.BST_HIJO
		WHERE (BOM_STRUCT.BST_PERINI <= GETDATE()) AND (BOM_STRUCT.BST_PERFIN >= GETDATE())')

	end
	
	

	
	/* Se asigna el tipo de costo */   


	exec('update TempBomGravableNivel'+@uservar+'
	set bst_tipocosto=''A''
	where esMP = ''S'' and esGravable = ''S'' and esAnadido = ''N'' 
	
	
	update TempBomGravableNivel'+@uservar+'
	set bst_tipocosto=''B''
	where esMP = ''S'' and esGravable = ''S'' and esAnadido = ''S'' 
	
	
	update TempBomGravableNivel'+@uservar+'
	set bst_tipocosto=''C''
	where esMP = ''S'' and esGravable = ''N'' and esAnadido = ''N'' 
	
	
	update TempBomGravableNivel'+@uservar+'
	set bst_tipocosto=''D''
	where esMP = ''S'' and esGravable = ''N'' and esAnadido = ''S'' 
	
	
	update TempBomGravableNivel'+@uservar+'
	set bst_tipocosto=''N''
	where esMP = ''S'' and esGravable = ''X'' and esAnadido = ''N'' 
	
	
	update TempBomGravableNivel'+@uservar+'
	set bst_tipocosto=''P''
	where esMP = ''S'' and esGravable = ''X'' and esAnadido = ''S'' 
	
	
	update TempBomGravableNivel'+@uservar+'
	set bst_tipocosto=''S''
	where esSUB = ''S''  
	

	-- ''X'' pertenecen a Mexico o canada


	update TempBomGravableNivel'+@uservar+'
	set bst_tipocosto=''E''
	where esMP = ''N'' and esSUB = ''N'' and
	(esGravable = ''S'' or  esGravable = ''X'') 
	
	
	update TempBomGravableNivel'+@uservar+'
	set bst_tipocosto=''F''
	where esMP = ''N'' and esSUB = ''N'' and
	(esGravable <> ''S'' and  esGravable <> ''X'')



	update maestro
	set bst_tipocosto=TempBomGravableNivel'+@uservar+'.bst_tipocosto
	from TempBomGravableNivel'+@uservar+' inner join maestro on TempBomGravableNivel'+@uservar+'.bst_hijo=maestro.ma_codigo
	where maestro.bst_tipocosto is null or maestro.bst_tipocosto<>TempBomGravableNivel'+@uservar+'.bst_tipocosto')


	alter table MAESTRO enable TRIGGER [Update_Maestro] 
	exec('exec sp_droptable ''TempBomGravableNivel'+@uservar+'''')

	exec('exec sp_droptable ''TempPaisTLC'+@uservar+'''')
GO
