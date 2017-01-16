SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO








-- explosiona varias facturas para la seleccion multiple de la descarga manual
CREATE PROCEDURE [dbo].[SP_DescargaFactExpSelVerificando] (@usuario int)   as

SET NOCOUNT ON  

DECLARE @FE_CODIGO INT, @CFF_TIPO CHAR(2), @fe_fecha datetime, @fecha varchar(10),
@hora varchar(15), @MA_CODIGO int, @FECHA_STRUCT datetime, @bm_codigo int, @info varchar(100), @fe_folio varchar(30),
@consecutivo int, @em_codigo int

	SELECT @consecutivo = isnull(MAX(KAP_CODIGO)+1,0) FROM KARDESPED 

	select @em_codigo=em_codigo from intradeglobal.dbo.empresa where em_corto in
	(select replace(convert(sysname,db_name()),'intrade',''))


	if exists (select * from intradeglobal.dbo.avance where AVA_MENSAJENO=1 and SYSUSLST_ID=@usuario)
	delete from intradeglobal.dbo.avance where AVA_MENSAJENO=1 and SYSUSLST_ID=@usuario


	exec sp_droptable  'BOM_DESCTEMP'
	exec sp_CreaBOM_DESCTEMP


	select @fecha=convert(varchar(10),getdate(),101)
	
	--explosiona las facturas de dicho periodo


	exec sp_droptable  'TempFacturasaDescargar'


		SELECT     dbo.FACTEXP.FE_CODIGO, dbo.CONFIGURATFACT.CFF_TIPO
		INTO dbo.TempFacturasaDescargar
		FROM         dbo.CONFIGURATFACT RIGHT OUTER JOIN
		                      dbo.FACTEXP ON dbo.CONFIGURATFACT.TF_CODIGO = dbo.FACTEXP.TF_CODIGO LEFT OUTER JOIN
		                      dbo.CONFIGURATIPO RIGHT OUTER JOIN
		                      dbo.FACTEXPDET ON dbo.CONFIGURATIPO.TI_CODIGO = dbo.FACTEXPDET.TI_CODIGO ON 
		                      dbo.FACTEXP.FE_CODIGO = dbo.FACTEXPDET.FE_CODIGO
		WHERE      (dbo.FACTEXP.FE_CANCELADO = 'N') AND (dbo.FACTEXP.FE_DESCARGADA = 'N') 
				AND (dbo.CONFIGURATFACT.CFF_TRAT = 'D') AND (dbo.FACTEXP.FE_SEL = 'S')
		GROUP BY dbo.FACTEXP.FE_FECHA, dbo.FACTEXP.FE_CODIGO, dbo.CONFIGURATFACT.CFF_TIPO
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


				select @hora =substring(convert(varchar(100),getdate(),9),13,8)+' '+substring(convert(varchar(100),getdate(),9),25,2)

				insert into intradeglobal.dbo.avance (SYSUSLST_ID, AVA_MENSAJENO, AVA_INFO, AVA_INFOING, AVA_FECHA, AVA_HORA, EM_CODIGO)
				values (@usuario,1, 'Llenando tabla Bom_DescTemp, Folio Doc.: '+@fe_folio+' Fecha Doc.: '+ convert(varchar(11), @fe_fecha) , 'Filling Bom_descTemp Table, Doc. Control #: '+@fe_folio+' Doc. Date: '+ convert(varchar(11), @fe_fecha), @fecha, @hora, @EM_CODIGO)


		print '<========== Llenando tabla Bom_DescTemp' + convert(varchar(11), @FE_CODIGO) + + convert(varchar(50), @fe_fecha) + '==========>' 

		EXEC SP_DescExplosionFactExp @FE_CODIGO, @usuario, 'N'
	
		FETCH NEXT FROM CUR_FACTEXPDESC INTO @FE_CODIGO, @CFF_TIPO
	
	END
	
	CLOSE CUR_FACTEXPDESC
	DEALLOCATE CUR_FACTEXPDESC



	exec sp_droptable  'TempFacturasaDescargar'



GO
