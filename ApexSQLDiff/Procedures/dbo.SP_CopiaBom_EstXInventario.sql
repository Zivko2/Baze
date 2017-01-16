SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
























CREATE PROCEDURE [dbo].[SP_CopiaBom_EstXInventario] (@fechaInv datetime)   as

SET NOCOUNT ON
DECLARE @CONSECUTIVO INT, @fed_indiced int, @FE_FECHA DATETIME



		alter table [factexpdet] disable trigger [Update_FactExpDet]

		update FACTEXPDET 
		set FED_RETRABAJO = 'E' 
		where FED_INDICED 
			in (select fed_indiced from RELFEDGENERICO 
--			where substring(BST_NIVEL,1,1) = 'B' or substring(BST_NIVEL,1,1) = 'M' 
			group by fed_indiced)
		and  FED_RETRABAJO = 'N'

		alter table [factexpdet] enable trigger [Update_FactExpDet]



		insert into CambiosXInventario (FED_INDICED, TIPO) 
		select fed_indiced, 'L' 
		from factexpdet 
		where FED_RETRABAJO = 'E' 
		and fed_indiced not in (select fed_indiced from CambiosXInventario)


	UPDATE dbo.RELFEDGENERICO
	SET     dbo.RELFEDGENERICO.MA_GENERICO= dbo.MAESTRO.MA_GENERICO
	FROM         dbo.RELFEDGENERICO INNER JOIN
	                      dbo.MAESTRO ON dbo.RELFEDGENERICO.BST_HIJO = dbo.MAESTRO.MA_CODIGO AND 
	                      dbo.RELFEDGENERICO.MA_GENERICO <> dbo.MAESTRO.MA_GENERICO



























GO
