SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO




















































CREATE PROCEDURE [dbo].[SP_BOMAGREGAPERIODO] (@pt int, @BST_hijo INT, @PerCambios CHAR(1), @Incorpor decimal(38,6))   as


DECLARE @FECHAACTUAL DATETIME, @AYER DATETIME, @Factconv decimal(28,14), @UniMed Int, @UMGen Int, @Tipo Int, @TipoLetra char(1), @Dis Char(1), @FechaInsert DateTime,
@bm_entravigor datetime, @manoparte varchar(30), @manopartepadre varchar(30), @bst_tip_ens CHAR(1), @pa_codigo int, @ma_peso_kg decimal(38,6)

SET @FECHAACTUAL = convert(datetime, convert(varchar(11), getdate(),101));

SET @AYER =  convert(datetime, floor(convert(decimal(38,6), getdate()-1)))

select @bm_entravigor = bst_perini from bom_struct where bsu_subensamble = @pt and bst_perini <= @fechaactual and bst_perfin >= @fechaactual

SELECT     @Tipo = dbo.MAESTRO.TI_CODIGO, @Dis = dbo.MAESTRO.MA_DISCHARGE, 
	   @UniMed = dbo.MAESTRO.ME_COM, @UMGen = MAESTRO_1.ME_COM, 
	   @Factconv = dbo.MAESTRO.EQ_GEN, @Manoparte = dbo.MAESTRO.MA_NOPARTE,
	@bst_tip_ens= dbo.MAESTRO.MA_TIP_ENS
FROM         dbo.MAESTRO LEFT OUTER JOIN
                      dbo.MAESTRO MAESTRO_1 ON dbo.MAESTRO.MA_GENERICO = MAESTRO_1.MA_CODIGO
WHERE     (dbo.MAESTRO.MA_CODIGO = @bst_hijo)


SELECT @manopartepadre = MA_NOPARTE FROM MAESTRO WHERE MA_CODIGO = @pt

IF @PerCambios ='S'
	BEGIN


		if not exists (select * from bom_struct where bsu_subensamble=@pt and bst_hijo = @bst_hijo)
		BEGIN
		    INSERT INTO BOM_Struct (BSU_Subensamble,  
	                               		BST_Hijo, 
					BSU_NOPARTE,
					BST_NOPARTE,
					BST_PerINI, 
			          		BST_PerFIN, 
				             	BST_DISCH, 
             			             		ME_CODIGO,
					ME_GEN,
					BST_INCORPOR,
		             		        	factconv,
					bst_tip_ens,
					BST_TRANS)

			    VALUES  (@pt, 
		             		@bst_hijo, 
				@manopartepadre,
				@manoparte,
				@bm_entravigor, 
			             	'01/01/9999', 
				@Dis, 
				@UniMed,
				isnull(@UMGen,19),
				@Incorpor, 
				@factconv,
				@bst_tip_ens,
				'N')
		END


	END
	ELSE
	BEGIN
		if not exists (select * from bom_struct where bsu_subensamble=@pt and bst_hijo = @bst_hijo)
		BEGIN
	
		    INSERT INTO BOM_Struct (BSU_Subensamble,  
	                               		BST_Hijo, 
					BSU_NOPARTE,
					BST_NOPARTE,
					BST_PerINI, 
			          		BST_PerFIN, 
				             	BST_DISCH, 
             			             		ME_CODIGO,
					ME_GEN,
					BST_INCORPOR,
		             		        	factconv ,
					bst_tip_ens,
					BST_TRANS)

			    VALUES  (@pt, 
		             		@bst_hijo, 
				@manopartepadre,
				@manoparte,
				@fechaactual, 
			             	'01/01/9999', 
				@Dis, 
				@UniMed,
				isnull(@UMGen,19),
				@Incorpor, 
				@factconv,
				@bst_tip_ens,
				'N')


		END
	END



















































GO
