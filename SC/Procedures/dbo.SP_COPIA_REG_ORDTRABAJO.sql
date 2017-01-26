SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO


-- copia de  la orden de trabajo hacia el reporte de produccion
CREATE PROCEDURE [dbo].[SP_COPIA_REG_ORDTRABAJO] (@ot_origen int, @pro_destino int)  as

SET NOCOUNT ON 
declare @prod_indiced int, @CONSECUTIVO int, @MA_CODIGO int, @OTD_NOPARTE varchar(30), @OTD_NOMBRE varchar(150), 
@OTD_SIZELOTE decimal(38,6), @ME_CODIGO int, @OT_TIPO char(1)

DECLARE curOrdTrabajoCopia CURSOR FOR
SELECT     MA_CODIGO, OTD_NOPARTE, OTD_NOMBRE, OTD_SALDO, ME_CODIGO
FROM         dbo.ORDTRABAJODET
WHERE     (OT_CODIGO = @ot_origen) AND OTD_SALDO >0
	OPEN curOrdTrabajoCopia
	FETCH NEXT FROM curOrdTrabajoCopia INTO @MA_CODIGO, @OTD_NOPARTE, @OTD_NOMBRE, @OTD_SIZELOTE, @ME_CODIGO
		WHILE (@@fetch_status <> -1)
		BEGIN  --1
			select @OT_TIPO=OT_TIPO from ORDTRABAJO WHERE OT_CODIGO=@ot_origen
			SELECT @CONSECUTIVO=ISNULL(MAX(PROD_INDICED),0) FROM PRODUCDET 
			SET @CONSECUTIVO=@CONSECUTIVO+1

		insert into PRODUCDET(PRO_CODIGO, PROD_INDICED, MA_CODIGO, PROD_NOPARTE, PROD_NOMBRE, PROD_CANT, ME_CODIGO, PROD_CANTPEND, 
		                      PROD_TIPODESCARGA)
		values (@pro_destino, @CONSECUTIVO, @MA_CODIGO, @OTD_NOPARTE, @OTD_NOMBRE, @OTD_SIZELOTE, @ME_CODIGO, @OTD_SIZELOTE, @OT_TIPO)

	FETCH NEXT FROM curOrdTrabajoCopia INTO @MA_CODIGO, @OTD_NOPARTE, @OTD_NOMBRE, @OTD_SIZELOTE, @ME_CODIGO
	end

	CLOSE curOrdTrabajoCopia
	DEALLOCATE curOrdTrabajoCopia

select @prod_indiced= max(prod_indiced) from producdet
	update consecutivo
	set cv_codigo =  isnull(@prod_indiced,0) + 1
	where cv_tipo = 'PROD'

GO
