SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[SP_IMPORTADORSELECTMASTER] (@tabla varchar(150), @ims_codigo int, @ims_cbforma int)   as

declare @aux2 varchar(1500),@j int, @primer char(1), @temp_str varchar(8000),
@IMF_FIELDTYPE varchar(1500),  @IMF_SELECTMASTER varchar(1500), @IMF_SACARMAESTRO varchar(1500), @Update varchar(1500), @Where varchar(1500), 
@cond varchar(1500), @Resultado varchar(8000), @IMF_TABLENAME VARCHAR(1500), @con smallint, @IMF_FIELDNAME varchar(500), @campo varchar(500)

	declare cur_selectmaster cursor for		
		SELECT    CHARINDEX('[', IMF_SELECTMASTER), '@aux2'=case when CHARINDEX('[', IMF_SELECTMASTER)>0 then SUBSTRING(IMF_SELECTMASTER, CHARINDEX('[', IMF_SELECTMASTER)+1, CHARINDEX(']',IMF_SELECTMASTER)-CHARINDEX('[',IMF_SELECTMASTER)-1)
		else '' end, '@temp_str'=case when CHARINDEX('[', IMF_SELECTMASTER)>0 then SUBSTRING(IMF_SELECTMASTER,1,CHARINDEX('[',IMF_SELECTMASTER)-2) else '' end, IMF_FIELDTYPE, IMF_SELECTMASTER, IMF_SACARMAESTRO,
		IMF_TABLENAME, IMF_FIELDNAME
		FROM         IMPORTFIELDS INNER JOIN IMPORTSPECDET ON IMPORTFIELDS.IMF_CODIGO=IMPORTSPECDET.IMF_CODIGO
		WHERE  IMPORTSPECDET.IMS_CODIGO=@ims_codigo and (IMPORTSPECDET.IMS_CBFORMA = @ims_cbforma) and
		   CHARINDEX('[', IMF_SELECTMASTER) IS NOT NULL and CHARINDEX('[', IMF_SELECTMASTER)>0 
		--and CHARINDEX('[', IMF_SELECTMASTER)=189
	open cur_selectmaster
	FETCH NEXT FROM cur_selectmaster INTO @con, @aux2, @temp_str, @IMF_FIELDTYPE, @IMF_SELECTMASTER, @IMF_SACARMAESTRO, @IMF_TABLENAME, @IMF_FIELDNAME

	WHILE (@@FETCH_STATUS = 0) 
	BEGIN

		if @con>0 
		begin
			/* se asigna cero en un inicio para que el while que pueda entrar al total de registros*/
			set @j=0 
			set @cond=''

			set @Update='UPDATE '+@tabla+' set '+@IMF_TABLENAME+convert(varchar(50),@ims_codigo)+'#'+@IMF_FIELDNAME+'= ('

			  if (@IMF_FIELDTYPE<>'SMALLINT' and @IMF_FIELDTYPE<>'INT' and @IMF_FIELDTYPE<>'decimal(38,6)')
				set @Where='WHERE ('+@IMF_TABLENAME+convert(varchar(50),@ims_codigo)+'#'+@IMF_FIELDNAME+'='''') '
			  else 
				set @Where='WHERE ('+@IMF_TABLENAME+convert(varchar(50),@ims_codigo)+'#'+@IMF_FIELDNAME+' IS NULL OR '+@IMF_TABLENAME+convert(varchar(50),@ims_codigo)+'#'+@IMF_FIELDNAME+' =0)'

			while (select dbo.RepiteStr(@aux2, ',')+1)<>@j 
			begin
				 select @campo=dbo.SeparaCampoComa(@aux2,@j+1)		

				if (select dbo.RepiteStr(@aux2, ',')+1) > 1 AND (select dbo.RepiteStr(@aux2, ',')+1)<>@j+1
				begin				
--					  if (@IMF_FIELDTYPE<>'SMALLINT' and @IMF_FIELDTYPE<>'INT' and @IMF_FIELDTYPE<>'decimal(38,6)')
--					     select @cond=@cond+@campo+'='+''''+@IMF_TABLENAME+convert(varchar(50),@ims_codigo)+'#'+dbo.SeparaCampoComa(@IMF_SACARMAESTRO,@j+1)+''' AND '
--					 else
					     select @cond= @cond+@campo+'='+@IMF_TABLENAME+convert(varchar(50),@ims_codigo)+'#'+dbo.SeparaCampoComa(@IMF_SACARMAESTRO,@j+1)+' AND '
				end
				else
				begin
--					  if (@IMF_FIELDTYPE<>'SMALLINT' and @IMF_FIELDTYPE<>'INT' and @IMF_FIELDTYPE<>'decimal(38,6)')
--					     select @cond=@cond+@campo+'='+''''+@IMF_TABLENAME+convert(varchar(50),@ims_codigo)+'#'+dbo.SeparaCampoComa(@IMF_SACARMAESTRO,@j+1)+''''
--					 else
					     select @cond= @cond+@campo+'='+@IMF_TABLENAME+convert(varchar(50),@ims_codigo)+'#'+dbo.SeparaCampoComa(@IMF_SACARMAESTRO,@j+1)
				end
				

				 set @j=@j+1
			  end

			     select @Resultado=@Update+@temp_str+@cond+') '+@Where 

				
	/*
			  if charindex('[',@IMF_SELECTMASTER) > 1
			    set @Resultado=@temp_str+substring(@IMF_SELECTMASTER,
		                                        charindex(']',@IMF_SELECTMASTER)+1,
		                                        Len(@IMF_SELECTMASTER)-
		                                        charindex(']',@IMF_SELECTMASTER)-1 )*/
	  	end
		else
		    set @Resultado=@IMF_SELECTMASTER

		if @Resultado<>''
		  exec (@Resultado)

		print @Resultado

	FETCH NEXT FROM cur_selectmaster INTO @con, @aux2, @temp_str, @IMF_FIELDTYPE, @IMF_SELECTMASTER, @IMF_SACARMAESTRO, @IMF_TABLENAME, @IMF_FIELDNAME

END

CLOSE cur_selectmaster
DEALLOCATE cur_selectmaster



GO
