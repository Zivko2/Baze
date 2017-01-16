SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[SP_ALLOCATE] (@OT_CODIGO INT)   as

declare @BST_HIJO int, @CANT decimal(38,6), @OTE_INDICED int, @END_SALDOALM decimal(38,6), @END_INDICED int, @END_CANTALLOCATE decimal(38,6), @END_CANT decimal(38,6),
@cantdesc decimal(38,6), @OT_FECHA DATETIME, @OT_FOLIO VARCHAR(25)

	IF NOT EXISTS (SELECT * FROM TempImpOrdTrabajo WHERE OT_CODIGO=@OT_CODIGO)
	EXEC SP_DescExplosionOrdTrabajo @OT_CODIGO


	if exists (select * from ORDTRABAJOEXPLO WHERE OT_CODIGO=@OT_CODIGO)
	DELETE FROM ORDTRABAJOEXPLO WHERE OT_CODIGO=@OT_CODIGO

	INSERT INTO ORDTRABAJOEXPLO(OT_CODIGO, OTD_INDICED, MA_CODIGO, OTE_NOPARTE, OTE_CANT, ME_CODIGO, OTE_CANTFALTA)
	SELECT @OT_CODIGO, OTD_INDICED, BST_HIJO, (SELECT MA_NOPARTE FROM MAESTRO WHERE MA_CODIGO=BST_HIJO), 
		sum(BST_INCORPOR * isnull(FACTCONV,1) * OTD_CANT), ME_GEN, sum(BST_INCORPOR * isnull(FACTCONV,1) * OTD_CANT)
	FROM TempImpOrdTrabajo
	WHERE OT_CODIGO=@OT_CODIGO
	GROUP BY OTD_INDICED, BST_HIJO, ME_GEN

	SELECT @OT_FECHA=OT_FECHA, @OT_FOLIO=OT_FOLIO FROM ORDTRABAJO WHERE OT_CODIGO=@OT_CODIGO



declare cur_allocatealm cursor for
	SELECT MA_CODIGO, OTE_CANT, OTE_INDICED
	FROM ORDTRABAJOEXPLO
	WHERE OT_CODIGO=@OT_CODIGO AND MA_CODIGO IN
		(SELECT     dbo.ENTSALALMDET.MA_CODIGO
	 	 FROM         dbo.ENTSALALMSALDO INNER JOIN
	                      dbo.ENTSALALM ON dbo.ENTSALALMSALDO.EN_CODIGO = dbo.ENTSALALM.EN_CODIGO LEFT OUTER JOIN
	                      dbo.CONFIGURATMOVIMIENTO ON dbo.ENTSALALM.TM_CODIGO = dbo.CONFIGURATMOVIMIENTO.TM_CODIGO LEFT OUTER JOIN 
				dbo.ENTSALALMDET ON dbo.ENTSALALMSALDO.END_INDICED = dbo.ENTSALALMDET.END_INDICED
	WHERE     (dbo.CONFIGURATMOVIMIENTO.CFM_TIPO IN ('IV', 'EN')) AND (dbo.ENTSALALM.EN_FECHA <= @OT_FECHA) AND 
	                      (dbo.ENTSALALMSALDO.END_SALDOALM > 0) AND (isnull(dbo.ENTSALALMSALDO.END_CANTALLOCATE,0) < dbo.ENTSALALMDET.END_CANT))
  OPEN cur_allocatealm

	FETCH NEXT FROM cur_allocatealm INTO @BST_HIJO, @CANT, @OTE_INDICED
  WHILE (@@fetch_status = 0) 
  BEGIN  

	set @cantdesc=0

	declare cur_saldoalm cursor for	
		SELECT     dbo.ENTSALALMSALDO.END_SALDOALM, dbo.ENTSALALMSALDO.END_INDICED, dbo.ENTSALALMSALDO.END_CANTALLOCATE, dbo.ENTSALALMDET.END_CANT
		FROM         dbo.ENTSALALMSALDO INNER JOIN
		                      dbo.ENTSALALM ON dbo.ENTSALALMSALDO.EN_CODIGO = dbo.ENTSALALM.EN_CODIGO LEFT OUTER JOIN
		                      dbo.CONFIGURATMOVIMIENTO ON dbo.ENTSALALM.TM_CODIGO = dbo.CONFIGURATMOVIMIENTO.TM_CODIGO LEFT OUTER JOIN 
				dbo.ENTSALALMDET ON dbo.ENTSALALMSALDO.END_INDICED = dbo.ENTSALALMDET.END_INDICED
		WHERE     (dbo.CONFIGURATMOVIMIENTO.CFM_TIPO IN ('IV', 'EN')) AND (dbo.ENTSALALM.EN_FECHA <= @OT_FECHA) AND 
		                      (dbo.ENTSALALMSALDO.END_SALDOALM > 0) AND (dbo.ENTSALALMSALDO.END_CANTALLOCATE < dbo.ENTSALALMDET.END_CANT) AND 
		                      (dbo.ENTSALALMDET.MA_CODIGO = @BST_HIJO) AND (dbo.ENTSALALMDET.END_NOORDEN='' OR dbo.ENTSALALMDET.END_NOORDEN=@OT_FOLIO)
	 OPEN cur_saldoalm
	
		FETCH NEXT FROM cur_saldoalm INTO @END_SALDOALM, @END_INDICED, @END_CANTALLOCATE, @END_CANT
	  WHILE (@@fetch_status = 0) 
	  BEGIN  

		if @cantdesc <@CANT
		begin
			if @END_SALDOALM <= @CANT
			begin
	
				set @cantdesc=@cantdesc+@END_SALDOALM
	
				update ENTSALALMSALDO
				set END_CANTALLOCATE=@END_CANT
				where END_INDICED=@END_INDICED

				INSERT INTO ORDTRABAJOEXPLODET(OTE_INDICED, END_INDICED, OTED_CANT)
				VALUES (@OTE_INDICED, @END_INDICED, @END_SALDOALM)
	
	
			end
	
			if @END_SALDOALM > @CANT
			begin
				set @cantdesc=@cantdesc+@CANT

				update ENTSALALMSALDO
				set END_CANTALLOCATE=@END_CANTALLOCATE+@CANT
				where END_INDICED=@END_INDICED

				INSERT INTO ORDTRABAJOEXPLODET(OTE_INDICED, END_INDICED, OTED_CANT)
				VALUES (@OTE_INDICED, @END_INDICED, @CANT)
			end
		end


		FETCH NEXT FROM cur_saldoalm INTO @END_SALDOALM, @END_INDICED, @END_CANTALLOCATE, @END_CANT

   	  END 
	CLOSE cur_saldoalm
	DEALLOCATE cur_saldoalm


		if @cantdesc<@CANT
			UPDATE ORDTRABAJOEXPLO
			SET OTE_CANTFALTA= @CANT-@cantdesc
			WHERE OTE_INDICED=@OTE_INDICED
		else
			UPDATE ORDTRABAJOEXPLO
			SET OTE_CANTFALTA= 0
			WHERE OTE_INDICED=@OTE_INDICED


	FETCH NEXT FROM cur_allocatealm INTO @BST_HIJO, @CANT, @OTE_INDICED		
  END 
  CLOSE cur_allocatealm
  DEALLOCATE cur_allocatealm

	UPDATE ORDTRABAJOEXPLO
	SET OTE_CANTPO=OTE_CANTFALTA
	WHERE OT_CODIGO=@OT_CODIGO









































GO
