SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SP_IMPORTADETORDTRABAJOTOT] (@OT_CODIGO int, @OR_CODIGO int)   as

SET NOCOUNT ON 
declare @MA_CODIGO int, @FechaActual datetime, @maximo int,@ORD_INDICED int, @OTD_INDICED int, @OTD_CANT decimal(38,6)
  SET @FechaActual = convert(varchar(10), getdate(),101)
	TRUNCATE TABLE TempImpOrdTrabajo
	SELECT @maximo=MAX(ORD_INDICED)+1 FROM ORDCOMPRADET
	dbcc checkident (TempImpOrdTrabajo, reseed, @maximo) WITH NO_INFOMSGS
	declare cur_bstOrdTrabajo cursor for
		Select MA_CODIGO, OTD_SALDOORDTRABAJO, OTD_INDICED 
		from ordTrabajoDet 
		where OT_CODIGO=@OT_CODIGO AND OTD_SALDOORDTRABAJO>0
	open cur_bstOrdTrabajo
	
	
		FETCH NEXT FROM cur_bstOrdTrabajo INTO @MA_CODIGO, @OTD_CANT, @OTD_INDICED
	
		WHILE (@@FETCH_STATUS = 0) 
		BEGIN
	
	
			EXEC SP_FILL_TempImpOrdTrabajo @OTD_INDICED, @MA_CODIGO, @FechaActual, @OTD_CANT, @OT_CODIGO
	
	
		FETCH NEXT FROM cur_bstOrdTrabajo INTO @MA_CODIGO, @OTD_CANT, @OTD_INDICED
	
	END
	
	CLOSE cur_bstOrdTrabajo
	DEALLOCATE cur_bstOrdTrabajo
	insert into ordCompraDet (ORD_INDICED,OR_CODIGO,ORD_CANT_ST,ORD_COS_UNI,ORD_COS_TOT,ORD_NOMBRE,ORD_NAME,ORD_NOPARTE,
	                          MA_CODIGO,ME_CODIGO,TI_CODIGO,TCO_CODIGO,OT_CODIGO,OTD_INDICED, ORD_SALDO, OTD_SALDOUSAORDTRAB, OT_FOLIO)
SELECT  
dbo.TempImpOrdTrabajo.OT_IDENTITY,@OR_CODIGO, 
'cantidad'= case 
	when dbo.MAESTROALM.MAA_SIZELOTE is null or dbo.MAESTROALM.MAA_SIZELOTE=0   then ceiling(SUM(dbo.TempImpOrdTrabajo.BST_INCORPOR * dbo.TempImpOrdTrabajo.OTD_CANT))  
	when dbo.MAESTROALM.MAA_SIZELOTE >= SUM(dbo.TempImpOrdTrabajo.BST_INCORPOR * dbo.TempImpOrdTrabajo.OTD_CANT) then ceiling(dbo.MAESTROALM.MAA_SIZELOTE)
	when dbo.MAESTROALM.MAA_SIZELOTE < SUM(dbo.TempImpOrdTrabajo.BST_INCORPOR * dbo.TempImpOrdTrabajo.OTD_CANT) then 
	ceiling(dbo.MAESTROALM.MAA_SIZELOTE) * case 
                                   when dbo.Entero(CEILING(SUM(dbo.TempImpOrdTrabajo.BST_INCORPOR * dbo.TempImpOrdTrabajo.OTD_CANT)),ceiling(dbo.MAESTROALM.MAA_SIZELOTE))>0
                                   then CEILING (SUM(dbo.TempImpOrdTrabajo.BST_INCORPOR * dbo.TempImpOrdTrabajo.OTD_CANT)/ceiling(dbo.MAESTROALM.MAA_SIZELOTE))
				   else Ceiling(SUM(dbo.TempImpOrdTrabajo.BST_INCORPOR * dbo.TempImpOrdTrabajo.OTD_CANT))/ceiling(dbo.MAESTROALM.MAA_SIZELOTE)			
				  end
	end,
isnull(dbo.VMAESTROCOST.MA_COSTO,0), 
             isnull(SUM(dbo.TempImpOrdTrabajo.BST_INCORPOR * dbo.TempImpOrdTrabajo.OTD_CANT * dbo.VMAESTROCOST.MA_COSTO),0) AS CostoTotal, 
                      dbo.MAESTRO.MA_NOMBRE, dbo.MAESTRO.MA_NAME, dbo.MAESTRO.MA_NOPARTE, dbo.MAESTRO.MA_CODIGO, 
                      dbo.TempImpOrdTrabajo.ME_CODIGO, dbo.MAESTRO.TI_CODIGO, dbo.VMAESTROCOST.TCO_CODIGO, dbo.TempImpOrdTrabajo.OT_CODIGO, 
	         dbo.TempImpOrdTrabajo.OTD_INDICED, ceiling(SUM(dbo.TempImpOrdTrabajo.BST_INCORPOR * dbo.TempImpOrdTrabajo.OTD_CANT)) AS Saldo, 
                      ceiling(SUM(dbo.TempImpOrdTrabajo.BST_INCORPOR * dbo.TempImpOrdTrabajo.OTD_CANT)),(select ot_folio from ordTrabajo where ot_codigo= @OT_CODIGO)
FROM         dbo.MAESTROALM RIGHT OUTER JOIN
                      dbo.MAESTRO ON dbo.MAESTROALM.MA_CODIGO = dbo.MAESTRO.MA_CODIGO RIGHT OUTER JOIN
                      dbo.TempImpOrdTrabajo LEFT OUTER JOIN
                      dbo.VMAESTROCOST ON dbo.TempImpOrdTrabajo.BST_HIJO = dbo.VMAESTROCOST.MA_CODIGO ON 
                      dbo.MAESTRO.MA_CODIGO = dbo.TempImpOrdTrabajo.BST_HIJO
GROUP BY dbo.MAESTRO.MA_CODIGO, dbo.MAESTRO.MA_NOPARTE, dbo.TempImpOrdTrabajo.OTD_INDICED, dbo.TempImpOrdTrabajo.OT_CODIGO, 
                      dbo.VMAESTROCOST.TCO_CODIGO, dbo.MAESTRO.MA_NOMBRE, dbo.MAESTRO.MA_NAME, dbo.VMAESTROCOST.MA_COSTO, 
                      dbo.TempImpOrdTrabajo.ME_CODIGO, dbo.MAESTRO.TI_CODIGO, dbo.TempImpOrdTrabajo.OT_IDENTITY, dbo.MAESTROALM.MAA_SIZELOTE	
	INSERT INTO KARDESORDTRABAJO (ORD_INDICED, OTD_INDICED, ORD_CANTDESC)
	SELECT     dbo.TempImpOrdTrabajo.OT_IDENTITY, dbo.TempImpOrdTrabajo.OTD_INDICED, SUM(dbo.TempImpOrdTrabajo.BST_INCORPOR * dbo.TempImpOrdTrabajo.OTD_CANT * dbo.VMAESTROCOST.MA_COSTO)  
	FROM         dbo.TempImpOrdTrabajo LEFT OUTER JOIN
	                      dbo.VMAESTROCOST ON dbo.TempImpOrdTrabajo.BST_HIJO = dbo.VMAESTROCOST.MA_CODIGO LEFT OUTER JOIN
	                      dbo.MAESTRO ON dbo.TempImpOrdTrabajo.BST_HIJO = dbo.MAESTRO.MA_CODIGO
	GROUP BY dbo.TempImpOrdTrabajo.OTD_INDICED,  dbo.TempImpOrdTrabajo.OT_IDENTITY
	
select @ORD_INDICED=max(ord_indiced) from ordCompraDet
update consecutivo
set cv_codigo =  isnull(@ORD_INDICED,0) + 1
where cv_tipo = 'ORD'

GO
