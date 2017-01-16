SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO




/* hace la descarga por un rango de fechas* -- solo las que son de mp */
CREATE PROCEDURE [dbo].[SP_DescargaFactExpPeriodoInv]  (@fechaini varchar(10), @fechafin varchar(10), @user int, @Tipo char(1)='I')   as

SET NOCOUNT ON 
DECLARE @FE_CODIGO INT, @CFF_TIPO CHAR(2), @CF_TIPODESCCAMBIOREG CHAR(1), @fe_fecha datetime,
@hora varchar(15), @MA_CODIGO int, @FECHA_STRUCT datetime, @bm_codigo int, @info varchar(100), @fe_folio varchar(30), @fecha varchar(10), @em_codigo int


	if @Tipo is null
	set @Tipo='I'
declare @consecutivo int

	SELECT @consecutivo = isnull(MAX(KAP_CODIGO)+1,0) FROM KARDESPED 

	select @em_codigo=em_codigo from intradeglobal.dbo.empresa where em_corto in
	(select replace(convert(sysname,db_name()),'intrade',''))

	select @fecha=convert(varchar(10),getdate(),101)

	if not exists (select * from kardespedtemp where kap_codigo >@consecutivo)
	dbcc checkident (kardespedtemp, reseed, @consecutivo) WITH NO_INFOMSGS

	--los numeros de mensaje de la descarga son valores de 0 a 1
	if exists (select * from intradeglobal.dbo.avance where AVA_MENSAJENO=1 and SYSUSLST_ID=@user)
	delete from intradeglobal.dbo.avance where AVA_MENSAJENO=1 and SYSUSLST_ID=@user

	SELECT @CF_TIPODESCCAMBIOREG = CF_TIPODESCCAMBIOREG
	FROM         dbo.CONFIGURACION


--	if exists(select * from BOM_DESCTEMP)
--	DELETE FROM BOM_DESCTEMP
	exec sp_droptable  'BOM_DESCTEMP'
	exec sp_CreaBOM_DESCTEMP


/*====== Llenando bom_desctemp ====*/

	exec sp_droptable  'TempFacturasaDescargar'



	SELECT     dbo.FACTEXP.FE_CODIGO, dbo.CONFIGURATFACT.CFF_TIPO
	INTO dbo.TempFacturasaDescargar
	FROM         dbo.CONFIGURATFACT RIGHT OUTER JOIN
	                      dbo.FACTEXP ON dbo.CONFIGURATFACT.TF_CODIGO = dbo.FACTEXP.TF_CODIGO LEFT OUTER JOIN
	                      dbo.CONFIGURATIPO RIGHT OUTER JOIN
	                      dbo.FACTEXPDET ON dbo.CONFIGURATIPO.TI_CODIGO = dbo.FACTEXPDET.TI_CODIGO ON 
	                      dbo.FACTEXP.FE_CODIGO = dbo.FACTEXPDET.FE_CODIGO LEFT OUTER 	 JOIN
			TEMBARQUE ON dbo.FACTEXP.TQ_CODIGO = dbo.TEMBARQUE.TQ_CODIGO 
	GROUP BY dbo.FACTEXP.FE_CODIGO, dbo.FACTEXP.FE_FECHA, dbo.CONFIGURATFACT.CFF_TIPO, dbo.FACTEXP.FE_CANCELADO, 
	                      dbo.FACTEXP.FE_DESCARGADA, dbo.CONFIGURATFACT.CFF_TRAT, dbo.CONFIGURATFACT.CFF_TIPODESCARGA, dbo.TEMBARQUE.TQ_TI_DESC
	HAVING      (dbo.FACTEXP.FE_CANCELADO = 'N') AND (dbo.FACTEXP.FE_DESCARGADA = 'N') 
			AND (dbo.CONFIGURATFACT.CFF_TRAT = 'D') AND (dbo.CONFIGURATFACT.CFF_TIPODESCARGA = 'A') 
			AND dbo.TEMBARQUE.TQ_TI_DESC='A'
			and (dbo.FACTEXP.FE_FECHA >= @fechaini) AND (dbo.FACTEXP.FE_FECHA <= @fechafin)
	ORDER BY dbo.FACTEXP.FE_FECHA, dbo.FACTEXP.FE_CODIGO


	
	DECLARE CUR_FACTEXPDESC CURSOR FOR
	

		SELECT FE_CODIGO, CFF_TIPO
		FROM TempFacturasaDescargar	

	OPEN CUR_FACTEXPDESC
	
	FETCH NEXT FROM CUR_FACTEXPDESC INTO @FE_CODIGO, @CFF_TIPO
	
	WHILE (@@FETCH_STATUS = 0) 
	BEGIN

		select @fe_fecha=fe_fecha, @fe_folio=fe_folio from factexp where fe_codigo=@FE_CODIGO
		select @hora =substring(convert(varchar(100),getdate(),9),13,8)+' '+substring(convert(varchar(100),getdate(),9),25,2)


		insert into intradeglobal.dbo.avance (SYSUSLST_ID, AVA_MENSAJENO, AVA_INFO, AVA_INFOING, AVA_FECHA, AVA_HORA, em_codigo)
		values (@user,1, 'Llenando tabla Bom_DescTemp, Folio Doc.: '+@fe_folio+' Fecha Doc.: '+ convert(varchar(11), @fe_fecha) , 'Filling Bom_descTemp Table, Doc. Control #: '+@fe_folio+' Doc. Date: '+ convert(varchar(11), @fe_fecha), @fecha, @hora, @em_codigo)

		print '<========== Llenando tabla Bom_DescTemp' + convert(varchar(11), @FE_CODIGO) + + convert(varchar(50), @fe_fecha) + '==========>' 

	

		if exists (select * from factexpdet where fed_retrabajo='N' and fe_codigo=@FE_CODIGO)
		begin
			exec SP_ExplosionDescFactExp @FE_CODIGO		
		end
		else
		begin

			insert into bom_desctemp (fe_codigo, bst_pt, bst_hijo, fed_cant, bst_disch, ti_codigo,
				me_codigo, factconv, me_gen, bst_incorpor, FED_INDICED, MA_TIP_ENS, BST_TIPODESC, BST_NIVEL)	
				
			
			SELECT     dbo.FACTEXPDET.FE_CODIGO, dbo.FACTEXPDET.MA_CODIGO, dbo.RETRABAJO.MA_HIJO, SUM(dbo.FACTEXPDET.FED_CANT) AS FED_CANT,  'S' AS MA_DISCHARGE, 
			                      dbo.CONFIGURATIPO.CFT_TIPO, ISNULL(dbo.MAESTRO.ME_COM, dbo.RETRABAJO.ME_GEN), dbo.RETRABAJO.FACTCONV, dbo.RETRABAJO.ME_GEN AS ME_GEN, 
			                      SUM(dbo.RETRABAJO.RE_INCORPOR) AS RE_INCORPOR, dbo.FACTEXPDET.FED_INDICED, dbo.MAESTRO.MA_TIP_ENS, 'N', 'R'
			FROM         dbo.RETRABAJO LEFT OUTER JOIN
			                      dbo.FACTEXPDET ON dbo.RETRABAJO.FETR_INDICED = dbo.FACTEXPDET.FED_INDICED and RETRABAJO.TIPO_FACTRANS='F' LEFT OUTER JOIN
			                      dbo.MAESTRO ON dbo.RETRABAJO.MA_HIJO = dbo.MAESTRO.MA_CODIGO LEFT OUTER JOIN
			                      dbo.CONFIGURATIPO ON dbo.FACTEXPDET.TI_CODIGO = dbo.CONFIGURATIPO.TI_CODIGO
			WHERE dbo.RETRABAJO.MA_HIJO <> dbo.FACTEXPDET.MA_CODIGO AND dbo.FACTEXPDET.FE_CODIGO=@FE_CODIGO
			GROUP BY dbo.FACTEXPDET.FE_CODIGO, dbo.FACTEXPDET.FED_INDICED, dbo.FACTEXPDET.FED_RATEIMPFO, dbo.FACTEXPDET.AR_IMPFO, 
			                      dbo.FACTEXPDET.FED_FECHA_STRUCT, dbo.FACTEXPDET.MA_CODIGO, dbo.FACTEXPDET.FED_COS_UNI, dbo.CONFIGURATIPO.TI_CODIGO, 
			                      dbo.MAESTRO.MA_TIP_ENS, dbo.RETRABAJO.MA_HIJO, dbo.RETRABAJO.FACTCONV, dbo.FACTEXPDET.FED_RETRABAJO, 
			                      dbo.CONFIGURATIPO.CFT_TIPO, dbo.RETRABAJO.ME_GEN, dbo.MAESTRO.ME_COM, dbo.MAESTRO.MA_DISCHARGE,
				dbo.FACTEXPDET.pid_indiced
			HAVING      (dbo.FACTEXPDET.FED_RETRABAJO <> 'N') 
				         and (dbo.FACTEXPDET.pid_indiced =-1) and SUM(dbo.FACTEXPDET.FED_CANT) >0
		end



--=============== Descargando ==================
		IF @CF_TIPODESCCAMBIOREG ='U'
			BEGIN
				IF @CFF_TIPO = 'MN'		
				begin
					EXEC sp_DescargaFactExpInv @FE_CODIGO, 'UEPS', @user
				end
				else
				begin
					EXEC sp_DescargaFactExpInv @FE_CODIGO, 'PEPS', @user
				end
			END
			ELSE
			BEGIN
				EXEC sp_DescargaFactExpInv @FE_CODIGO, 'PEPS', @user
			END
	

			if exists(select * from BOM_DESCTEMP WHERE FE_CODIGO = @FE_CODIGO)
			DELETE FROM BOM_DESCTEMP WHERE FE_CODIGO = @FE_CODIGO

	
		FETCH NEXT FROM CUR_FACTEXPDESC INTO @FE_CODIGO, @CFF_TIPO
	
	END
	
	CLOSE CUR_FACTEXPDESC
	DEALLOCATE CUR_FACTEXPDESC


	UPDATE CONFIGURACION
	SET CF_DESCARGANDO='N', US_DESCARGANDO=0


	select @hora =substring(convert(varchar(100),getdate(),9),13,8)+' '+substring(convert(varchar(100),getdate(),9),25,2)

	insert into intradeglobal.dbo.avance (SYSUSLST_ID, AVA_MENSAJENO, AVA_INFO, AVA_INFOING, AVA_FECHA, AVA_HORA, EM_CODIGO)
	values (@user,1, 'Proceso Terminado' , 'Finish Process', @fecha, @hora, @em_codigo)



	exec sp_droptable  'TempFacturasaDescargar'

GO
