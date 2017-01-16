SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[SP_IMPEXCELFACTEXPAGRU]   as

SET NOCOUNT ON 
declare @fea_codigo int, @fe_codigo int, @folioagru varchar(25), @folio varchar(25),
@pu_cargas int, @pu_salidas int, @pu_entradas int, @pu_destinos int, @it_salida int, @cl_matriz int,
@ag_mex int, @ag_usa int, @cl_trafico int, @mo_codigo int, @FechaActual varchar(10), @dirempresa int,
@dirmatriz int, @dirtrafico int, @consecutivo int, @tc_cant decimal(38,6)

--borra los errores generados en otras importaciones
DELETE FROM IMPORTLOG
DBCC CHECKIDENT (IMPORTLOG, RESEED, 0) WITH NO_INFOMSGS



if exists(SELECT     IMPEXCELRELFACTAGRU.FOLIOFACT
FROM         IMPEXCELRELFACTAGRU LEFT OUTER JOIN
                      FACTEXP ON IMPEXCELRELFACTAGRU.FOLIOFACT = FACTEXP.FE_FOLIO
WHERE     (FACTEXP.FE_FOLIO IS NULL) AND (IMPEXCELRELFACTAGRU.FOLIOFACT IS NOT NULL AND IMPEXCELRELFACTAGRU.FOLIOFACT <> ''))

	INSERT INTO IMPORTLOG (IML_MENSAJE) 
	SELECT     'NO SE PUEDE GENERAR LA RELACION DE LA FACTURA: '+IMPEXCELRELFACTAGRU.FOLIOFACT + ' PORQUE NO EXISTE EN LOS DUCMENTOS DE SALIDA'
	FROM         IMPEXCELRELFACTAGRU LEFT OUTER JOIN
	                      FACTEXP ON IMPEXCELRELFACTAGRU.FOLIOFACT = FACTEXP.FE_FOLIO
	WHERE     (FACTEXP.FE_FOLIO IS NULL) AND (IMPEXCELRELFACTAGRU.FOLIOFACT IS NOT NULL AND IMPEXCELRELFACTAGRU.FOLIOFACT <> '')




SELECT     @pu_cargas=PU_CARGAS, @pu_salidas=PU_SALIDAS, @pu_entradas=PU_ENTRADAS, @pu_destinos=PU_DESTINOS, 
@it_salida=IT_SALIDA, @cl_matriz=CL_MATRIZ, @ag_mex=AG_MEX, @ag_usa=AG_USA, @cl_trafico=CL_TRAFICO,
@mo_codigo=MO_CODIGO
FROM         CLIENTE
WHERE     (CL_CODIGO = 1)


SELECT @dirempresa=MAX(DI_INDICE) FROM DIR_CLIENTE WHERE DI_FISCAL = 'S' AND CL_CODIGO = 1
SELECT @dirmatriz=MAX(DI_INDICE) FROM DIR_CLIENTE WHERE DI_FISCAL = 'S' AND CL_CODIGO = @CL_MATRIZ
SELECT @dirtrafico=MAX(DI_INDICE) FROM DIR_CLIENTE WHERE DI_FISCAL = 'S' AND CL_CODIGO = @CL_Trafico

SET @FechaActual = convert(varchar(10), getdate(),101)


SELECT @tc_cant=TC_CANT FROM TCAMBIO WHERE (TC_FECHA = @FechaActual)

	if exists (SELECT     FOLIOFACTAGRU
			FROM         IMPEXCELRELFACTAGRU
			WHERE FOLIOFACT IN (SELECT FE_FOLIO FROM FACTEXP)
			GROUP BY FOLIOFACTAGRU
			HAVING      (FOLIOFACTAGRU IS NOT NULL AND FOLIOFACTAGRU <> ''))
	begin

		declare cur_factagru cursor for
			SELECT     FOLIOFACTAGRU, FOLIOFACT
			FROM         IMPEXCELRELFACTAGRU
			WHERE FOLIOFACT IN (SELECT FE_FOLIO FROM FACTEXP)
			GROUP BY FOLIOFACTAGRU, FOLIOFACT
			HAVING      (FOLIOFACTAGRU IS NOT NULL AND FOLIOFACTAGRU <> '')
		open cur_factagru
		FETCH NEXT FROM cur_factagru INTO @folioagru, @folio
	
		WHILE (@@FETCH_STATUS = 0) 
		BEGIN
		
			if exists (select * from factexpagru where fea_folio=@folioagru)
			begin
				select @fea_codigo=fea_codigo from factexpagru where fea_folio=@folioagru
				select @fe_codigo=fe_codigo from factexp where fe_folio=@folio
				
				update factexp
				set fe_factagru=@fea_codigo
				where fe_codigo=@fe_codigo
			end
			else
			begin

				SELECT     @consecutivo=isnull(CV_CODIGO,0)+1
				FROM         CONSECUTIVO
				WHERE     (CV_TIPO = 'FEA')


				INSERT FACTEXPAGRU(FEA_CODIGO, FEA_FOLIO, FEA_FECHA, TF_CODIGO, TQ_CODIGO, FEA_TIPO, FEA_PINICIAL, FEA_PFINAL, TN_CODIGO, FEA_TIPOCAMBIO, AG_MX, 
				                   AG_US, CL_PROD, DI_PROD, CL_COMP, DI_COMP, CL_COMPFIN, DI_COMPFIN, CL_EXP, DI_EXP, CL_EXPFIN, DI_EXPFIN, CL_DESTINI, DI_DESTINI, 
				                   CL_DESTFIN, DI_DESTFIN, CL_VEND, DI_VEND, CL_IMP, DI_IMP, MO_CODIGO, IT_COMPANY1,
						   PU_CARGA, PU_SALIDA, PU_ENTRADA, PU_DESTINO)
				
				values ( @consecutivo, @folioagru, @FechaActual, 2, 3, 'F', @FechaActual, @FechaActual, 4, @tc_cant, @AG_MEX, @AG_USA,
				1, @dirempresa, @CL_MATRIZ, @dirmatriz, @CL_MATRIZ, @dirmatriz, @cl_trafico, @dirtrafico, @cl_trafico, @dirtrafico,
				@CL_MATRIZ, @dirmatriz, @CL_MATRIZ, @dirmatriz, 1, @dirempresa, @CL_MATRIZ, @dirmatriz, @mo_codigo, @IT_SALIDA, 
				@PU_CARGAS, @PU_SALIDAS, @PU_ENTRADAS, @PU_DESTINOS)

				select @fe_codigo=fe_codigo from factexp where fe_folio=@folio

				update factexp
				set fe_factagru=@consecutivo
				where fe_codigo=@fe_codigo


				-- se actualiza consecutivo
				select @fea_codigo= max(fea_codigo) from factexpagru
				
				update consecutivo
				set cv_codigo =  isnull(@fea_codigo,0) + 1
				where cv_tipo = 'FEA'

			end

		FETCH NEXT FROM cur_factagru INTO @folioagru, @folio
		END
		
		CLOSE cur_factagru
		DEALLOCATE cur_factagru


	end






























GO
