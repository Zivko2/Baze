SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO






































CREATE PROCEDURE [dbo].[ARREGLAKARDESPEDNEGATIVOS]   as

declare @PID_INDICED int, @KAP_SALDOGEN decimal(38,6), @KAP_CODIGO int, @KAP_CANTDESC decimal(38,6), @descargademas decimal(38,6)



	IF EXISTS (SELECT name FROM  [tempdb].dbo.sysobjects 
	   WHERE name = '##SALDONEGATIVO'  AND  type = 'U')
	begin
		drop table ##SALDONEGATIVO
	end


	SELECT     PID_INDICED, KAP_SALDOGEN
	INTO ##SALDONEGATIVO
	FROM         VPEDIMPSALDO
	WHERE     (KAP_SALDOGEN < 0)

declare cur_arreglanegativos cursor for
	select PID_INDICED, 0-KAP_SALDOGEN
	from ##SALDONEGATIVO 
	order by 0-KAP_SALDOGEN desc
open cur_arreglanegativos

	FETCH NEXT FROM cur_arreglanegativos INTO @PID_INDICED, @KAP_SALDOGEN

	WHILE (@@FETCH_STATUS = 0) 
	BEGIN

		set @descargademas=@KAP_SALDOGEN

		declare cur_kardesnegativos cursor for		
			SELECT     KAP_CODIGO, KAP_CANTDESC
			FROM         KARDESPED
			WHERE     (KAP_INDICED_PED = @PID_INDICED)
			ORDER BY KAP_CODIGO DESC
		open cur_kardesnegativos
		FETCH NEXT FROM cur_kardesnegativos INTO @KAP_CODIGO, @KAP_CANTDESC
	
		WHILE (@@FETCH_STATUS = 0) 
		BEGIN

			if @descargademas >0
			begin
				if @KAP_CANTDESC>@descargademas
				begin
				   update kardesped 
				   set KAP_CANTDESC=@KAP_CANTDESC-@descargademas,
				       KAP_Saldo_FED=KAP_Saldo_FED+@descargademas
				   where kap_codigo=@KAP_CODIGO

				   set @descargademas=0
				end

				if @KAP_CANTDESC<=@descargademas		
				begin
				   delete from kardesped where kap_codigo=@KAP_CODIGO
				   set @descargademas=@descargademas-@KAP_CANTDESC
				end
			end

			IF (@descargademas = 0) 
			 break


		FETCH NEXT FROM cur_kardesnegativos INTO @KAP_CODIGO, @KAP_CANTDESC
		
		END
		
		CLOSE cur_kardesnegativos
		DEALLOCATE cur_kardesnegativos


	FETCH NEXT FROM cur_arreglanegativos INTO @PID_INDICED, @KAP_SALDOGEN

END

CLOSE cur_arreglanegativos
DEALLOCATE cur_arreglanegativos




		IF EXISTS (SELECT name FROM  [tempdb].dbo.sysobjects 
		   WHERE name = '##SALDONEGATIVO'  AND  type = 'U')
		begin
			drop table ##SALDONEGATIVO
		end






























GO
