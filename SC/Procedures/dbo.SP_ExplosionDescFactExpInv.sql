SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO







































CREATE PROCEDURE [dbo].[SP_ExplosionDescFactExpInv] (@CodigoFactura Int)   as

SET NOCOUNT ON 

DECLARE @COUNTMP INT, @COUNTPT INT, @COUNTFIS_COMP INT,@bst_hijo int, @fed_cant decimal(38,6), @bst_disch char(1), @ti_codigo char(1),
	@me_codigo int, @Factconv decimal(28,14), @me_gen int, @DescargaEmpaque char(1), @DescargaEmpaqueDet char(1), @fed_indiced int, 
	@HayRetrabajo int, @HayNormal Int, @CF_CONTENEDOR CHAR(1), @fecha datetime, @empaqueadicional int,
	@countdescargable int, @cs_codigo smallint, @fe_fecha datetime, @TEmbarque char(1), @tipodesc varchar(5),@fed_tip_ens char(1),
	@FechaActual varchar(10), @cfq_tipo char(1)

  SET @FechaActual = convert(varchar(10), getdate(),101)

-- Luis
SELECT     @COUNTFIS_COMP = COUNT(dbo.FACTEXPDET.FED_TIP_ENS)
FROM         dbo.FACTEXPDET 
GROUP BY dbo.FACTEXPDET.FE_CODIGO, dbo.FACTEXPDET.FED_TIP_ENS
HAVING      (dbo.FACTEXPDET.FED_TIP_ENS = 'A') AND (dbo.FACTEXPDET.FE_CODIGO = @CodigoFactura)
--

SELECT     @COUNTMP = COUNT(dbo.FACTEXPDET.FED_TIP_ENS)
FROM         dbo.FACTEXPDET 
WHERE (dbo.FACTEXPDET.FED_TIP_ENS = 'C')  
GROUP BY dbo.FACTEXPDET.FE_CODIGO
HAVING     (dbo.FACTEXPDET.FE_CODIGO = @CodigoFactura)


SELECT     @COUNTPT = COUNT(dbo.FACTEXPDET.FED_TIP_ENS)
FROM         dbo.FACTEXPDET 
WHERE (dbo.FACTEXPDET.FED_TIP_ENS = 'F' OR dbo.FACTEXPDET.FED_TIP_ENS = 'E') 
GROUP BY dbo.FACTEXPDET.FE_CODIGO
HAVING      (dbo.FACTEXPDET.FE_CODIGO = @CodigoFactura)


SELECT     @HayRetrabajo = COUNT(FED_RETRABAJO) 
FROM         dbo.FACTEXPDET
WHERE (FED_RETRABAJO = 'R' OR FED_RETRABAJO = 'D' OR FED_RETRABAJO = 'C' OR FED_RETRABAJO = 'A' OR FED_RETRABAJO = 'E')
GROUP BY FE_CODIGO
HAVING      (FE_CODIGO = @CodigoFactura) 

SELECT     @HayNormal = COUNT(FED_RETRABAJO) 
FROM         dbo.FACTEXPDET
WHERE (FED_RETRABAJO = 'N' OR FED_RETRABAJO = 'C')
GROUP BY FE_CODIGO
HAVING      (FE_CODIGO = @CodigoFactura)  

SELECT     @CF_CONTENEDOR = CF_CONTENEDOR, @DescargaEmpaqueDet = CF_MAN_EMPAQUE,
@DescargaEmpaque = CF_EMPAQUE_BOM
FROM         dbo.CONFIGURACION

SELECT     @TEmbarque = dbo.CONFIGURATEMBARQUE.CFQ_TIPO
FROM         dbo.FACTEXP LEFT OUTER JOIN
              dbo.CONFIGURATEMBARQUE ON dbo.FACTEXP.TQ_CODIGO = dbo.CONFIGURATEMBARQUE.TQ_CODIGO
GROUP BY dbo.CONFIGURATEMBARQUE.CFQ_TIPO, dbo.FACTEXP.FE_CODIGO, dbo.FACTEXP.FE_TIPO
HAVING      (dbo.FACTEXP.FE_CODIGO = @CodigoFactura)


SELECT     @empaqueadicional = COUNT(MA_CODIGO)  FROM dbo.FACTEXPEMPAQUEADICIONAL
GROUP BY FE_CODIGO  HAVING  (FE_CODIGO = @CodigoFactura)


select @fe_fecha=fe_fecha from factexp where fe_codigo=@CodigoFactura

	/* cuando hay pt o sub en detalle con tipo de adquisicion <> Fisico-Comprado (A) insertamos en bom_desctemp por medio del  la tabla bom_structdesc*/

	


/* la cantidad de pt que se capturo en la lista de reatrabjo se le resta a la cantidad original de pt, esto es para que no se tenga que dividir una cantidad
si va revuelto pt con retrabajo*/
	IF @COUNTPT > 0 AND @HayRetrabajo >0
	INSERT INTO BOM_DESCTEMP(FE_CODIGO, FED_INDICED, FED_CANT, BST_PT, BST_ENTRAVIGOR, BST_HIJO, BST_INCORPOR, 
	BST_DISCH, TI_CODIGO, ME_CODIGO, FACTCONV, BST_PERINI, BST_PERFIN, ME_GEN, BST_TRANS, BST_TIPOCOSTO, 
	MA_TIP_ENS, BST_NIVEL, BST_TIPODESC, BST_PERTENECE)


	SELECT     TOP 100 PERCENT dbo.FACTEXPDET.FE_CODIGO, dbo.FACTEXPDET.FED_INDICED, 
	                      dbo.FACTEXPDET.FED_CANT - dbo.RETRABAJO.RE_INCORPOR AS FED_CANT, dbo.TempBOM_ESTRUCTDESC.BST_PT, 
	                      dbo.TempBOM_ESTRUCTDESC.BST_ENTRAVIGOR, dbo.TempBOM_ESTRUCTDESC.BST_HIJO, dbo.TempBOM_ESTRUCTDESC.BST_INCORPOR, 
	                      dbo.TempBOM_ESTRUCTDESC.BST_DISCH, dbo.TempBOM_ESTRUCTDESC.TI_CODIGO, dbo.TempBOM_ESTRUCTDESC.ME_CODIGO, 
	                      dbo.TempBOM_ESTRUCTDESC.FACTCONV, dbo.TempBOM_ESTRUCTDESC.BST_PERINI, dbo.TempBOM_ESTRUCTDESC.BST_PERFIN, 
	                      dbo.TempBOM_ESTRUCTDESC.ME_GEN, dbo.TempBOM_ESTRUCTDESC.BST_TRANS, dbo.TempBOM_ESTRUCTDESC.BST_TIPOCOSTO, 
	                      dbo.TempBOM_ESTRUCTDESC.MA_TIP_ENS, 
	                      dbo.TempBOM_ESTRUCTDESC.BST_NIVEL, dbo.TempBOM_ESTRUCTDESC.BST_TIPODESC, dbo.TempBOM_ESTRUCTDESC.BST_PERTENECE
	FROM         dbo.FACTEXPDET INNER JOIN
	                      dbo.TempBOM_ESTRUCTDESC ON dbo.FACTEXPDET.MA_CODIGO = dbo.TempBOM_ESTRUCTDESC.BST_PT AND 
	                      dbo.FACTEXPDET.FED_FECHA_STRUCT = dbo.TempBOM_ESTRUCTDESC.BST_ENTRAVIGOR INNER JOIN
	                      dbo.RETRABAJO ON dbo.FACTEXPDET.FED_INDICED = dbo.RETRABAJO.FETR_INDICED AND 
	                      dbo.FACTEXPDET.MA_CODIGO = dbo.RETRABAJO.MA_HIJO RIGHT OUTER JOIN
	                      dbo.FACTEXP ON dbo.FACTEXPDET.FE_CODIGO = dbo.FACTEXP.FE_CODIGO LEFT OUTER JOIN
	                      dbo.CONFIGURATIPO ON dbo.FACTEXPDET.TI_CODIGO = dbo.CONFIGURATIPO.TI_CODIGO
	WHERE     (dbo.FACTEXPDET.FED_RETRABAJO = 'A') AND (dbo.FACTEXP.FE_CODIGO = @CodigoFactura) AND (dbo.CONFIGURATIPO.CFT_TIPO = 'P' OR
	                      dbo.CONFIGURATIPO.CFT_TIPO = 'S') AND (dbo.RETRABAJO.TIPO_FACTRANS = 'F') AND dbo.FACTEXPDET.FED_TIP_ENS <>'A'
	GROUP BY dbo.FACTEXPDET.FE_CODIGO, dbo.FACTEXPDET.FED_INDICED, dbo.FACTEXPDET.FED_CANT - dbo.RETRABAJO.RE_INCORPOR, 
	                      dbo.TempBOM_ESTRUCTDESC.BST_PT, dbo.TempBOM_ESTRUCTDESC.BST_ENTRAVIGOR, dbo.TempBOM_ESTRUCTDESC.BST_HIJO, 
	                      dbo.TempBOM_ESTRUCTDESC.BST_INCORPOR, dbo.TempBOM_ESTRUCTDESC.BST_DISCH, dbo.TempBOM_ESTRUCTDESC.TI_CODIGO, 
	                      dbo.TempBOM_ESTRUCTDESC.ME_CODIGO, dbo.TempBOM_ESTRUCTDESC.FACTCONV, dbo.TempBOM_ESTRUCTDESC.BST_PERINI, 
	                      dbo.TempBOM_ESTRUCTDESC.BST_PERFIN, dbo.TempBOM_ESTRUCTDESC.ME_GEN, dbo.TempBOM_ESTRUCTDESC.BST_TRANS, 
	                      dbo.TempBOM_ESTRUCTDESC.BST_TIPOCOSTO, 
	                      dbo.TempBOM_ESTRUCTDESC.MA_TIP_ENS, dbo.TempBOM_ESTRUCTDESC.BST_NIVEL, dbo.TempBOM_ESTRUCTDESC.BST_TIPODESC, 
	                      dbo.TempBOM_ESTRUCTDESC.BST_PERTENECE



	IF @HayRetrabajo >0

		EXEC sp_DescExplosion_Retrabajo @CodigoFactura /* inserta en bom_desctemp la lista de retrabajo */

		exec  sp_DescRetrabajoDesp @CodigoFactura  /* inserta a almacen de desperdicio el desperdicio del retrabajo -- no descargable */




	IF @COUNTMP > 0 OR @COUNTFIS_COMP > 0 
		
	BEGIN

	/* cuando hay mp en detalle insertamos en bom_desctemp la materia prima que viene directamente */

		declare CUR_DETALLEFACTMP cursor for
			SELECT     dbo.FACTEXPDET.MA_CODIGO, SUM(dbo.FACTEXPDET.FED_CANT) AS FED_CANT, dbo.FACTEXPDET.FED_DISCHARGE, 
			                      dbo.CONFIGURATIPO.CFT_TIPO, dbo.FACTEXPDET.ME_CODIGO, dbo.FACTEXPDET.EQ_GEN, ISNULL(dbo.MAESTRO.ME_COM, 19), 
			                      dbo.FACTEXPDET.FED_INDICED, dbo.FACTEXPDET.FED_FECHA_STRUCT, MAESTRO_1.CS_CODIGO,FACTEXPDET.FED_TIP_ENS
			FROM         dbo.FACTEXPDET LEFT OUTER JOIN
			                      dbo.MAESTRO MAESTRO_1 ON dbo.FACTEXPDET.MA_CODIGO = MAESTRO_1.MA_CODIGO LEFT OUTER JOIN
			                      dbo.MAESTRO ON dbo.FACTEXPDET.MA_GENERICO = dbo.MAESTRO.MA_CODIGO LEFT OUTER JOIN
			                      dbo.CONFIGURATIPO ON dbo.FACTEXPDET.TI_CODIGO = dbo.CONFIGURATIPO.TI_CODIGO
			WHERE     (dbo.FACTEXPDET.FED_TIP_ENS ='C' OR dbo.FACTEXPDET.FED_TIP_ENS ='A') AND (dbo.FACTEXPDET.FE_CODIGO = @CodigoFactura) 
				AND (dbo.FACTEXPDET.FED_DISCHARGE = 'S') AND (dbo.FACTEXPDET.PID_INDICED = - 1) --AND dbo.FACTEXPDET.TI_CODIGO NOT IN (SELECT TI_CODIGO FROM CONFIGURATIPO WHERE CFT_TIPO='P')
				AND (dbo.FACTEXPDET.FED_RETRABAJO='N')
			GROUP BY dbo.CONFIGURATIPO.CFT_TIPO, dbo.FACTEXPDET.MA_CODIGO, dbo.FACTEXPDET.ME_CODIGO, dbo.FACTEXPDET.EQ_GEN, 
			                      dbo.FACTEXPDET.FED_DISCHARGE, dbo.MAESTRO.ME_COM, dbo.FACTEXPDET.FED_INDICED, dbo.FACTEXPDET.FED_FECHA_STRUCT, 
			                      dbo.FACTEXPDET.PID_INDICED, dbo.FACTEXPDET.FED_RETRABAJO, MAESTRO_1.CS_CODIGO,FACTEXPDET.FED_TIP_ENS
			HAVING      (SUM(dbo.FACTEXPDET.FED_CANT) > 0) AND (dbo.FACTEXPDET.FED_RETRABAJO = 'N')

		 OPEN CUR_DETALLEFACTMP

		  FETCH NEXT FROM CUR_DETALLEFACTMP INTO @bst_hijo, @fed_cant, @bst_disch, @ti_codigo,
		@me_codigo, @factconv, @me_gen, @fed_indiced, @fecha, @cs_codigo,@fed_tip_ens

		  WHILE (@@fetch_status = 0) 
		  BEGIN  

			if @TEmbarque='D'
			set @tipodesc='D'
			else 
			set @tipodesc='N'

			if @cs_codigo<>2  --diferente de PadreKit
			begin

				insert into bom_desctemp (fe_codigo, bst_pt, bst_hijo, fed_cant, bst_disch, ti_codigo,
				me_codigo, factconv, me_gen, bst_incorpor, fed_indiced, bst_nivel, ma_tip_ens, bst_entravigor, bst_perini, bst_perfin,
				bst_tipodesc, bst_pertenece, bst_tipocosto)


				values
				(@CodigoFactura, @bst_hijo, @bst_hijo, @fed_cant, @bst_disch, @ti_codigo,
				@me_codigo, @factconv, @me_gen, 1, @fed_indiced, 'MP',@fed_tip_ens, @fecha,  @fecha,  @fecha, @tipodesc,
				@bst_hijo, 'S')
			end

			else
			begin
				if exists (select * from vpidescarga where ma_codigo=@bst_hijo and pi_fec_ent<=@fe_fecha and pid_saldogen>0)
				/* si no se encuentra en la tabla pedimpdet con saldo se insertan los componentes para descargar*/
				begin
					insert into bom_desctemp (fe_codigo, bst_pt, bst_hijo, fed_cant, bst_disch, ti_codigo,
					me_codigo, factconv, me_gen, bst_incorpor, fed_indiced, bst_nivel, bst_entravigor, bst_perini, bst_perfin,
					bst_tipodesc, ma_tip_ens, bst_tipocosto)
	
					values
					(@CodigoFactura, @bst_hijo, @bst_hijo, @fed_cant, @bst_disch, @ti_codigo,
					@me_codigo, @factconv, @me_gen, 1, @fed_indiced, 'MP', @fecha,  @fecha,  @fecha, @tipodesc, @fed_tip_ens,
					'S')
				end
				else
				begin
					insert into bom_desctemp (fe_codigo, bst_pt, bst_hijo, fed_cant, bst_disch, ti_codigo,
					me_codigo, factconv, me_gen, bst_incorpor, fed_indiced, bst_nivel, bst_entravigor, bst_perini, bst_perfin,
					bst_tipodesc, ma_tip_ens, bst_tipocosto)
	
					select @CodigoFactura, @bst_hijo, bom_struct.bst_hijo, @fed_cant, bom_struct.bst_disch, maestro.ti_codigo,
					bom_struct.me_codigo, bom_struct.factconv, @me_gen, bom_struct.bst_incorpor, @fed_indiced, 'MPK', @fecha, bom_struct.bst_perini, bom_struct.bst_perfin, @tipodesc,
					@fed_tip_ens, 'S'
					from bom_struct left outer join maestro on bom_struct.bst_hijo = maestro.ma_codigo
					where bsu_subensamble =@bst_hijo and bst_perini<=@fecha and bst_perfin>=@fecha and bst_disch='S'
				end				
			end


		  FETCH NEXT FROM CUR_DETALLEFACTMP INTO @bst_hijo, @fed_cant, @bst_disch, @ti_codigo,
		@me_codigo, @factconv, @me_gen, @fed_indiced, @fecha, @cs_codigo,@fed_tip_ens

		END

		CLOSE CUR_DETALLEFACTMP
		DEALLOCATE CUR_DETALLEFACTMP
	
	END


	/* se agrega empaque por pestaa */

	IF @DescargaEmpaque ='N' and @DescargaEmpaqueDet ='P'

	BEGIN
		 EXEC sp_DescEmpPestana  @CodigoFactura

	END

	/* se agrega empaque por detalle */	

	 IF @DescargaEmpaque ='N' and @DescargaEmpaqueDet ='I'

	BEGIN
		 EXEC sp_DescEmpDetalle  @CodigoFactura

	END

	/* se agrega empaque adicional */	
	if @empaqueadicional <> 0 
	BEGIN
               	EXEC sp_DescEmpAdicional  @CodigoFactura
	END







GO
