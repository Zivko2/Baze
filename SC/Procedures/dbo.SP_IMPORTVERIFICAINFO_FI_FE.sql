SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
























CREATE PROCEDURE [dbo].[SP_IMPORTVERIFICAINFO_FI_FE] (@tabla varchar(150), @ims_cbforma int, @Insert char(1))   as


declare @user varchar(10)
select @user = substring(@tabla,charindex('_',@tabla)+1,len(@tabla))

	if @ims_cbforma=21 and @Insert='S'
	begin


		UPDATE FACTIMPDET
		SET FID_COS_UNI=ROUND(.50/FID_CANT_ST,6), FID_COS_TOT=.50
		FROM    FACTIMPDET INNER JOIN
		                      FACTIMP ON FACTIMPDET.FI_CODIGO = FACTIMP.FI_CODIGO
		WHERE (FID_COS_TOT < .50) AND (FID_CANT_ST>0) AND (FID_CANT_ST IS NOT NULL)
		AND FACTIMP.FI_FOLIO IN (SELECT REPLACE(LEFT(RI_REGISTRO,CHARINDEX(',',RI_REGISTRO)-1),'FI_FOLIO = ','') 
					FROM REGISTROSIMPORTADOS
					WHERE RI_REGISTRO LIKE 'FI_FOLIO%' AND RI_TIPO='I')
		and FACTIMP.fi_estatus not in ('A', 'C', 'L') and FACTIMP.fi_iniciocruce<>'S'
		and FACTIMP.TQ_CODIGO NOT IN (SELECT TQ_CODIGO FROM TEMBARQUE WHERE TQ_NOMBRE='TODO TIPO MATERIAL Y EQUIPO (CASO ESPECIAL)')


		INSERT INTO REGISTROSIMPORTADOS (RI_REGISTRO, RI_CBFORMA,  RI_TIPO, RI_USERID) 
		SELECT 'EN LA FACTURA: '+FACTIMP.FI_FOLIO+'EL NO. PARTE: ' + FACTIMPDET.FID_NOPARTE+' NO CUENTA CON COSTO UNITARIO', 21, 'I', @user
		FROM         FACTIMPDET INNER JOIN
		                      FACTIMP ON FACTIMPDET.FI_CODIGO = FACTIMP.FI_CODIGO
		WHERE     FACTIMP.FI_FOLIO IN (SELECT REPLACE(LEFT(RI_REGISTRO,CHARINDEX(',',RI_REGISTRO)-1),'FI_FOLIO = ','') 
					FROM REGISTROSIMPORTADOS
					WHERE RI_REGISTRO LIKE 'FI_FOLIO%' AND RI_TIPO='I')
			AND (FACTIMPDET.FID_COS_UNI=0 OR FACTIMPDET.FID_COS_UNI IS NULL)
   			and FACTIMP.fi_estatus not in ('A', 'C', 'L') and FACTIMP.fi_iniciocruce<>'S'
		GROUP BY FACTIMPDET.FID_NOPARTE, FACTIMP.FI_FOLIO


		INSERT INTO REGISTROSIMPORTADOS (RI_REGISTRO, RI_CBFORMA,  RI_TIPO, RI_USERID) 
		SELECT 'EN LA FACTURA: '+FACTIMP.FI_FOLIO+'EL NO. PARTE: ' + FACTIMPDET.FID_NOPARTE+' NO CUENTA CON CANTIDAD', 21, 'I', @user
		FROM         FACTIMPDET INNER JOIN
		                      FACTIMP ON FACTIMPDET.FI_CODIGO = FACTIMP.FI_CODIGO
		WHERE     FACTIMP.FI_FOLIO IN (SELECT REPLACE(LEFT(RI_REGISTRO,CHARINDEX(',',RI_REGISTRO)-1),'FI_FOLIO = ','') 
					FROM REGISTROSIMPORTADOS
					WHERE RI_REGISTRO LIKE 'FI_FOLIO%' AND RI_TIPO='I')
			AND (FACTIMPDET.FID_CANT_ST=0 OR FACTIMPDET.FID_CANT_ST IS NULL)
			and FACTIMP.fi_estatus not in ('A', 'C', 'L') and FACTIMP.fi_iniciocruce<>'S'
		GROUP BY FACTIMPDET.FID_NOPARTE, FACTIMP.FI_FOLIO

	end


	if @ims_cbforma=20 and @Insert='S'
	begin



		UPDATE FACTEXPDET
		SET FED_COS_UNI=ROUND(.50/FED_CANT,6), FED_COS_TOT=.50
		FROM    FACTEXPDET INNER JOIN
		                      FACTEXP ON FACTEXPDET.FE_CODIGO = FACTEXP.FE_CODIGO
		WHERE (FED_COS_TOT < .50) AND (FED_CANT>0) AND (FED_CANT IS NOT NULL)
		AND TI_CODIGO IN (SELECT TI_CODIGO FROM CONFIGURATIPO WHERE CFT_TIPO NOT IN ('P','S'))
		AND FACTEXP.FE_FOLIO IN (SELECT REPLACE(LEFT(RI_REGISTRO,CHARINDEX(',',RI_REGISTRO)-1),'FE_FOLIO = ','') 
					FROM REGISTROSIMPORTADOS
					WHERE RI_REGISTRO LIKE 'FE_FOLIO%' AND RI_TIPO='I')
		and factexp.fe_estatus not in ('A', 'C', 'D', 'L', 'S') and factexp.fe_iniciocruce<>'S'
		and FACTEXP.TQ_CODIGO NOT IN (SELECT TQ_CODIGO FROM TEMBARQUE WHERE TQ_NOMBRE='PRODUCTO TERMINADO (CASO ESPECIAL)')


		INSERT INTO REGISTROSIMPORTADOS (RI_REGISTRO, RI_CBFORMA,  RI_TIPO, RI_USERID) 
		SELECT 'EN LA FACTURA: '+FACTEXP.FE_FOLIO+' EL NO. PARTE: ' + FACTEXPDET.FED_NOPARTE+' NO CUENTA CON COSTO UNITARIO', 20, 'I', @user
		FROM         FACTEXPDET INNER JOIN
		                      FACTEXP ON FACTEXPDET.FE_CODIGO = FACTEXP.FE_CODIGO
		WHERE     FACTEXP.FE_FOLIO IN (SELECT REPLACE(LEFT(RI_REGISTRO,CHARINDEX(',',RI_REGISTRO)-1),'FE_FOLIO = ','') 
					FROM REGISTROSIMPORTADOS
					WHERE RI_REGISTRO LIKE 'FE_FOLIO%' AND RI_TIPO='I')
			AND (FACTEXPDET.FED_COS_UNI=0 OR FACTEXPDET.FED_COS_UNI IS NULL)
			and FACTEXP.fe_estatus not in ('A', 'C', 'D', 'L', 'S') and FACTEXP.fe_iniciocruce<>'S'
		GROUP BY FACTEXPDET.FED_NOPARTE, FACTEXP.FE_FOLIO


		INSERT INTO REGISTROSIMPORTADOS (RI_REGISTRO, RI_CBFORMA,  RI_TIPO, RI_USERID) 
		SELECT 'EN LA FACTURA: '+FACTEXP.FE_FOLIO+' EL NO. PARTE: ' + FACTEXPDET.FED_NOPARTE+' NO CUENTA CON CANTIDAD', 20, 'I', @user
		FROM         FACTEXPDET INNER JOIN
		                      FACTEXP ON FACTEXPDET.FE_CODIGO = FACTEXP.FE_CODIGO
		WHERE     FACTEXP.FE_FOLIO IN (SELECT REPLACE(LEFT(RI_REGISTRO,CHARINDEX(',',RI_REGISTRO)-1),'FE_FOLIO = ','') 
					FROM REGISTROSIMPORTADOS
					WHERE RI_REGISTRO LIKE 'FE_FOLIO%' AND RI_TIPO='I')
			AND (FACTEXPDET.FED_CANT=0 OR FACTEXPDET.FED_CANT IS NULL)
			and FACTEXP.fe_estatus not in ('A', 'C', 'D', 'L', 'S') and FACTEXP.fe_iniciocruce<>'S'
		GROUP BY FACTEXPDET.FED_NOPARTE, FACTEXP.FE_FOLIO
	end


GO