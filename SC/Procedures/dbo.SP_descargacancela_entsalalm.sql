SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[SP_descargacancela_entsalalm] (@EN_CODIGO int)   as

SET NOCOUNT ON 
DECLARE @KAAD_CANT decimal(38,6), @KAAD_TIPO char(1), @KAA_INDICED_PED int, @saldoalm decimal(38,6), @CFM_TIPO varchar(5),
@saldosurt decimal(38,6), @ot_codigo int, @KAA_INDICED_FACT INT, @OTD_INDICED int, @END_CANT decimal(38,6), @END_INDICED int


SELECT     @CFM_TIPO= dbo.CONFIGURATMOVIMIENTO.CFM_TIPO
FROM         dbo.ENTSALALM LEFT OUTER JOIN
                      dbo.CONFIGURATMOVIMIENTO ON dbo.ENTSALALM.TM_CODIGO = dbo.CONFIGURATMOVIMIENTO.TM_CODIGO
WHERE dbo.ENTSALALM.EN_CODIGO=@EN_CODIGO


declare cur_cancelaalmacen cursor for

	SELECT     KAA_CANTDESC, KAA_TIPO, KAA_INDICED_PED, KAA_INDICED_FACT
	FROM         dbo.KARDESALMACEN
	WHERE     (KAA_CANTDESC > 0) AND (KAA_INDICED_PED IS NOT NULL) AND (KAA_FACTRANS = @EN_CODIGO)
	ORDER BY KAA_CODIGO DESC
open cur_cancelaalmacen

	FETCH NEXT FROM cur_cancelaalmacen INTO @KAAD_CANT, @KAAD_TIPO, @KAA_INDICED_PED, @KAA_INDICED_FACT


	WHILE (@@FETCH_STATUS = 0) 
	BEGIN

			select @saldoalm=isnull(end_saldoalm,0) from ENTSALALMSALDO where end_indiced=@KAA_INDICED_PED
			
			if @KAAD_TIPO='S'
			begin
				if @saldoalm-@KAAD_CANT>0
					update ENTSALALMSALDO
					set end_saldoalm=@saldoalm-@KAAD_CANT
					where end_indiced=@KAA_INDICED_PED

			end
			else
			begin
					update ENTSALALMSALDO
					set end_saldoalm=@saldoalm+@KAAD_CANT
					where end_indiced=@KAA_INDICED_PED
			end


	FETCH NEXT FROM cur_cancelaalmacen INTO @KAAD_CANT, @KAAD_TIPO, @KAA_INDICED_PED, @KAA_INDICED_FACT
	END

CLOSE cur_cancelaalmacen
DEALLOCATE cur_cancelaalmacen
	


	/* orden de trabajo */

	if @CFM_TIPO='SA'
	begin
	
	
		declare cur_cancelaOrdTrabajo cursor for
			SELECT     END_CANT, OTD_INDICED, END_INDICED
			FROM         ENTSALALMDET
			WHERE     (END_CANT > 0) AND (OTD_INDICED IS NOT NULL) AND (OTD_INDICED<>-1) AND (EN_CODIGO = @EN_CODIGO)
		open cur_cancelaOrdTrabajo
		
			FETCH NEXT FROM cur_cancelaOrdTrabajo INTO @END_CANT, @OTD_INDICED, @END_INDICED
		
		
			WHILE (@@FETCH_STATUS = 0) 
			BEGIN
		
				select @ot_codigo=ot_codigo from ordtrabajodet where otd_indiced=@OTD_INDICED
	
				update ordtrabajodet
				set otd_saldosurt=isnull(otd_saldosurt,0)+@END_CANT
				where otd_indiced =@OTD_INDICED
	
				update ENTSALALMDET
				set otd_indiced=-1
				where end_indiced=@END_INDICED			
	
	
				exec SP_ACTUALIZAESTATUSORDTRABAJOSURT @ot_codigo
	
		
		
			FETCH NEXT FROM cur_cancelaOrdTrabajo INTO @END_CANT, @OTD_INDICED, @END_INDICED
			END
		
		CLOSE cur_cancelaOrdTrabajo
		DEALLOCATE cur_cancelaOrdTrabajo
		
	
	end

	delete from KARDESALMACEN WHERE (KAA_FACTRANS = @EN_CODIGO)

	delete from ENTSALALMSALDO where en_codigo=@EN_CODIGO

	delete from ENTSALALMNOINTEGRA where en_codigo=@EN_CODIGO

	UPDATE ENTSALALM
	SET     EN_ESTATUS='S'
	WHERE     (EN_CODIGO = @EN_CODIGO)




























GO
