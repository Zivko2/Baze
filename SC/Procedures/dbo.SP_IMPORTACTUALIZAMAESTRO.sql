SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[SP_IMPORTACTUALIZAMAESTRO] (@tabla varchar(150), @user int, @consecutivo int)   as

declare @Contador int, @Campos varchar(150), @referencia varchar(8000)

	set @Contador=1

	DECLARE cur_campos CURSOR FOR
		SELECT     IMF_DISPLAYLABEL
		FROM         IMPORTSPECDET INNER JOIN
		                      IMPORTFIELDS ON IMPORTSPECDET.IMF_CODIGO = IMPORTFIELDS.IMF_CODIGO
		WHERE     ((IMPORTSPECDET.IMD_CAMPO_ORIGEN IS NOT NULL AND IMPORTSPECDET.IMD_CAMPO_ORIGEN <> '') OR
		          (IMPORTSPECDET.IMD_CALCULADO = 'S')) AND (IMPORTSPECDET.IMS_CODIGO = 0)
		AND IMPORTFIELDS.IMF_FIELDNAME NOT LIKE 'MA_NOPARTE%'
	open cur_campos
	
		FETCH NEXT FROM cur_campos INTO @Campos
		WHILE (@@FETCH_STATUS = 0) 
		BEGIN

			if @Contador=1
			set @referencia=@Campos
			else
			set @referencia=@referencia+','+@Campos
	
	
			set @Contador=@Contador+1

		FETCH NEXT FROM cur_campos INTO @Campos
	
	END

	CLOSE cur_campos
	DEALLOCATE cur_campos


	if @referencia is null 
	set @referencia=''

	exec SP_CREATABLALOG 41
	exec(' insert into sysusrlog41 (user_id, mov_id, referencia, frmtag, fechahora) 
	 select '+@user+', 2, convert(varchar(1100),'+@tabla+'.MAESTRO'+@consecutivo+'#MA_NOPARTE'+'+'',(Importador Datos)''+ lower('''+@referencia+''')), 41, getdate() 
	from '+@tabla +'
	where '+@tabla+'.MAESTRO'+@consecutivo+'#MA_NOPARTE IN (SELECT REPLACE(LEFT(RI_REGISTRO,CHARINDEX('','',RI_REGISTRO)-1),''MA_NOPARTE = '','''') FROM REGISTROSIMPORTADOS
							WHERE RI_REGISTRO LIKE ''MA_NOPARTE%'' AND RI_TIPO=''A'')
	group by MAESTRO'+@consecutivo+'#MA_NOPARTE')






























GO
