SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[SP_actualizaTasaSectorPT] (@FE_CODIGO INT, @ACTUALIZACION CHAR(1)='N')   as


declare @totalpartidas int, @ccp_tipo varchar(5), @VINPCMAX decimal(38,6), @PI_FEC_ENTPI datetime, @ma_hijo int, @Paorigen int, 
@fe_fecha datetime, @pi_fec_sal datetime, @KAP_INDICED_PED int, @kap_codigo int, @Cantidad decimal(38,6), @CostTot decimal(38,6), @cpe_codigo int

	




	IF @ACTUALIZACION='N'
	BEGIN

		delete from KARDESPEDPPS where kap_codigo in
		(select kap_codigo from kardesped where KAP_FACTRANS=@FE_CODIGO)


		IF (SELECT CF_CAMBIOTASASEC FROM CONFIGURACION)='S' 
		begin
			-- inserta en la tabla kardespedpps las descargas donde el sector del componente es diferente del sector del pt
			INSERT INTO KARDESPEDPPS(KAP_CODIGO, KAP_COSTOUNITACT, KAP_FT_ACT)
			SELECT     KARDESPED.KAP_CODIGO, round(PEDIMPDET.PID_COS_UNIADU,6), 1
			FROM         dbo.KARDESPED INNER JOIN
			                      dbo.FACTEXPDET ON dbo.KARDESPED.KAP_INDICED_FACT = dbo.FACTEXPDET.FED_INDICED INNER JOIN
			                      dbo.PEDIMPDET ON dbo.KARDESPED.KAP_INDICED_PED = dbo.PEDIMPDET.PID_INDICED AND ISNULL(dbo.FACTEXPDET.SE_CODIGO, 0) 
			                      <> ISNULL(dbo.PEDIMPDET.PID_SEC_IMP, 0) INNER JOIN
			                      dbo.PEDIMP ON dbo.PEDIMPDET.PI_CODIGO = dbo.PEDIMP.PI_CODIGO
			WHERE     (dbo.KARDESPED.KAP_CODIGO NOT IN
			                          (SELECT     KARDESPEDPPS.KAP_CODIGO
			                            FROM          KARDESPEDPPS)) AND (dbo.PEDIMPDET.PID_DEF_TIP = 'S') AND (dbo.PEDIMP.PI_TIPO IN ('A', 'C'))
			AND (dbo.KARDESPED.KAP_FACTRANS = @FE_CODIGO) 

			--Yolanda Avila
			--2010-09-07
			--Se comento esta parte ya que cuando el PT tiene sector IIb y el componente tiene IIa ó IIb el sistema ignoraba estos registros y no hacia el cambio y se iba por la TIGIE	
			--2=IIa y 19=IIb
			/*DELETE FROM KARDESPEDPPS WHERE KAP_CODIGO IN
			(SELECT     KARDESPED.KAP_CODIGO
			FROM         dbo.KARDESPED INNER JOIN
			                      dbo.FACTEXPDET ON dbo.KARDESPED.KAP_INDICED_FACT = dbo.FACTEXPDET.FED_INDICED INNER JOIN
			                      dbo.PEDIMPDET ON dbo.KARDESPED.KAP_INDICED_PED = dbo.PEDIMPDET.PID_INDICED INNER JOIN
			                      dbo.PEDIMP ON dbo.PEDIMPDET.PI_CODIGO = dbo.PEDIMP.PI_CODIGO
			WHERE     (dbo.PEDIMPDET.PID_DEF_TIP = 'S') AND (dbo.PEDIMP.PI_TIPO IN ('A', 'C'))
			AND (dbo.KARDESPED.KAP_FACTRANS = @FE_CODIGO) 
			AND ISNULL(dbo.FACTEXPDET.SE_CODIGO, 0) =19 AND (ISNULL(dbo.PEDIMPDET.PID_SEC_IMP, 0)=2 OR ISNULL(dbo.PEDIMPDET.PID_SEC_IMP, 0)=19))
	       */
		end

	
		if (SELECT     COUNT(KARDESPEDPPS.KAP_TASAFINAL) 
		FROM         KARDESPEDPPS INNER JOIN
		                      KARDESPED ON KARDESPEDPPS.KAP_CODIGO = KARDESPED.KAP_CODIGO
		WHERE     KARDESPED.KAP_FACTRANS = @FE_CODIGO AND KARDESPEDPPS.KAP_TASAFINAL = - 1)>0 
		begin
		
			select @fe_fecha=fe_fecha from factexp where fe_codigo=@FE_CODIGO
		
			
			IF (SELECT CF_CAMBIOTASASEC FROM CONFIGURACION)='S' 
			begin

				-- actualiza las tasas que se encuentran en sectorara donde el sector del componente es diferente del sector del pt
				UPDATE KARDESPEDPPS
				SET     KARDESPEDPPS.KAP_TASAFINAL= isnull(SECTORARA.SA_PORCENT,-1), KAP_SECIMP=FACTEXPDET.SE_CODIGO,
				KARDESPEDPPS.KAP_DEF_TIP='S', KARDESPEDPPS.SPI_CODIGO=0
				FROM         KARDESPED INNER JOIN
				                      FACTEXPDET ON KARDESPED.KAP_INDICED_FACT = FACTEXPDET.FED_INDICED INNER JOIN
				                      PEDIMPDET ON KARDESPED.KAP_INDICED_PED = PEDIMPDET.PID_INDICED AND 
				                      FACTEXPDET.SE_CODIGO <> PEDIMPDET.PID_SEC_IMP INNER JOIN
				                      SECTORARA ON FACTEXPDET.SE_CODIGO = SECTORARA.SE_CODIGO AND 
				                      PEDIMPDET.AR_IMPMX = SECTORARA.AR_CODIGO INNER JOIN
				                      KARDESPEDPPS ON KARDESPED.KAP_CODIGO = KARDESPEDPPS.KAP_CODIGO
				WHERE     (PEDIMPDET.PID_DEF_TIP = 'S') AND
				(SECTORARA.SA_PORCENT > - 1) AND (FACTEXPDET.FE_CODIGO = @FE_CODIGO)



				-- actualiza las tasas que no se encuentran en pps, (tasa general)
				UPDATE KARDESPEDPPS
				SET     KARDESPEDPPS.KAP_TASAFINAL= isnull(ARANCEL.AR_ADVDEF,-1), KARDESPEDPPS.KAP_DEF_TIP='G', KARDESPEDPPS.KAP_SECIMP=0,
				KARDESPEDPPS.SPI_CODIGO=0
				FROM         KARDESPED INNER JOIN
				                      FACTEXPDET ON KARDESPED.KAP_INDICED_FACT = FACTEXPDET.FED_INDICED INNER JOIN
				                      PEDIMPDET ON KARDESPED.KAP_INDICED_PED = PEDIMPDET.PID_INDICED AND 
				                      FACTEXPDET.SE_CODIGO <> PEDIMPDET.PID_SEC_IMP INNER JOIN
				                      KARDESPEDPPS ON KARDESPED.KAP_CODIGO = KARDESPEDPPS.KAP_CODIGO LEFT OUTER JOIN
				                      ARANCEL ON PEDIMPDET.AR_IMPMX = ARANCEL.AR_CODIGO LEFT OUTER JOIN
				                      SECTORARA ON FACTEXPDET.SE_CODIGO = SECTORARA.SE_CODIGO AND 
				                      PEDIMPDET.AR_IMPMX = SECTORARA.AR_CODIGO
				WHERE     (PEDIMPDET.PID_DEF_TIP = 'S') AND (SECTORARA.SE_CODIGO IS NULL)
				AND (FACTEXPDET.FE_CODIGO = @FE_CODIGO) and (KARDESPEDPPS.KAP_TASAFINAL>=ARANCEL.AR_ADVDEF OR KARDESPEDPPS.KAP_TASAFINAL=-1)




				-- actualiza las tasas que no se encuentran en pps, (Certificado)
				UPDATE KARDESPEDPPS
				SET    KARDESPEDPPS.SPI_CODIGO=ISNULL((SELECT PAIS.SPI_CODIGO FROM PAIS WHERE PAIS.PA_CODIGO=PEDIMPDET.PA_ORIGEN),0),
					KARDESPEDPPS.KAP_DEF_TIP='P', KARDESPEDPPS.KAP_SECIMP=0,
					KARDESPEDPPS.KAP_TASAFINAL= isnull((SELECT PAISARA.PAR_BEN
							FROM PAISARA WHERE PAISARA.AR_CODIGO=PEDIMPDET.AR_IMPMX 
							AND PAISARA.PA_CODIGO =PEDIMPDET.PA_ORIGEN AND 
						               PAISARA.SPI_CODIGO = KARDESPEDPPS.SPI_CODIGO),-1) 
				FROM         KARDESPED INNER JOIN
				                      FACTEXPDET ON KARDESPED.KAP_INDICED_FACT = FACTEXPDET.FED_INDICED INNER JOIN
				                      PEDIMPDET ON KARDESPED.KAP_INDICED_PED = PEDIMPDET.PID_INDICED AND 
				                      FACTEXPDET.SE_CODIGO <> PEDIMPDET.PID_SEC_IMP INNER JOIN
				                      KARDESPEDPPS ON KARDESPED.KAP_CODIGO = KARDESPEDPPS.KAP_CODIGO LEFT OUTER JOIN
				                      ARANCEL ON PEDIMPDET.AR_IMPMX = ARANCEL.AR_CODIGO LEFT OUTER JOIN
				                      SECTORARA ON FACTEXPDET.SE_CODIGO = SECTORARA.SE_CODIGO AND 
				                      PEDIMPDET.AR_IMPMX = SECTORARA.AR_CODIGO
				WHERE     (PEDIMPDET.PID_DEF_TIP = 'S') AND (SECTORARA.SE_CODIGO IS NULL)
				AND (FACTEXPDET.FE_CODIGO = @FE_CODIGO) and (KARDESPEDPPS.KAP_TASAFINAL=-1 OR KARDESPEDPPS.KAP_TASAFINAL>(SELECT PAISARA.PAR_BEN
							FROM PAISARA WHERE PAISARA.AR_CODIGO=PEDIMPDET.AR_IMPMX 
							AND PAISARA.PA_CODIGO =PEDIMPDET.PA_ORIGEN AND 
						               PAISARA.SPI_CODIGO = KARDESPEDPPS.SPI_CODIGO))
				and PEDIMPDET.MA_CODIGO IN
					(SELECT     CERTORIGMPDET.MA_CODIGO
					FROM         CERTORIGMP INNER JOIN
					                      CERTORIGMPDET ON CERTORIGMP.CMP_CODIGO = CERTORIGMPDET.CMP_CODIGO INNER JOIN
					                      ARANCEL ARA ON CERTORIGMPDET.AR_CODIGO = ARA.AR_CODIGO
					WHERE     (CERTORIGMP.CMP_IFECHA <= @fe_fecha) AND (CERTORIGMP.CMP_VFECHA >= @fe_fecha)
					AND CERTORIGMP.CMP_ESTATUS='V' AND  LEFT(REPLACE(CERTORIGMPDET.CMP_FRACCION,'.',''), 6) =ARANCEL.AR_FRACCION AND CERTORIGMPDET.PA_CLASE=PEDIMPDET.PA_ORIGEN				
					GROUP BY CERTORIGMPDET.MA_CODIGO)
				AND (SELECT PAISARA.PAR_BEN
							FROM PAISARA WHERE PAISARA.AR_CODIGO=PEDIMPDET.AR_IMPMX 
							AND PAISARA.PA_CODIGO =PEDIMPDET.PA_ORIGEN AND 
						               PAISARA.SPI_CODIGO = KARDESPEDPPS.SPI_CODIGO)  IS NOT NULL


				-- REGLA OCTAVA
				declare cur_TipoTasa cursor for
					SELECT     KARDESPEDPPS.KAP_CODIGO, KARDESPED.KAP_CANTDESC, 
					      KARDESPED.KAP_CANTDESC * PEDIMPDET.PID_COS_UNIADU AS FID_COS_TOT, 
						PEDIMPDET.PA_ORIGEN, KARDESPED.MA_HIJO					      
					FROM  KARDESPEDPPS INNER JOIN
					      KARDESPED ON KARDESPEDPPS.KAP_CODIGO = KARDESPED.KAP_CODIGO INNER JOIN
					      PEDIMPDET ON KARDESPED.KAP_INDICED_PED = PEDIMPDET.PID_INDICED LEFT OUTER JOIN
					      ARANCEL ON PEDIMPDET.AR_IMPMX = ARANCEL.AR_CODIGO
					WHERE     KARDESPED.KAP_FACTRANS = @FE_CODIGO AND (KARDESPEDPPS.KAP_TASAFINAL = - 1
						OR KARDESPEDPPS.KAP_TASAFINAL>ARANCEL.AR_PORCENT_8VA) AND ARANCEL.AR_PORCENT_8VA<>-1
				open cur_TipoTasa
					FETCH NEXT FROM  cur_TipoTasa INTO @kap_codigo, @Cantidad, @CostTot, @Paorigen, @ma_hijo
					WHILE (@@FETCH_STATUS = 0) 
					BEGIN
					


						select @cpe_codigo=max(cpe_codigo) from MAESTROCATEG where ma_codigo=@ma_hijo and
						cpe_codigo in (SELECT PERMISODET.MA_GENERICO
								FROM PERMISODET INNER JOIN
								     PERMISO ON PERMISODET.PE_CODIGO = PERMISO.PE_CODIGO INNER JOIN
								     CONFIGURAPERMISOREL ON PERMISO.IDE_CODIGO = CONFIGURAPERMISOREL.IDE_CODIGO
								WHERE (CONFIGURAPERMISOREL.CFR_SALDOCARATULA = 'S') AND (PERMISO.PE_SALDO > 0) AND (PERMISO.PE_ESTATUS <> 'C'))

						if @cpe_codigo is null
						set @cpe_codigo=0

						if @cpe_codigo>0			
        	        			exec SP_AFECTAPERMISOKARDES @KAP_CODIGO, @FE_CODIGO, @CPE_CODIGO, @Paorigen, @CostTot, @Cantidad
						
			
				
					FETCH NEXT FROM  cur_TipoTasa INTO @kap_codigo, @Cantidad, @CostTot, @Paorigen, @ma_hijo
				END
				CLOSE cur_TipoTasa
				DEALLOCATE cur_TipoTasa
	

		


				-- actualiza las tasas que no se encuentran en pps, (tasa general)
				UPDATE KARDESPEDPPS
				SET     KARDESPEDPPS.KAP_TASAFINAL= isnull(ARANCEL.AR_ADVDEF,-1), KARDESPEDPPS.KAP_DEF_TIP='G', KARDESPEDPPS.KAP_SECIMP=0,
				KARDESPEDPPS.SPI_CODIGO=0
				FROM         KARDESPED INNER JOIN
				                      FACTEXPDET ON KARDESPED.KAP_INDICED_FACT = FACTEXPDET.FED_INDICED INNER JOIN
				                      PEDIMPDET ON KARDESPED.KAP_INDICED_PED = PEDIMPDET.PID_INDICED AND 
				                      FACTEXPDET.SE_CODIGO <> PEDIMPDET.PID_SEC_IMP INNER JOIN
				                      KARDESPEDPPS ON KARDESPED.KAP_CODIGO = KARDESPEDPPS.KAP_CODIGO LEFT OUTER JOIN
				                      ARANCEL ON PEDIMPDET.AR_IMPMX = ARANCEL.AR_CODIGO LEFT OUTER JOIN
				                      SECTORARA ON FACTEXPDET.SE_CODIGO = SECTORARA.SE_CODIGO AND 
				                      PEDIMPDET.AR_IMPMX = SECTORARA.AR_CODIGO
				WHERE     (PEDIMPDET.PID_DEF_TIP = 'S') AND (SECTORARA.SE_CODIGO IS NULL)
				AND (FACTEXPDET.FE_CODIGO = @FE_CODIGO) and (KARDESPEDPPS.KAP_TASAFINAL>=ARANCEL.AR_ADVDEF OR KARDESPEDPPS.KAP_TASAFINAL=-1)


			
			
			end
	
	END	
	ELSE
	BEGIN

		-- =====================  factor de actualizacion para la rectificacion =============================== 
	
		declare cur_actualizacion cursor for
			SELECT     KARDESPEDPPS.KAP_FECHAPED, KARDESPED.KAP_INDICED_PED
			FROM         KARDESPEDPPS INNER JOIN
			                      KARDESPED ON KARDESPEDPPS.KAP_CODIGO = KARDESPED.KAP_CODIGO
			WHERE     (KARDESPEDPPS.KAP_DEF_TIP <> 'S') AND (KARDESPEDPPS.KAP_TASAFINAL <> - 1) 
				AND KARDESPEDPPS.KAP_FECHAPED IS NOT NULL AND KARDESPEDPPS.KAP_FECHAPED<>''
				AND (KARDESPED.KAP_FACTRANS = @FE_CODIGO)
		open cur_actualizacion
			FETCH NEXT FROM  cur_actualizacion INTO @pi_fec_sal, @KAP_INDICED_PED
			WHILE (@@FETCH_STATUS = 0) 
			BEGIN
	
	--	select @pi_fec_sal=fe_fecha from factexp where fe_codigo=@FE_CODIGO
					SELECT     @VINPCMAX=IN_CANT
					FROM         INPC
					WHERE IN_FECINI IN (SELECT MAX(INPC.IN_FECINI) FROM  INPC WHERE IN_FECINI <= @pi_fec_sal)
			
					SELECT    @PI_FEC_ENTPI=PI_FEC_PAG
					FROM         pedimp 
					where pi_codigo in (select pi_codigo from pedimpdet where pid_indiced=@KAP_INDICED_PED)
					
			
				
					-- periodo fecha de entrada de la mercancia hasta la fecha de cambio de regimen
					-- inpc maximo
					SELECT     @VINPCMAX=IN_CANT
					FROM         INPC
					WHERE IN_FECINI IN (SELECT MAX(INPC.IN_FECINI) FROM  INPC WHERE IN_FECINI <= @pi_fec_sal)
				
					/*para la materia prima el impuesto general de importacion se determina aplicando la tasa arancelaria preferencial 
					vigente a la fecha de entrada de las mercancias al territorio nacional en los terminos del articulo 56, fraccion I de la Ley, actualizado conforme
					 al art-culo 17-A del Codigo y una cantidad equivalente al importe de los recargos que corresponderian en los terminos del articulo 21 del Codigo, 
					a partir del mes en que las mercancias se importen temporalmente y hasta que las mismas se paguen */		
					UPDATE KARDESPEDPPS
					set KAP_FT_ACT =  round(isnull((@VINPCMAX /(SELECT max(IN_CANT)
										        FROM INPC WHERE IN_FECINI IN (SELECT MAX(IN_FECINI) FROM  INPC WHERE IN_FECINI <= @PI_FEC_ENTPI
									     	        and INPC.IN_FECINI NOT IN (SELECT MAX(INPC.IN_FECINI) FROM INPC WHERE IN_FECINI <= @PI_FEC_ENTPI)))),0),2)			
					FROM  KARDESPEDPPS INNER JOIN
				                      KARDESPED ON KARDESPEDPPS.KAP_CODIGO = KARDESPED.KAP_CODIGO
					WHERE KARDESPED.KAP_INDICED_PED=@KAP_INDICED_PED AND (KARDESPED.KAP_FACTRANS = @FE_CODIGO)
	
					UPDATE KARDESPEDPPS
					SET     KARDESPEDPPS.KAP_COSTOUNITACT= round(PEDIMPDET.PID_COS_UNIADU,6)
					FROM         KARDESPEDPPS INNER JOIN
					                      KARDESPED ON KARDESPEDPPS.KAP_CODIGO = KARDESPED.KAP_CODIGO INNER JOIN
					                      PEDIMPDET ON KARDESPED.KAP_INDICED_PED = PEDIMPDET.PID_INDICED
					WHERE KARDESPED.KAP_INDICED_PED=@KAP_INDICED_PED AND (KARDESPED.KAP_FACTRANS = @FE_CODIGO)
	
					UPDATE KARDESPEDPPS
					SET KAP_COSTOUNITACT=round(KAP_COSTOUNITACT*KAP_FT_ACT,6)
					FROM  KARDESPEDPPS INNER JOIN
				                      KARDESPED ON KARDESPEDPPS.KAP_CODIGO = KARDESPED.KAP_CODIGO
					WHERE KARDESPED.KAP_INDICED_PED=@KAP_INDICED_PED AND (KARDESPED.KAP_FACTRANS = @FE_CODIGO)
	
			
				FETCH NEXT FROM  cur_actualizacion INTO @pi_fec_sal, @KAP_INDICED_PED
			END
			CLOSE cur_actualizacion
			DEALLOCATE cur_actualizacion
		end
	END






GO
