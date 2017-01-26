SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO












CREATE PROCEDURE [dbo].[SP_DescargaFactExpRango]  (@folioini varchar(25), @foliofin varchar(25), @user int)   as

SET NOCOUNT ON 

DECLARE @FE_CODIGO INT, @CFF_TIPO CHAR(2), @CF_TIPODESCCAMBIOREG CHAR(1), @fe_fecha datetime,
@fecodigoini int, @fecodigofin int, @fechaini datetime, @fechafin datetime, @sizeini smallint, @sizefin smallint, @folioini2 varchar(25),
@hora varchar(15), @MA_CODIGO int, @FECHA_STRUCT datetime, @bm_codigo int, @info varchar(100), @fe_folio varchar(30), @fecha varchar(10),
@consecutivo int, @EM_CODIGO INT

	SELECT @consecutivo = isnull(MAX(KAP_CODIGO)+1,0) FROM KARDESPED 

	select @em_codigo=em_codigo from intradeglobal.dbo.empresa where em_corto in
	(select replace(convert(sysname,db_name()),'intrade',''))

	select @fecha=convert(varchar(10),getdate(),101)

	if not exists (select * from kardespedtemp where kap_codigo >@consecutivo)
	dbcc checkident (kardespedtemp, reseed, @consecutivo) WITH NO_INFOMSGS

	if exists (select * from intradeglobal.dbo.avance where AVA_MENSAJENO=1 and SYSUSLST_ID=@user)
	delete from intradeglobal.dbo.avance where AVA_MENSAJENO=1 and SYSUSLST_ID=@user


	select @fecodigoini=fe_codigo from factexp where fe_folio=@folioini
	select @fecodigofin=fe_codigo from factexp where fe_folio=@foliofin
	select @fechaini= min(fe_fecha) from factexp where fe_codigo=@fecodigoini
	select @fechafin= max(fe_fecha) from factexp where fe_codigo=@fecodigofin


	SELECT @CF_TIPODESCCAMBIOREG = CF_TIPODESCCAMBIOREG
	FROM         dbo.CONFIGURACION

	/*set @sizeini = len(@folioini)
	set @sizefin =len(@foliofin)

	if @sizefin>@sizeini
	begin
		set @folioini2=replicate('0', @sizefin-@sizeini)+@folioini
	end
	else
		set @folioini2=@folioini*/


--	exec sp_DescExplosionaFactExpRango  @folioini, @foliofin

	exec sp_droptable  'BOM_DESCTEMP'
	exec sp_CreaBOM_DESCTEMP



/*==================*/

	exec sp_droptable  'TempFacturasaDescargar'


		SELECT     dbo.FACTEXP.FE_CODIGO, dbo.CONFIGURATFACT.CFF_TIPO
		INTO dbo.TempFacturasaDescargar
		FROM         dbo.CONFIGURATFACT RIGHT OUTER JOIN
		                      dbo.FACTEXP ON dbo.CONFIGURATFACT.TF_CODIGO = dbo.FACTEXP.TF_CODIGO LEFT OUTER JOIN
		                      dbo.CONFIGURATIPO RIGHT OUTER JOIN
		                      dbo.FACTEXPDET ON dbo.CONFIGURATIPO.TI_CODIGO = dbo.FACTEXPDET.TI_CODIGO ON 
		                      dbo.FACTEXP.FE_CODIGO = dbo.FACTEXPDET.FE_CODIGO LEFT OUTER 	 JOIN
				TEMBARQUE ON dbo.FACTEXP.TQ_CODIGO = dbo.TEMBARQUE.TQ_CODIGO 
		GROUP BY dbo.FACTEXP.FE_CODIGO, dbo.FACTEXP.FE_FECHA, dbo.FACTEXP.FE_FOLIO, dbo.CONFIGURATFACT.CFF_TIPO, dbo.FACTEXP.FE_CANCELADO, 
		                      dbo.FACTEXP.FE_DESCARGADA, dbo.CONFIGURATFACT.CFF_TRAT, dbo.CONFIGURATFACT.CFF_TIPODESCARGA, dbo.TEMBARQUE.TQ_TI_DESC
		HAVING      (dbo.FACTEXP.FE_CANCELADO = 'N') AND (dbo.FACTEXP.FE_DESCARGADA = 'N') AND (dbo.CONFIGURATFACT.CFF_TRAT = 'D') AND 
		                      (dbo.CONFIGURATFACT.CFF_TIPODESCARGA = 'A') --and (dbo.FACTEXP.FE_FOLIO >= @folioini2) AND (dbo.FACTEXP.FE_FOLIO <= @foliofin)
			AND dbo.TEMBARQUE.TQ_TI_DESC='A'
			and (dbo.FACTEXP.FE_FECHA >= @fechaini) AND (dbo.FACTEXP.FE_FECHA <= @fechafin)
			and (dbo.FACTEXP.FE_CODIGO >= @fecodigoini) AND (dbo.FACTEXP.FE_CODIGO <= @fecodigofin)
		ORDER BY dbo.FACTEXP.FE_FECHA, dbo.FACTEXP.FE_FOLIO, dbo.FACTEXP.FE_CODIGO


	
	DECLARE CUR_FACTEXPDESC CURSOR FOR
		SELECT FE_CODIGO, CFF_TIPO
		FROM TempFacturasaDescargar		



	
	OPEN CUR_FACTEXPDESC
	
	FETCH NEXT FROM CUR_FACTEXPDESC INTO @FE_CODIGO, @CFF_TIPO
	
	WHILE (@@FETCH_STATUS = 0) 
	BEGIN

		select @fe_fecha=fe_fecha, @fe_folio=fe_folio from factexp where fe_codigo=@FE_CODIGO

		select @hora =substring(convert(varchar(100),getdate(),9),13,8)+' '+substring(convert(varchar(100),getdate(),9),25,2)

		insert into intradeglobal.dbo.avance (SYSUSLST_ID, AVA_MENSAJENO, AVA_INFO, AVA_INFOING, AVA_FECHA, AVA_HORA, EM_CODIGO)
		values (@user,1, 'Llenando tabla Bom_DescTemp, Folio Doc.: '+@fe_folio+' Fecha Doc.: '+ convert(varchar(11), @fe_fecha) , 'Filling Bom_descTemp Table, Doc. Control #: '+@fe_folio+' Doc. Date: '+ convert(varchar(11), @fe_fecha), @fecha, @hora, @em_codigo)

		print '<==========' + convert(varchar(50), @FE_CODIGO) + + convert(varchar(11), @fe_fecha) + '==========>' 


		exec sp_CreaBOM_DESCTEMP


		EXEC SP_DescExplosionFactExp @FE_CODIGO, @user
	

/*=============== Descargando ==================*/

			IF @CF_TIPODESCCAMBIOREG ='U'
			BEGIN
				IF @CFF_TIPO = 'MN'		
				begin
					EXEC sp_DescargaFactExp @FE_CODIGO, 'UEPS', @user
				end
				else
				begin
					EXEC sp_DescargaFactExp @FE_CODIGO, 'PEPS', @user
				end
			END
			ELSE
			BEGIN
				EXEC sp_DescargaFactExp @FE_CODIGO, 'PEPS', @user
			END


		exec sp_droptable  'BOM_DESCTEMP'


		FETCH NEXT FROM CUR_FACTEXPDESC INTO @FE_CODIGO, @CFF_TIPO
	
	END
	
	CLOSE CUR_FACTEXPDESC
	DEALLOCATE CUR_FACTEXPDESC

	exec sp_CreaBOM_DESCTEMP



	UPDATE CONFIGURACION
	SET CF_DESCARGANDO='N', US_DESCARGANDO=0

	
	select @hora =substring(convert(varchar(100),getdate(),9),13,8)+' '+substring(convert(varchar(100),getdate(),9),25,2)

	insert into intradeglobal.dbo.avance (SYSUSLST_ID, AVA_MENSAJENO, AVA_INFO, AVA_INFOING, AVA_FECHA, AVA_HORA, EM_CODIGO)
	values (@user, 1, 'Proceso Terminado' , 'Finish Process', @fecha, @hora, @em_codigo)

	exec sp_droptable  'TempFacturasaDescargar'





















GO
