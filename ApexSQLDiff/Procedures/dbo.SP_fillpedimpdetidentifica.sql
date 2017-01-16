SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SP_fillpedimpdetidentifica] (@picodigo int, @pi_movimiento char(1), @ccp_tipo varchar(5))   as

SET NOCOUNT ON 
declare @maximo INT, @Piid_codigo int, @fraccion varchar(20), @pi_rectifica int, @cp_clave varchar(10)




	TRUNCATE TABLE TempPedImpDetIdentifica



	SELECT    @cp_clave= dbo.CLAVEPED.CP_CLAVE
	FROM         dbo.CLAVEPED INNER JOIN
	          dbo.PEDIMP ON dbo.CLAVEPED.CP_CODIGO = dbo.PEDIMP.CP_CODIGO
	          WHERE     dbo.PEDIMP.PI_CODIGO = @picodigo



	--if exists (select * from PedImpDetIdentifica where pib_indiceb in (select pib_indiceb from pedimpdet where pi_codigo=@picodigo))
	begin
		--delete from  PedImpDetIdentifica where pib_indiceb in (select pib_indiceb from pedimpdet where pi_codigo=@picodigo)
		IF EXISTS (SELECT name FROM  [tempdb].dbo.sysobjects 
		   WHERE name = '##pib_indiceb'  AND  type = 'U')
		begin
			drop table ##pib_indiceb
		end


		select pib_indiceb 
		INTO ##pib_indiceb
		from pedimpdet where pi_codigo=@picodigo

		delete from  PedImpDetIdentifica where pib_indiceb in (select pib_indiceb from ##pib_indiceb)
		
		IF EXISTS (SELECT name FROM  [tempdb].dbo.sysobjects 
		   WHERE name = '##pib_indiceb'  AND  type = 'U')
		begin
			drop table ##pib_indiceb
		end



	end



	SELECT     @maximo= isnull(MAX(PIID_CODIGO),0)+1
	FROM         PEDIMPDETIDENTIFICA

	if @maximo is null
	set @maximo=1

	dbcc checkident (TempPedImpDetIdentifica, reseed, @maximo) WITH NO_INFOMSGS

	exec sp_droptable 'identificapermite'


	if @ccp_tipo IN ('RE')-- RECTIFICACION
	begin

		select @pi_rectifica=pi_rectifica from pedimp where pi_codigo=@picodigo

/*
		SELECT    @ccp_tipo= dbo.CONFIGURACLAVEPED.CCP_TIPO
		FROM         dbo.CONFIGURACLAVEPED INNER JOIN
		          dbo.PEDIMP ON dbo.CONFIGURACLAVEPED.CP_CODIGO = dbo.PEDIMP.CP_CODIGO
		          WHERE     dbo.PEDIMP.PI_CODIGO = @pi_rectifica*/


		SELECT     IDE_CODIGO
		into dbo.identificapermite
		FROM         CLAVEPEDIDENTIFICA
		WHERE      (IDE_NIVEL='A' OR IDE_NIVEL='P')  
		AND (CP_MOVIMIENTO = @pi_movimiento OR CP_MOVIMIENTO = 'A') AND (CP_CODIGO in (select cp_codigo from pedimp where pi_codigo=@picodigo))

	end
	else
	begin

		SELECT     IDE_CODIGO
		into dbo.identificapermite
		FROM         CLAVEPEDIDENTIFICA
		WHERE      (IDE_NIVEL='A' OR IDE_NIVEL='P')  AND (CP_MOVIMIENTO = @pi_movimiento OR CP_MOVIMIENTO = 'A') AND (CP_CODIGO in (select cp_codigo from pedimp where pi_codigo=@picodigo))
	end

	/* ======================= pps y regla octava ============================= */

		if exists(select * from identificapermite where ide_codigo in (SELECT IDE_CODIGO FROM dbo.IDENTIFICA WHERE IDE_CLAVE = 'PS' and IDE_IDENTPERM='I'))
		if exists (select * from pedimpdet where (pid_def_tip='S') and pi_codigo=@picodigo)		
		begin


			SELECT @fraccion=IDEG_DESC FROM IDENTIFICAGRAL WHERE IDEG_TIPO = 'C' AND IDE_CODIGO IN (SELECT IDE_CODIGO FROM dbo.IDENTIFICA WHERE IDE_CLAVE = 'PS' and IDE_IDENTPERM='I')


			INSERT INTO TempPedimpDetIdentifica (PIB_INDICEB, IDE_CODIGO, IDED_CODIGO, PIID_DESC)
		
			SELECT     dbo.PEDIMPDET.PIB_INDICEB, (SELECT IDE_CODIGO FROM dbo.IDENTIFICA WHERE IDE_CLAVE = 'PS' and IDE_IDENTPERM='I'), 0, isnull(dbo.SECTOR.SE_CLAVE, isnull(@fraccion,''))
			FROM         dbo.PEDIMPDET LEFT OUTER JOIN
			                      dbo.SECTOR ON dbo.PEDIMPDET.PID_SEC_IMP = dbo.SECTOR.SE_CODIGO LEFT OUTER JOIN
			                      dbo.PEDIMP ON dbo.PEDIMPDET.PI_CODIGO = dbo.PEDIMP.PI_CODIGO
			WHERE     (dbo.PEDIMPDET.PI_CODIGO = @picodigo) AND (dbo.PEDIMPDET.PIB_INDICEB IS NOT NULL) AND (PID_DEF_TIP='S')
			GROUP BY dbo.PEDIMPDET.PIB_INDICEB, dbo.PEDIMPDET.PID_SEC_IMP, dbo.SECTOR.SE_CLAVE
		end


		if (select pi_fec_pag from pedimp where pi_codigo=@picodigo)>='09/25/2006'
		if exists(select * from identificapermite where ide_codigo in (SELECT IDE_CODIGO FROM dbo.IDENTIFICA WHERE IDE_CLAVE = 'PS' and IDE_IDENTPERM='I'))
		if exists (select * from pedimpdet where (pid_def_tip='R') and pi_codigo=@picodigo)		
		begin


			SELECT @fraccion=IDEG_DESC FROM IDENTIFICAGRAL WHERE IDEG_TIPO = 'C' AND IDE_CODIGO IN (SELECT IDE_CODIGO FROM dbo.IDENTIFICA WHERE IDE_CLAVE = 'PS' and IDE_IDENTPERM='I')


			INSERT INTO TempPedimpDetIdentifica (PIB_INDICEB, IDE_CODIGO, IDED_CODIGO, PIID_DESC)
		
			SELECT     dbo.PEDIMPDET.PIB_INDICEB, (SELECT IDE_CODIGO FROM dbo.IDENTIFICA WHERE IDE_CLAVE = 'PS' and IDE_IDENTPERM='I'), 0, isnull(@fraccion,'')
			FROM         dbo.PEDIMPDET LEFT OUTER JOIN
			                      dbo.SECTOR ON dbo.PEDIMPDET.PID_SEC_IMP = dbo.SECTOR.SE_CODIGO LEFT OUTER JOIN
			                      dbo.PEDIMP ON dbo.PEDIMPDET.PI_CODIGO = dbo.PEDIMP.PI_CODIGO
			WHERE     (dbo.PEDIMPDET.PI_CODIGO = @picodigo) AND (dbo.PEDIMPDET.PIB_INDICEB IS NOT NULL) AND (PID_DEF_TIP='R')
			GROUP BY dbo.PEDIMPDET.PIB_INDICEB, dbo.PEDIMPDET.PID_SEC_IMP, dbo.SECTOR.SE_CLAVE
		end

	/* ======================= bajo tratado  ============================= */

		if exists(select * from identificapermite where ide_codigo in (SELECT IDE_CODIGO FROM dbo.IDENTIFICA WHERE IDE_CLAVE = 'TL' and IDE_IDENTPERM='I'))
		if exists (select * from pedimpdet where pid_def_tip='P' and pi_codigo=@picodigo)
		begin
			INSERT INTO TempPedimpDetIdentifica (PIB_INDICEB, IDE_CODIGO, PIID_DESC)
		
			SELECT     dbo.PEDIMPDET.PIB_INDICEB, (SELECT IDE_CODIGO FROM dbo.IDENTIFICA WHERE IDE_CLAVE = 'TL' and IDE_IDENTPERM='I'), REPLACE(REPLACE(dbo.PAIS.PA_SAAIM3,'MX', 'USA'),'MEX', 'USA')
			FROM         dbo.PEDIMPDET LEFT OUTER JOIN
			                      dbo.PEDIMP ON dbo.PEDIMPDET.PI_CODIGO = dbo.PEDIMP.PI_CODIGO LEFT OUTER JOIN
				dbo.PAIS ON dbo.PEDIMPDET.PA_ORIGEN = dbo.PAIS.PA_CODIGO
			WHERE     (dbo.PEDIMPDET.PI_CODIGO = @picodigo) AND (dbo.PEDIMPDET.PIB_INDICEB IS NOT NULL) AND (dbo.PEDIMPDET.PID_DEF_TIP = 'P')
			GROUP BY dbo.PEDIMPDET.PIB_INDICEB, dbo.PAIS.PA_SAAIM3

		end



	/* ======================= Tasa Fronteriza  ============================= */

	if @cp_clave='C1'
	begin
		if exists(select * from identificapermite where ide_codigo in (SELECT IDE_CODIGO FROM dbo.IDENTIFICA WHERE IDE_CLAVE = 'CF' and IDE_IDENTPERM='I'))
		if exists (select * from pedimpdet where pid_def_tip='F' and pi_codigo=@picodigo)
		begin
			INSERT INTO TempPedimpDetIdentifica (PIB_INDICEB, IDE_CODIGO)
                        -- Se agrego validacion de nivel Ambas y por Partida. 4-Nov-09 Manuel G.
		
			SELECT     dbo.PEDIMPDET.PIB_INDICEB, (SELECT IDE_CODIGO FROM dbo.IDENTIFICA WHERE IDE_CLAVE = 'CF' and IDE_IDENTPERM='I' and IDE_NIVEL in ('A','P'))
			FROM         dbo.PEDIMPDET LEFT OUTER JOIN
			                      dbo.PEDIMP ON dbo.PEDIMPDET.PI_CODIGO = dbo.PEDIMP.PI_CODIGO LEFT OUTER JOIN
				dbo.PAIS ON dbo.PEDIMPDET.PA_ORIGEN = dbo.PAIS.PA_CODIGO
			WHERE     (dbo.PEDIMPDET.PI_CODIGO = @picodigo) AND (dbo.PEDIMPDET.PIB_INDICEB IS NOT NULL) AND (dbo.PEDIMPDET.PID_DEF_TIP = 'F')
			GROUP BY dbo.PEDIMPDET.PIB_INDICEB, dbo.PAIS.PA_SAAIM3

		end
	end


	/* ======================= bajo 9803  ============================= */

		if exists(select * from identificapermite where ide_codigo in (SELECT IDE_CODIGO FROM dbo.IDENTIFICA WHERE IDE_CLAVE = 'ME' and IDE_IDENTPERM='I'))
		if exists (select * from pedimpdet where pid_def_tip='G' and pi_codigo=@picodigo)
		begin
			INSERT INTO TempPedimpDetIdentifica (PIB_INDICEB, IDE_CODIGO, PIID_DESC)
		
			SELECT     dbo.PEDIMPDET.PIB_INDICEB, (SELECT IDE_CODIGO FROM dbo.IDENTIFICA WHERE IDE_CLAVE = 'ME' and IDE_IDENTPERM='I'), dbo.ARANCEL.AR_FRACCION
			FROM         dbo.PEDIMPDET LEFT OUTER JOIN
			                      dbo.PEDIMP ON dbo.PEDIMPDET.PI_CODIGO = dbo.PEDIMP.PI_CODIGO LEFT OUTER JOIN dbo.ARANCEL ON
				dbo.PEDIMPDET.AR_IMPMX = dbo.ARANCEL.AR_CODIGO
			WHERE     (dbo.PEDIMPDET.PI_CODIGO = @picodigo) AND (dbo.PEDIMPDET.PIB_INDICEB IS NOT NULL) AND (dbo.PEDIMPDET.PID_DEF_TIP = 'G')
				    AND (dbo.ARANCEL.AR_FRACCION LIKE '9803%')
			GROUP BY dbo.PEDIMPDET.PIB_INDICEB, dbo.ARANCEL.AR_FRACCION

		end

	/* ======================= retorno de racas (racks)  ============================= */

		-- deposito fiscal
		if @ccp_tipo='IR' and (select cl_tipo from cliente where cl_empresa='S')='D' 
		if exists(select * from identificapermite where ide_codigo in (SELECT IDE_CODIGO FROM dbo.IDENTIFICA WHERE IDE_CLAVE = 'RA' and IDE_IDENTPERM='I'))
		if exists (select * from pedimpdet where pid_nombre like '%raca%' and pi_codigo=@picodigo)		
		begin
			INSERT INTO TempPedimpDetIdentifica (PIB_INDICEB, IDE_CODIGO)
		
			SELECT     dbo.PEDIMPDET.PIB_INDICEB, (SELECT IDE_CODIGO FROM dbo.IDENTIFICA WHERE IDE_CLAVE = 'RA' and IDE_IDENTPERM='I')
			FROM         dbo.PEDIMPDET LEFT OUTER JOIN
			                      dbo.PEDIMP ON dbo.PEDIMPDET.PI_CODIGO = dbo.PEDIMP.PI_CODIGO
			WHERE     (dbo.PEDIMPDET.PI_CODIGO = @picodigo) AND (dbo.PEDIMPDET.PIB_INDICEB IS NOT NULL) AND dbo.PEDIMPDET.PID_NOMBRE LIKE '%RACA%'
			GROUP BY dbo.PEDIMPDET.PIB_INDICEB
		end

		if @ccp_tipo<>'ED'  -- deposito fiscal
		begin
			--PRINT  'ENTRA'
			/* ======================= ES  ============================= */
			if exists(select * from identificapermite where ide_codigo in (SELECT IDE_CODIGO FROM dbo.IDENTIFICA WHERE IDE_CLAVE = 'ES' and IDE_IDENTPERM='I'))
			and not exists (select * from TempPedimpDetIdentifica where IDE_CODIGO in (SELECT IDE_CODIGO FROM dbo.IDENTIFICA WHERE IDE_CLAVE = 'ES' and IDE_IDENTPERM='I'))
			begin
				INSERT INTO TempPedimpDetIdentifica (PIB_INDICEB, IDE_CODIGO, IDED_CODIGO, PIID_DESC)
			
				SELECT     dbo.PEDIMPDET.PIB_INDICEB, (SELECT IDE_CODIGO FROM dbo.IDENTIFICA WHERE IDE_CLAVE = 'ES' and IDE_IDENTPERM='I'),
					(SELECT IDED_CODIGO FROM IDENTIFICADET
					WHERE IDE_CODIGO IN (SELECT IDE_CODIGO FROM dbo.IDENTIFICA WHERE IDE_CLAVE = 'ES' and IDE_IDENTPERM='I')
					AND IDED_VALOR='N'), 'N'
				FROM         dbo.PEDIMPDET LEFT OUTER JOIN
				                      dbo.PEDIMP ON dbo.PEDIMPDET.PI_CODIGO = dbo.PEDIMP.PI_CODIGO
				WHERE     (dbo.PEDIMPDET.PI_CODIGO = @picodigo) AND dbo.PEDIMPDET.PIB_INDICEB IS NOT NULL
				GROUP BY dbo.PEDIMPDET.PIB_INDICEB
			end
	
			/* ======================= UM  ============================= */
	
			if exists(select * from identificapermite where ide_codigo in (SELECT IDE_CODIGO FROM dbo.IDENTIFICA WHERE IDE_CLAVE = 'UM' and IDE_IDENTPERM='I'))
			and not exists (select * from TempPedimpDetIdentifica where IDE_CODIGO in (SELECT IDE_CODIGO FROM dbo.IDENTIFICA WHERE IDE_CLAVE = 'UM' and IDE_IDENTPERM='I'))
			begin
				INSERT INTO TempPedimpDetIdentifica (PIB_INDICEB, IDE_CODIGO, IDED_CODIGO, PIID_DESC)
			
				SELECT     dbo.PEDIMPDET.PIB_INDICEB, (SELECT IDE_CODIGO FROM dbo.IDENTIFICA WHERE IDE_CLAVE = 'UM' and IDE_IDENTPERM='I'),
					(SELECT IDED_CODIGO FROM IDENTIFICADET
					WHERE IDE_CODIGO IN (SELECT IDE_CODIGO FROM dbo.IDENTIFICA WHERE IDE_CLAVE = 'UM' and IDE_IDENTPERM='I')
					AND IDED_VALOR='I'), 'I'
				FROM         dbo.PEDIMPDET LEFT OUTER JOIN
				                      dbo.PEDIMP ON dbo.PEDIMPDET.PI_CODIGO = dbo.PEDIMP.PI_CODIGO
				WHERE     (dbo.PEDIMPDET.PI_CODIGO = @picodigo) AND dbo.PEDIMPDET.PIB_INDICEB IS NOT NULL
				GROUP BY dbo.PEDIMPDET.PIB_INDICEB
			end
		end


	/* ========== los identificadores insertados directamente en las partidas de la factura de entrada ============ */

	if @pi_movimiento='E'
	begin
		if @ccp_tipo<>'RE'  and exists (select * from factimp where pi_codigo=@picodigo)
		begin
			
			INSERT INTO TempPedimpDetIdentifica (PIB_INDICEB, IDE_CODIGO, IDED_CODIGO, PIID_DESC, IDED_CODIGO2, PIID_DESC2, IDED_CODIGO3, PIID_DESC3)
			SELECT    dbo.PEDIMPDET.PIB_INDICEB, dbo.FACTIMPDETIDENTIFICA.IDE_CODIGO, dbo.FACTIMPDETIDENTIFICA.IDED_CODIGO, dbo.FACTIMPDETIDENTIFICA.FIID_DESC,
					dbo.FACTIMPDETIDENTIFICA.IDED_CODIGO2, dbo.FACTIMPDETIDENTIFICA.FIID_DESC2, dbo.FACTIMPDETIDENTIFICA.IDED_CODIGO3, dbo.FACTIMPDETIDENTIFICA.FIID_DESC3
			FROM         dbo.FACTIMPDET INNER JOIN
			                      dbo.PEDIMPDET ON dbo.FACTIMPDET.PID_INDICEDLIGA = dbo.PEDIMPDET.PID_INDICED INNER JOIN
			                      dbo.FACTIMPDETIDENTIFICA ON dbo.FACTIMPDET.FID_INDICED = dbo.FACTIMPDETIDENTIFICA.FID_INDICED
			WHERE     (dbo.PEDIMPDET.PI_CODIGO = @picodigo) and dbo.FACTIMPDETIDENTIFICA.IDE_CODIGO
			NOT IN (SELECT IDE_CODIGO from TempPedimpDetIdentifica) and dbo.FACTIMPDETIDENTIFICA.IDE_CODIGO in (select ide_codigo from identificapermite)
			GROUP BY dbo.PEDIMPDET.PIB_INDICEB, dbo.FACTIMPDETIDENTIFICA.IDE_CODIGO, dbo.FACTIMPDETIDENTIFICA.IDED_CODIGO, dbo.FACTIMPDETIDENTIFICA.FIID_DESC,
					dbo.FACTIMPDETIDENTIFICA.IDED_CODIGO2, dbo.FACTIMPDETIDENTIFICA.FIID_DESC2, dbo.FACTIMPDETIDENTIFICA.IDED_CODIGO3, dbo.FACTIMPDETIDENTIFICA.FIID_DESC3
		end
		else
		if exists (select * from factimp where pi_rectifica=@picodigo)
		begin
			INSERT INTO TempPedimpDetIdentifica (PIB_INDICEB,IDE_CODIGO, IDED_CODIGO, PIID_DESC, IDED_CODIGO2, PIID_DESC2, IDED_CODIGO3, PIID_DESC3)
			SELECT     dbo.PEDIMPDET.PIB_INDICEB, dbo.FACTIMPDETIDENTIFICA.IDE_CODIGO, dbo.FACTIMPDETIDENTIFICA.IDED_CODIGO, dbo.FACTIMPDETIDENTIFICA.FIID_DESC,
						dbo.FACTIMPDETIDENTIFICA.IDED_CODIGO2, dbo.FACTIMPDETIDENTIFICA.FIID_DESC2, dbo.FACTIMPDETIDENTIFICA.IDED_CODIGO3, dbo.FACTIMPDETIDENTIFICA.FIID_DESC3
			FROM         dbo.FACTIMPDET INNER JOIN
			                      dbo.PEDIMPDET ON dbo.FACTIMPDET.PID_INDICEDLIGAR1 = dbo.PEDIMPDET.PID_INDICED INNER JOIN
			                      dbo.FACTIMPDETIDENTIFICA ON dbo.FACTIMPDET.FID_INDICED = dbo.FACTIMPDETIDENTIFICA.FID_INDICED
			WHERE     (dbo.PEDIMPDET.PI_CODIGO = @picodigo) and dbo.FACTIMPDETIDENTIFICA.IDE_CODIGO
			NOT IN (SELECT IDE_CODIGO from TempPedimpDetIdentifica) and dbo.FACTIMPDETIDENTIFICA.IDE_CODIGO in (select ide_codigo from identificapermite)
		
			GROUP BY dbo.PEDIMPDET.PIB_INDICEB, dbo.FACTIMPDETIDENTIFICA.IDE_CODIGO, dbo.FACTIMPDETIDENTIFICA.IDED_CODIGO, dbo.FACTIMPDETIDENTIFICA.FIID_DESC,
					dbo.FACTIMPDETIDENTIFICA.IDED_CODIGO2, dbo.FACTIMPDETIDENTIFICA.FIID_DESC2, dbo.FACTIMPDETIDENTIFICA.IDED_CODIGO3, dbo.FACTIMPDETIDENTIFICA.FIID_DESC3
		end

		/*  En importaciones, utilizar los identificadores del uso de la mercanc-a "UM" para SAGAR y SALUD y del estado "ES" para Econom-a */


	end
	else -- salida
	begin
		if @ccp_tipo<>'RE'  
		begin
			if exists (select * from factexp where pi_codigo=@picodigo)
			INSERT INTO TempPedimpDetIdentifica (PIB_INDICEB,IDE_CODIGO, IDED_CODIGO, PIID_DESC, IDED_CODIGO2, PIID_DESC2, IDED_CODIGO3, PIID_DESC3)
			SELECT     dbo.PEDIMPDET.PIB_INDICEB, dbo.FACTEXPDETIDENTIFICA.IDE_CODIGO, dbo.FACTEXPDETIDENTIFICA.IDED_CODIGO, dbo.FACTEXPDETIDENTIFICA.FEID_DESC,
						dbo.FACTEXPDETIDENTIFICA.IDED_CODIGO2, dbo.FACTEXPDETIDENTIFICA.FEID_DESC2, dbo.FACTEXPDETIDENTIFICA.IDED_CODIGO3, dbo.FACTEXPDETIDENTIFICA.FEID_DESC3
			FROM         dbo.FACTEXPDET INNER JOIN
			                      dbo.PEDIMPDET ON dbo.FACTEXPDET.PID_INDICEDLIGA = dbo.PEDIMPDET.PID_INDICED INNER JOIN
			                      dbo.FACTEXPDETIDENTIFICA ON dbo.FACTEXPDET.FED_INDICED = dbo.FACTEXPDETIDENTIFICA.FED_INDICED
			WHERE     (dbo.PEDIMPDET.PI_CODIGO = @picodigo) and dbo.FACTEXPDETIDENTIFICA.IDE_CODIGO
			NOT IN (SELECT IDE_CODIGO from TempPedimpDetIdentifica) and dbo.FACTEXPDETIDENTIFICA.IDE_CODIGO in (select ide_codigo from identificapermite)
			GROUP BY dbo.PEDIMPDET.PIB_INDICEB, dbo.FACTEXPDETIDENTIFICA.IDE_CODIGO, dbo.FACTEXPDETIDENTIFICA.IDED_CODIGO, dbo.FACTEXPDETIDENTIFICA.FEID_DESC,
					dbo.FACTEXPDETIDENTIFICA.IDED_CODIGO2, dbo.FACTEXPDETIDENTIFICA.FEID_DESC2, dbo.FACTEXPDETIDENTIFICA.IDED_CODIGO3, dbo.FACTEXPDETIDENTIFICA.FEID_DESC3


	
		end
		else
		if exists (select * from factexp where pi_rectifica=@picodigo)
		begin

			INSERT INTO TempPedimpDetIdentifica (PIB_INDICEB, IDE_CODIGO, IDED_CODIGO, PIID_DESC, IDED_CODIGO2, PIID_DESC2, IDED_CODIGO3, PIID_DESC3)
			SELECT     dbo.PEDIMPDET.PIB_INDICEB, dbo.FACTEXPDETIDENTIFICA.IDE_CODIGO, dbo.FACTEXPDETIDENTIFICA.IDED_CODIGO, dbo.FACTEXPDETIDENTIFICA.FEID_DESC,
						dbo.FACTEXPDETIDENTIFICA.IDED_CODIGO2, dbo.FACTEXPDETIDENTIFICA.FEID_DESC2, dbo.FACTEXPDETIDENTIFICA.IDED_CODIGO3, dbo.FACTEXPDETIDENTIFICA.FEID_DESC3
			
			FROM         dbo.FACTEXPDET INNER JOIN
			                      dbo.PEDIMPDET ON dbo.FACTEXPDET.PID_INDICEDLIGAR1 = dbo.PEDIMPDET.PID_INDICED INNER JOIN
			                      dbo.FACTEXPDETIDENTIFICA ON dbo.FACTEXPDET.FED_INDICED = dbo.FACTEXPDETIDENTIFICA.FED_INDICED
			WHERE     (dbo.PEDIMPDET.PI_CODIGO = @picodigo) and dbo.FACTEXPDETIDENTIFICA.IDE_CODIGO
			NOT IN (SELECT IDE_CODIGO from TempPedimpDetIdentifica) and dbo.FACTEXPDETIDENTIFICA.IDE_CODIGO in (select ide_codigo from identificapermite)
			GROUP BY dbo.PEDIMPDET.PIB_INDICEB, dbo.FACTEXPDETIDENTIFICA.IDE_CODIGO, dbo.FACTEXPDETIDENTIFICA.IDED_CODIGO, dbo.FACTEXPDETIDENTIFICA.FEID_DESC,
						dbo.FACTEXPDETIDENTIFICA.IDED_CODIGO2, dbo.FACTEXPDETIDENTIFICA.FEID_DESC2, dbo.FACTEXPDETIDENTIFICA.IDED_CODIGO3, dbo.FACTEXPDETIDENTIFICA.FEID_DESC3

		end



		if @ccp_tipo='IR' --H1
		begin  
				/* ======================= DT complemento 12  retorno en el mismo estado  ============================= */
				if exists(select * from identificapermite where ide_codigo in (SELECT IDE_CODIGO FROM dbo.IDENTIFICA WHERE IDE_CLAVE = 'DT' and IDE_IDENTPERM='I'))
				and not exists (select * from TempPedimpDetIdentifica where IDE_CODIGO in (SELECT IDE_CODIGO FROM dbo.IDENTIFICA WHERE IDE_CLAVE = 'DT' and IDE_IDENTPERM='I'))
				begin
					INSERT INTO TempPedimpDetIdentifica (PIB_INDICEB, IDE_CODIGO, IDED_CODIGO, PIID_DESC)
				
					SELECT     dbo.PEDIMPDET.PIB_INDICEB, (SELECT IDE_CODIGO FROM dbo.IDENTIFICA WHERE IDE_CLAVE = 'DT' and IDE_IDENTPERM='I'),
						(SELECT IDED_CODIGO FROM IDENTIFICADET
						WHERE IDE_CODIGO IN (SELECT IDE_CODIGO FROM dbo.IDENTIFICA WHERE IDE_CLAVE = 'DT' and IDE_IDENTPERM='I')
						AND IDED_VALOR='12'), '12'
					FROM         dbo.PEDIMPDET LEFT OUTER JOIN
					                      dbo.PEDIMP ON dbo.PEDIMPDET.PI_CODIGO = dbo.PEDIMP.PI_CODIGO
					WHERE     (dbo.PEDIMPDET.PI_CODIGO = @picodigo) AND dbo.PEDIMPDET.PIB_INDICEB IS NOT NULL
						AND dbo.PEDIMPDET.PID_DEF_TIP='S' AND dbo.PEDIMPDET.PA_ORIGEN=233
					GROUP BY dbo.PEDIMPDET.PIB_INDICEB
				end


		end

		if @ccp_tipo='ER'
		begin  

			/* ======================= DT complemento 17 de Desperdicio  ============================= */
			if (select PI_DESP_EQUIPO from pedimp where pi_codigo=@picodigo)='S'
			begin
				if exists(select * from identificapermite where ide_codigo in (SELECT IDE_CODIGO FROM dbo.IDENTIFICA WHERE IDE_CLAVE = 'DT' and IDE_IDENTPERM='I'))
				and not exists (select * from TempPedimpDetIdentifica where IDE_CODIGO in (SELECT IDE_CODIGO FROM dbo.IDENTIFICA WHERE IDE_CLAVE = 'DT' and IDE_IDENTPERM='I'))
				begin
					INSERT INTO TempPedimpDetIdentifica (PIB_INDICEB, IDE_CODIGO, IDED_CODIGO, PIID_DESC)
				
					SELECT     dbo.PEDIMPDET.PIB_INDICEB, (SELECT IDE_CODIGO FROM dbo.IDENTIFICA WHERE IDE_CLAVE = 'DT' and IDE_IDENTPERM='I'),
						(SELECT IDED_CODIGO FROM IDENTIFICADET
						WHERE IDE_CODIGO IN (SELECT IDE_CODIGO FROM dbo.IDENTIFICA WHERE IDE_CLAVE = 'DT' and IDE_IDENTPERM='I')
						AND IDED_VALOR='17'), '17'
					FROM         dbo.PEDIMPDET LEFT OUTER JOIN
					                      dbo.PEDIMP ON dbo.PEDIMPDET.PI_CODIGO = dbo.PEDIMP.PI_CODIGO
					WHERE     (dbo.PEDIMPDET.PI_CODIGO = @picodigo) AND dbo.PEDIMPDET.PIB_INDICEB IS NOT NULL
						AND dbo.PEDIMPDET.PID_DEF_TIP='S' AND dbo.PEDIMPDET.PA_ORIGEN=233
					GROUP BY dbo.PEDIMPDET.PIB_INDICEB
				end
			end
			else
			begin

				if (select cf_pagocontribucion from configuracion)='E'  -- pago a la entrada
				begin
					/* ======================= DT complemento 2 pago a la importacion  ============================= */
					if exists(select * from identificapermite where ide_codigo in (SELECT IDE_CODIGO FROM dbo.IDENTIFICA WHERE IDE_CLAVE = 'DT' and IDE_IDENTPERM='I'))
					and not exists (select * from TempPedimpDetIdentifica where IDE_CODIGO in (SELECT IDE_CODIGO FROM dbo.IDENTIFICA WHERE IDE_CLAVE = 'DT' and IDE_IDENTPERM='I'))
					begin
						INSERT INTO TempPedimpDetIdentifica (PIB_INDICEB, IDE_CODIGO, IDED_CODIGO, PIID_DESC)
					
						SELECT     dbo.PEDIMPDET.PIB_INDICEB, (SELECT IDE_CODIGO FROM dbo.IDENTIFICA WHERE IDE_CLAVE = 'DT' and IDE_IDENTPERM='I'),
							(SELECT IDED_CODIGO FROM IDENTIFICADET
							WHERE IDE_CODIGO IN (SELECT IDE_CODIGO FROM dbo.IDENTIFICA WHERE IDE_CLAVE = 'DT' and IDE_IDENTPERM='I')
							AND IDED_VALOR='2'), '2'
						FROM         dbo.PEDIMPDET LEFT OUTER JOIN
						                      dbo.PEDIMP ON dbo.PEDIMPDET.PI_CODIGO = dbo.PEDIMP.PI_CODIGO
						WHERE     (dbo.PEDIMPDET.PI_CODIGO = @picodigo) AND dbo.PEDIMPDET.PIB_INDICEB IS NOT NULL
							AND dbo.PEDIMPDET.PA_ORIGEN=233
						GROUP BY dbo.PEDIMPDET.PIB_INDICEB
					end



				end
				else
				begin

					/* ======================= DT complemento 11 Destino diferente de USA  ============================= */
					if exists(select * from identificapermite where ide_codigo in (SELECT IDE_CODIGO FROM dbo.IDENTIFICA WHERE IDE_CLAVE = 'DT' and IDE_IDENTPERM='I'))
					and not exists (select * from TempPedimpDetIdentifica where IDE_CODIGO in (SELECT IDE_CODIGO FROM dbo.IDENTIFICA WHERE IDE_CLAVE = 'DT' and IDE_IDENTPERM='I'))
					begin
						INSERT INTO TempPedimpDetIdentifica (PIB_INDICEB, IDE_CODIGO, IDED_CODIGO, PIID_DESC)
					
						SELECT     dbo.PEDIMPDET.PIB_INDICEB, (SELECT IDE_CODIGO FROM dbo.IDENTIFICA WHERE IDE_CLAVE = 'DT' and IDE_IDENTPERM='I'),
							(SELECT IDED_CODIGO FROM IDENTIFICADET
							WHERE IDE_CODIGO IN (SELECT IDE_CODIGO FROM dbo.IDENTIFICA WHERE IDE_CLAVE = 'DT' and IDE_IDENTPERM='I')
							AND IDED_VALOR='11'), '11'
						FROM         dbo.PEDIMPDET LEFT OUTER JOIN
						                      dbo.PEDIMP ON dbo.PEDIMPDET.PI_CODIGO = dbo.PEDIMP.PI_CODIGO
						WHERE     (dbo.PEDIMPDET.PI_CODIGO = @picodigo) AND dbo.PEDIMPDET.PIB_INDICEB IS NOT NULL
							AND dbo.PEDIMPDET.PA_ORIGEN<>233
						GROUP BY dbo.PEDIMPDET.PIB_INDICEB
					end

/*
					if (select cf_pagocontribucion from configuracion)='J'  -- pago a la salida en pedimento J1
					begin
	
						-- ======================= DT complemento 11 Destino USA  ============================= 
						if exists(select * from identificapermite where ide_codigo in (SELECT IDE_CODIGO FROM dbo.IDENTIFICA WHERE IDE_CLAVE = 'DT' and IDE_IDENTPERM='I'))
						and not exists (select * from TempPedimpDetIdentifica where IDE_CODIGO in (SELECT IDE_CODIGO FROM dbo.IDENTIFICA WHERE IDE_CLAVE = 'DT' and IDE_IDENTPERM='I'))
						begin
							INSERT INTO TempPedimpDetIdentifica (PIB_INDICEB, IDE_CODIGO, IDED_CODIGO, PIID_DESC)
						
							SELECT     dbo.PEDIMPDET.PIB_INDICEB, (SELECT IDE_CODIGO FROM dbo.IDENTIFICA WHERE IDE_CLAVE = 'DT' and IDE_IDENTPERM='I'),
								(SELECT IDED_CODIGO FROM IDENTIFICADET
								WHERE IDE_CODIGO IN (SELECT IDE_CODIGO FROM dbo.IDENTIFICA WHERE IDE_CLAVE = 'DT' and IDE_IDENTPERM='I')
								AND IDED_VALOR='11'), '11'
							FROM         dbo.PEDIMPDET LEFT OUTER JOIN
							                      dbo.PEDIMP ON dbo.PEDIMPDET.PI_CODIGO = dbo.PEDIMP.PI_CODIGO
							WHERE     (dbo.PEDIMPDET.PI_CODIGO = @picodigo) AND dbo.PEDIMPDET.PIB_INDICEB IS NOT NULL
								AND dbo.PEDIMPDET.PA_ORIGEN=233 and PIB_IMPORTECONTR>0
							GROUP BY dbo.PEDIMPDET.PIB_INDICEB
						end
					end
					else
					begin
						-- ======================= DT complemento 11 Destino diferente de USA  ============================= 
						if exists(select * from identificapermite where ide_codigo in (SELECT IDE_CODIGO FROM dbo.IDENTIFICA WHERE IDE_CLAVE = 'DT' and IDE_IDENTPERM='I'))
						and not exists (select * from TempPedimpDetIdentifica where IDE_CODIGO in (SELECT IDE_CODIGO FROM dbo.IDENTIFICA WHERE IDE_CLAVE = 'DT' and IDE_IDENTPERM='I'))
						begin
							INSERT INTO TempPedimpDetIdentifica (PIB_INDICEB, IDE_CODIGO, IDED_CODIGO, PIID_DESC)
						
							SELECT     dbo.PEDIMPDET.PIB_INDICEB, (SELECT IDE_CODIGO FROM dbo.IDENTIFICA WHERE IDE_CLAVE = 'DT' and IDE_IDENTPERM='I'),
								(SELECT IDED_CODIGO FROM IDENTIFICADET
								WHERE IDE_CODIGO IN (SELECT IDE_CODIGO FROM dbo.IDENTIFICA WHERE IDE_CLAVE = 'DT' and IDE_IDENTPERM='I')
								AND IDED_VALOR='11'), '11'
							FROM         dbo.PEDIMPDET LEFT OUTER JOIN
							                      dbo.PEDIMP ON dbo.PEDIMPDET.PI_CODIGO = dbo.PEDIMP.PI_CODIGO
							WHERE     (dbo.PEDIMPDET.PI_CODIGO = @picodigo) AND dbo.PEDIMPDET.PIB_INDICEB IS NOT NULL
								AND dbo.PEDIMPDET.PA_ORIGEN=233
							GROUP BY dbo.PEDIMPDET.PIB_INDICEB
						end

					end*/

				end
			end
	
		end



	end	

alter table [PedImpDetIdentifica] disable trigger [UPDATE_PEDIMPDETIDENTIFICA]

		insert into PedImpDetIdentifica (PIID_CODIGO, PIB_INDICEB, IDE_CODIGO, IDED_CODIGO, PIID_DESC, PIID_DESC2, PIID_TIPO, IDED_CODIGO2, IDED_CODIGO3, PIID_DESC3 )
	
		SELECT     TempPedImpDetIdentifica.PIID_CODIGO, TempPedImpDetIdentifica.PIB_INDICEB, TempPedImpDetIdentifica.IDE_CODIGO, 
		                      TempPedImpDetIdentifica.IDED_CODIGO, TempPedImpDetIdentifica.PIID_DESC, TempPedImpDetIdentifica.PIID_DESC2, 'N',
		                      TempPedImpDetIdentifica.IDED_CODIGO2, TempPedImpDetIdentifica.IDED_CODIGO3, TempPedImpDetIdentifica.PIID_DESC3
		FROM         TempPedImpDetIdentifica INNER JOIN
		                      PEDIMPDET ON TempPedImpDetIdentifica.PIB_INDICEB = PEDIMPDET.PIB_INDICEB
		WHERE     (PEDIMPDET.PI_CODIGO = @picodigo)
		GROUP BY TempPedImpDetIdentifica.PIID_CODIGO, TempPedImpDetIdentifica.PIB_INDICEB, TempPedImpDetIdentifica.IDE_CODIGO, 
		                      TempPedImpDetIdentifica.IDED_CODIGO, TempPedImpDetIdentifica.PIID_DESC, TempPedImpDetIdentifica.PIID_TIPO,
				TempPedImpDetIdentifica.PIID_DESC2, TempPedImpDetIdentifica.IDED_CODIGO2, TempPedImpDetIdentifica.IDED_CODIGO3, TempPedImpDetIdentifica.PIID_DESC3
				
alter table [PedImpDetIdentifica] enable trigger [UPDATE_PEDIMPDETIDENTIFICA]





select @Piid_codigo= isnull(max(Piid_codigo),0) from pedimpdetidentifica

	update consecutivo
	set cv_codigo =  isnull(@Piid_codigo,0) + 1
	where cv_tipo = 'PIID'

	exec sp_droptable 'identificapermite'

	if @CCP_TIPO='IE' and @pi_movimiento='E' 
	exec SP_AGREGAIDENITIFICAEN @picodigo, '0'
GO
