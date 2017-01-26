SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

































CREATE PROCEDURE [dbo].[SP_INSERTAGENERICOAR]  (@PE_CODIGO int)   as

SET NOCOUNT ON 

declare @PED_ID_SUBORD INT, @AR_IMPMX INT, @PED_INDICED INT, @CONSECUTIVO INT

declare cur_insertaGenerico cursor for
	SELECT     PED_ID_SUBORD, AR_IMPMX
	FROM         PERMISODET
	WHERE     (PED_REGISTROTIPO = 1) AND (PED_ID_SUBORD <> 0) AND (PE_CODIGO = @PE_CODIGO)
	GROUP BY  PED_ID_SUBORD, AR_IMPMX
	ORDER BY PED_ID_SUBORD
open cur_insertaGenerico


	FETCH NEXT FROM cur_insertaGenerico INTO @PED_ID_SUBORD, @AR_IMPMX

	WHILE (@@FETCH_STATUS = 0) 
	BEGIN

		EXEC SP_GETCONSECUTIVO 'PED', @VALUE = @PED_INDICED OUTPUT

		SELECT @CONSECUTIVO=ISNULL(MAX(PED_CONSECUTIVO),0) FROM PERMISODET WHERE PE_CODIGO=@PE_CODIGO
		AND PED_REGISTROTIPO=1 AND PED_ID_SUBORD=@PED_ID_SUBORD

		SET @CONSECUTIVO=@CONSECUTIVO+1

		INSERT INTO PERMISODET(PED_INDICED, PE_CODIGO, PED_REGISTROTIPO, MA_GENERICO, MA_NOPARTE,
			PED_NOMBRE, TI_CODIGO, ME_COM, AR_IMPMX, PED_ID_SUBORD, PED_CONSECUTIVO, PED_COSTO)

		select @PED_INDICED, @PE_CODIGO, 1, ma_codigo, ma_noparte, ma_nombre, ti_codigo, me_com, ar_impmx,
			@PED_ID_SUBORD, @CONSECUTIVO, isnull((select ma_costo from vmaestrocost 
							where vmaestrocost.ma_codigo=maestro.ma_codigo),0)
		from maestro where ma_inv_gen='g' 
		and ti_codigo in (select ti_codigo from configuratipo where cft_tipo='R' or cft_tipo = 'E' or cft_tipo='L' or cft_tipo='M' or cft_tipo='T' or cft_tipo='O')
		and ma_codigo not in
			(SELECT     MA_GENERICO
			FROM         PERMISODET
			WHERE     PED_REGISTROTIPO = 1 AND PE_CODIGO = @PE_CODIGO
				and PED_ID_SUBORD=@PED_ID_SUBORD) 
		and ar_impmx=@AR_IMPMX



	FETCH NEXT FROM cur_insertaGenerico INTO @PED_ID_SUBORD, @AR_IMPMX

END

CLOSE cur_insertaGenerico
DEALLOCATE cur_insertaGenerico































GO
