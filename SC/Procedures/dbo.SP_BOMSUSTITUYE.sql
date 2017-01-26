SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

















































CREATE PROCEDURE [dbo].[SP_BOMSUSTITUYE] (@pt int,@bst_hijo int, @BST_NUEVO INT, @PerCambios CHAR(1), @Incorpor decimal(38,6), @Desp decimal(38,6), @Merma decimal(38,6))   as

SET NOCOUNT ON 
DECLARE @FECHAACTUAL DATETIME, @AYER DATETIME, @Factconv decimal(28,14), @UniMed Int, @UMGen Int, @Tipo Int,
@TipoLetra char(1), @Dis Char(1), @FechaInsert DateTime, @BM_ENTRAVIGOR DATETIME, @manoparte varchar(30), @manopartepadre varchar(30),
@bst_tip_ens char(1), @pa_codigo int, @countbom int, @BM_PERFIN datetime, @ma_peso_kg decimal(38,6)

SET @FECHAACTUAL = convert(datetime, convert(varchar(11), getdate(),101));

select @countbom=count(*) from bom_struct where 
bsu_subensamble=@pt

SELECT     @Tipo = dbo.MAESTRO.TI_CODIGO, 
	@Dis = dbo.MAESTRO.MA_DISCHARGE, 
	   @UniMed = dbo.MAESTRO.ME_COM, @UMGen = MAESTRO_1.ME_COM, 
	   @Factconv = dbo.MAESTRO.EQ_GEN, @manoparte = dbo.MAESTRO.MA_NOPARTE,
	@bst_tip_ens= dbo.MAESTRO.MA_TIP_ENS
	--, @pa_codigo=dbo.MAESTRO.pa_origen,
	--@ma_peso_kg=dbo.MAESTRO.ma_peso_kg
FROM         dbo.MAESTRO LEFT OUTER JOIN
                      dbo.MAESTRO MAESTRO_1 ON dbo.MAESTRO.MA_GENERICO = MAESTRO_1.MA_CODIGO
WHERE     (dbo.MAESTRO.MA_CODIGO = @BST_NUEVO)

select @manopartepadre = ma_noparte from maestro where ma_codigo=@pt


SELECT @BM_ENTRAVIGOR = BST_PERINI, @BM_PERFIN = BST_PERFIN FROM BOM_STRUCT WHERE BSU_SUBENSAMBLE=@PT AND BST_PERINI <=@FECHAACTUAL AND BST_PERFIN >=@FECHAACTUAL
SET @AYER =  convert(datetime, floor(convert(decimal(38,6), getdate()-1)))

IF @PerCambios ='S'
	BEGIN
		/* si no esta en periodo de cambios no guarda historial eso significa que borra los que bst_hijo = @bst_hijo e inserta el nuevo */
		    UPDATE BOM_STRUCT 
		     SET BST_Hijo = @BST_NUEVO,
			BST_NOPARTE = @manoparte,
			BST_DISCH = @Dis, 
			ME_CODIGO =	isnull(@UniMed,19),
			ME_GEN = isnull(@UMGen,19),
			bst_tip_ens=@bst_tip_ens
		WHERE BSU_SUBENSAMBLE=@PT AND BST_HIJO = @BST_HIJO AND BST_PERINI <=@FECHAACTUAL AND
	 	    BST_PERFIN >=@FECHAACTUAL

	END
	ELSE
	BEGIN

		/* si guarda historial significa qu al que ya existia le hace update a la fecha final e inserta el nuevo con la fecha inicial = al dia en que se inserto*/

		if not exists(select * from bom_struct where bsu_subensamble=@pt
		  and bst_hijo=@bst_nuevo and bst_perini<= @BM_ENTRAVIGOR	and bst_perfin>=@BM_ENTRAVIGOR)

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
		             		@bst_nuevo, 
				@manopartepadre,
				@manoparte,
				@fechaactual, 
			             	'01/01/9999', 
				@Dis, 
				isnull(@UniMed,19),
				isnull(@UMGen,19),
				@Incorpor, 
				@factconv,
				@bst_tip_ens,
				'N')


		UPDATE dbo.BOM_STRUCT 
		SET BST_PERFIN = @AYER
		WHERE     (BST_PERINI <= @FECHAACTUAL) AND (BST_PERFIN >= @FECHAACTUAL)
		and BST_PERINI<>@fechaactual
		AND (BST_HIJO = @bst_hijo) and (BSU_SUBENSAMBLE=@PT )

	END
















































GO
