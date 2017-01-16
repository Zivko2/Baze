SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[SP_GENERASALDOAVISOTRASLADO] (@ATI_CODIGO INT, @TIPO CHAR(1), @USER INT)   as

DECLARE @ATID_INDICED INT, @MA_CODIGO INT, @BST_ENTRAVIGOR DATETIME, @ATID_CANT decimal(38,6), @CFT_TIPO VARCHAR(5),
@DI_DESTINO INT, @ATI_FECHAEMISION VARCHAR(11), @DI_ORIGEN INT


--@TIPO I=INTEGRAR, C=CANCELA

DELETE FROM IMPORTLOG WHERE IML_CBFORMA=322

if (select count(*) from IMPORTLOG)=0
DBCC CHECKIDENT (IMPORTLOG, RESEED, 0) WITH NO_INFOMSGS


IF @TIPO='I'
BEGIN
	UPDATE CONFIGURACION
	SET CF_DESCARGANDO='S'



	SELECT @DI_DESTINO=DI_DESTINO, @DI_ORIGEN=DI_ORIGEN, @ATI_FECHAEMISION=CONVERT(VARCHAR(11),ATI_FECHAEMISION,101) FROM AVISOTRASLADO WHERE ATI_CODIGO=@ATI_CODIGO

	/* =========== SE EXPLOSIONA EL AVISO DE TRASLADO ============*/
	DELETE FROM BOM_DESCTEMP WHERE FE_CODIGO=@ATI_CODIGO


		insert into bom_desctemp (fe_codigo, bst_pt, bst_hijo, fed_cant, bst_disch, ti_codigo,
		me_codigo, factconv, me_gen, bst_incorpor, fed_indiced, bst_nivel, ma_tip_ens, bst_entravigor, bst_perini, bst_perfin,
		bst_tipodesc, bst_pertenece, bst_tipocosto)

		SELECT     @ATI_CODIGO, AVISOTRASLADODET.MA_CODIGO, AVISOTRASLADODET.MA_CODIGO, SUM(AVISOTRASLADODET.ATID_CANT) AS ATID_CANT, 
			  'S', CONFIGURATIPO.CFT_TIPO, ISNULL(AVISOTRASLADODET.ME_CODIGO, 19), 1, 
			ISNULL(AVISOTRASLADODET.ME_CODIGO, 19), 1, AVISOTRASLADODET.ATID_INDICED, 'MP', 'C', AVISOTRASLADODET.ATID_FECHA_STRUCT,
			AVISOTRASLADODET.ATID_FECHA_STRUCT, AVISOTRASLADODET.ATID_FECHA_STRUCT, 'N', AVISOTRASLADODET.MA_CODIGO, 'S'			
		FROM         AVISOTRASLADODET LEFT OUTER JOIN
		                      MAESTRO MAESTRO_1 ON AVISOTRASLADODET.MA_CODIGO = MAESTRO_1.MA_CODIGO LEFT OUTER JOIN
		                      CONFIGURATIPO ON MAESTRO_1.TI_CODIGO = CONFIGURATIPO.TI_CODIGO
		WHERE (AVISOTRASLADODET.ATI_CODIGO = @ATI_CODIGO) AND AVISOTRASLADODET.ATID_TIP_ENS='C'--(CONFIGURATIPO.CFT_TIPO NOT IN ('P','S'))
		
		GROUP BY CONFIGURATIPO.CFT_TIPO, AVISOTRASLADODET.MA_CODIGO, AVISOTRASLADODET.ME_CODIGO, 
		                     AVISOTRASLADODET.ATID_INDICED, AVISOTRASLADODET.ATID_FECHA_STRUCT
		HAVING  (SUM(AVISOTRASLADODET.ATID_CANT) > 0) 


	DECLARE cur_AvisoTraslado CURSOR FOR
		SELECT   ATID_INDICED, AVISOTRASLADODET.MA_CODIGO, ATID_CANT, AVISOTRASLADODET.ATID_FECHA_STRUCT
		FROM  AVISOTRASLADODET LEFT OUTER JOIN
                      MAESTRO MAESTRO_1 ON AVISOTRASLADODET.MA_CODIGO = MAESTRO_1.MA_CODIGO LEFT OUTER JOIN
                      CONFIGURATIPO ON MAESTRO_1.TI_CODIGO = CONFIGURATIPO.TI_CODIGO
		WHERE ATI_CODIGO=@ATI_CODIGO AND CONFIGURATIPO.CFT_TIPO IN ('P','S')
	open cur_AvisoTraslado
		FETCH NEXT FROM cur_AvisoTraslado INTO @ATID_INDICED, @MA_CODIGO, @ATID_CANT, @BST_ENTRAVIGOR
		WHILE (@@FETCH_STATUS = 0) 
		BEGIN

			IF @BST_ENTRAVIGOR IS NOT NULL
			EXEC SP_FILL_BOM_DESCTEMP @ATID_INDICED, @MA_CODIGO, @BST_ENTRAVIGOR, @ATID_CANT, @ATI_CODIGO	
		

		FETCH NEXT FROM cur_AvisoTraslado INTO @ATID_INDICED, @MA_CODIGO, @ATID_CANT, @BST_ENTRAVIGOR
	
	END
	
	CLOSE cur_AvisoTraslado
	DEALLOCATE cur_AvisoTraslado

	
	
	EXEC SP_CreaVPIDescarga 'M', @ATI_FECHAEMISION, @DI_ORIGEN



	declare @v_fed_indiced int, @v_fe_codigo int, @v_bst_pt int, @v_bst_hijo int, @v_cantdesc decimal(38,6), @v_me_gen int, @v_totalSaldo decimal(38,6), @v_saldoInsuficiente varchar(1), @v_saldoDescargar decimal(38,6)
	declare cur_BOM_DESCTEMP cursor for
		SELECT     FED_INDICED, FE_CODIGO, BST_PT, BST_HIJO, ROUND(FED_CANT * BST_INCORPOR * ISNULL(FACTCONV, 1),6) AS CANTDESC, ME_GEN
		FROM         BOM_DESCTEMP
		WHERE     (FE_CODIGO = @ATI_CODIGO)
	open cur_BOM_DESCTEMP
	fetch next from cur_BOM_DESCTEMP into @v_fed_indiced , @v_fe_codigo , @v_bst_pt , @v_bst_hijo , @v_cantdesc , @v_me_gen
	while (@@fetch_status = 0)
	 begin
	
		   set @v_totalSaldo = @v_cantdesc
		   set @v_saldoInsuficiente = 0

  		    declare @v_pid_indiced int, @v_pid_saldogen int
		    declare cur_VPIDescarga cursor for
		        select pid_indiced, pid_saldogen 
                                   from VPIDescarga
		        where ma_codigo=@v_bst_hijo
		        order by pi_fec_ent
		
		   open cur_VPIDescarga
		   fetch next from cur_VPIDescarga into @v_pid_indiced, @v_pid_saldogen
		   while (@@fetch_status = 0)
		     begin
	
		       if @v_totalSaldo >0
		         begin
                                          if @v_totalSaldo >= @v_pid_saldogen
                  		     set @v_saldodescargar = @v_pid_saldogen
                                          else
                                           set @v_saldodescargar = @v_totalSaldo 	

		   	  INSERT INTO AVISOTRASLADOSALDO(ATID_INDICED, ATI_CODIGO, MA_CODIGO, MA_HIJO, ATIS_CANTHIJO, DI_INDICE, ME_CODIGO, PID_INDICED, ATIS_SALDODISP_PI)
		          	  values (@v_fed_indiced , @v_fe_codigo , @v_bst_pt , @v_bst_hijo , 0-@v_saldodescargar , @DI_ORIGEN, @v_me_gen, @v_pid_indiced,0-@v_saldodescargar)

		   	  INSERT INTO AVISOTRASLADOSALDO(ATID_INDICED, ATI_CODIGO, MA_CODIGO, MA_HIJO, ATIS_CANTHIJO, DI_INDICE, ME_CODIGO, PID_INDICED, ATIS_SALDODISP_PI)
		          	  values (@v_fed_indiced , @v_fe_codigo , @v_bst_pt , @v_bst_hijo , @v_saldodescargar , @DI_DESTINO, @v_me_gen, @v_pid_indiced,@v_saldodescargar)

		               set @v_totalSaldo = @v_totalSaldo - @v_pid_saldogen


                                          if @v_totalSaldo = 0
                                             break

		         end
                                  else
		        set @v_saldoInsuficiente = 1
	
		       fetch next from cur_VPIDescarga into @v_pid_indiced, @v_pid_saldogen
		     end
                               if @v_totalsaldo > 0
                 		   INSERT INTO AVISOTRASLADOSALDO(ATID_INDICED, ATI_CODIGO, MA_CODIGO, MA_HIJO, ATIS_CANTHIJO, DI_INDICE, ME_CODIGO, PID_INDICED, ATIS_SALDODISP_PI)
		          	  values (@v_fed_indiced , @v_fe_codigo , @v_bst_pt , @v_bst_hijo , @v_totalSaldo , @DI_DESTINO, @v_me_gen, @v_pid_indiced,0)

		    close cur_VPIDescarga
		    deallocate cur_VPIDescarga
		     
	   fetch next from cur_BOM_DESCTEMP into @v_fed_indiced , @v_fe_codigo , @v_bst_pt , @v_bst_hijo , @v_cantdesc , @v_me_gen
	 end
	close cur_BOM_DESCTEMP
	deallocate cur_BOM_DESCTEMP
	/*
	-- se le suma la cantidad a la planta destino
	INSERT INTO AVISOTRASLADOSALDO(ATID_INDICED, ATI_CODIGO, MA_CODIGO, MA_HIJO, ATIS_CANTHIJO, DI_INDICE, ME_CODIGO)
	SELECT     FED_INDICED, FE_CODIGO, BST_PT, BST_HIJO, ROUND(FED_CANT * BST_INCORPOR * ISNULL(FACTCONV, 1),6) AS CANTDESC, @DI_DESTINO, ME_GEN
	FROM         BOM_DESCTEMP
	WHERE     (FE_CODIGO = @ATI_CODIGO)

	-- se calcula la cantidad disponible de la planta origen
	UPDATE AVISOTRASLADOSALDO
	SET ATIS_SALDODISP_PI= ISNULL((SELECT ROUND(SUM(PID_SALDOGEN),6)+
					ISNULL((SELECT SUM(ATIS_CANTHIJO)
					FROM AVISOTRASLADOSALDO
					WHERE (MA_HIJO = VPIDescarga.MA_CODIGO) AND (DI_INDICE=@DI_ORIGEN)),0)
				FROM VPIDescarga inner join pedimp on VPIDescarga.pi_codigo=pedimp.pi_codigo
				WHERE PID_SALDOGEN > 0 AND MA_CODIGO = MA_HIJO-- AND DI_DEST_ORIGEN=@DI_ORIGEN
				AND VPIDescarga.PI_FEC_ENT <= @ATI_FECHAEMISION
				GROUP BY VPIDescarga.MA_CODIGO) ,0)
	WHERE ATI_CODIGO=@ATI_CODIGO



	-- se le resta la cantidad a la planta origen, este registro se inserta para poder sacar el inventario que queda en la planta origen
	INSERT INTO AVISOTRASLADOSALDO(ATID_INDICED, ATI_CODIGO, MA_CODIGO, MA_HIJO, ATIS_CANTHIJO, DI_INDICE, ME_CODIGO)
	SELECT     FED_INDICED, FE_CODIGO, BST_PT, BST_HIJO, 0-ROUND(FED_CANT * BST_INCORPOR * ISNULL(FACTCONV, 1),6) AS CANTDESC, @DI_ORIGEN, ME_GEN
	FROM         BOM_DESCTEMP
	WHERE     (FE_CODIGO = @ATI_CODIGO)


	UPDATE AVISOTRASLADO
	SET ATI_FECHADESCARGA=GETDATE(), ATI_ESTATUS='I'
	WHERE ATI_CODIGO=@ATI_CODIGO  */


	INSERT INTO IMPORTLOG (IML_MENSAJE, IML_CBFORMA) 
	SELECT     'NO SE PUEDE INTEGRAR EL NO. PARTE: ' + AVISOTRASLADODET.ATID_NOPARTE + ' POR QUE NO TIENE ASIGNADA ESTRUCTURA (BOM) ', 322
	FROM         AVISOTRASLADODET LEFT OUTER JOIN
	                      BOM_DESCTEMP ON AVISOTRASLADODET.ATID_INDICED = BOM_DESCTEMP.FED_INDICED
	WHERE     (BOM_DESCTEMP.FED_INDICED IS NULL) AND (AVISOTRASLADODET.ATI_CODIGO = @ATI_CODIGO)



	/*SI NO EXISTE SALDO SUFICIENTE EN PED. IMP. DE LAS PARTES QUE SE QUIEREN HACER EL TRASLADO
	AUTOMATICAMENTE CANCELA Y ENVIA UN REPORTE */

	IF (SELECT COUNT(*) FROM AVISOTRASLADOSALDO WHERE ATIS_SALDODISP_PI<ATIS_CANTHIJO AND DI_INDICE=@DI_DESTINO AND ATI_CODIGO=@ATI_CODIGO)>0
	or (SELECT COUNT(*) FROM IMPORTLOG WHERE IML_CBFORMA=322 AND IML_MENSAJE LIKE '%ASIGNADA ESTRUCTURA (BOM)')>0
	BEGIN
		INSERT INTO IMPORTLOG (IML_MENSAJE, IML_CBFORMA) 
		SELECT     'NO SE PUEDE INTEGRAR EL NO. PARTE: ' + MAESTRO_1.MA_NOPARTE + ' POR QUE NO EXISTE SALDO SUFICIENTE EN PEDIMENTOS (CANT. INSUFICIENTE:'+
			CONVERT(VARCHAR(50),dbo.AVISOTRASLADOSALDO.ATIS_CANTHIJO)+' '+dbo.MEDIDA.ME_CORTO+')', 322
		FROM         dbo.AVISOTRASLADOSALDO LEFT OUTER JOIN
		                      dbo.MEDIDA ON dbo.AVISOTRASLADOSALDO.ME_CODIGO = dbo.MEDIDA.ME_CODIGO LEFT OUTER JOIN
		                      dbo.MAESTRO MAESTRO_1 ON dbo.AVISOTRASLADOSALDO.MA_CODIGO = MAESTRO_1.MA_CODIGO
		WHERE ATIS_SALDODISP_PI<ATIS_CANTHIJO AND DI_INDICE=@DI_DESTINO AND ATI_CODIGO=@ATI_CODIGO


		DELETE FROM AVISOTRASLADOSALDO WHERE ATI_CODIGO=@ATI_CODIGO


		UPDATE AVISOTRASLADO
		SET ATI_FECHADESCARGA=NULL, ATI_ESTATUS='S'
		WHERE ATI_CODIGO=@ATI_CODIGO

	END


	UPDATE CONFIGURACION
	SET CF_DESCARGANDO='N'

END
ELSE
BEGIN
	DELETE FROM AVISOTRASLADOSALDO WHERE ATI_CODIGO=@ATI_CODIGO

	UPDATE AVISOTRASLADO
	SET ATI_FECHADESCARGA=NULL, ATI_ESTATUS='S'
	WHERE ATI_CODIGO=@ATI_CODIGO
END



GO
