SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO





















CREATE TRIGGER [INSERT_BOM_STRUCT] ON dbo.BOM_STRUCT 
FOR INSERT
AS
SET NOCOUNT ON 

	declare @TipoLetra char(1), @bst_codigo int, @bsu_subensamble int, @bst_hijo  int, @perini  varchar(10),
	@dummy char(1), @codigo int, @Factconv decimal(28,14), @pa_codigo int, @pa_origen int, @AYER datetime, @hoy  datetime, @bstcodigoactual int,
	@bstcodigoanterior  int, @count int, @bmperfinanterior datetime, @entravigorantes datetime, @entravigor1 datetime, @perfin varchar(10),
	@bmentravigorposterior datetime, @bstcodigoposterior int, @perfinantes datetime, @bmperfin1 datetime, @bst_trans char(1)


	/*-------------------------------------------------------*/
	-- obtener la info del registro insertado
	declare crBOMInsert cursor for
		select  bst_codigo, bsu_subensamble, 
		bst_hijo, convert(varchar(10), bst_perini,101), factconv, convert(varchar(10), bst_perfin,101), bst_trans  from inserted
	open crBOMInsert
	fetch next from crBOMInsert into @bst_codigo, @bsu_subensamble, @bst_hijo, @perini, @factconv, @perfin, @bst_trans
	
		WHILE (@@FETCH_STATUS = 0) 
		BEGIN

			-- actualiza la fecha final del ultimo resgitro antes de la insercion
			if exists(select * from bom_struct where bsu_subensamble=@bsu_subensamble
				and bst_hijo=@bst_hijo and bst_codigo <>@bst_codigo)
			exec SP_BOM_STRUCTACTUALIZAFECHAS @BST_CODIGO,  'S', 'N', @perini, @perfin



			-- actualizar bom_costo
			/*if exists (select * from vmaestrocost where ma_codigo=@bst_hijo)
			exec sp_actualizaBomCosto @bst_codigo*/
		
			if @factconv=0
			update bom_struct
			set factconv=1
			where bst_codigo =@bst_codigo


	fetch next from crBOMInsert into @bst_codigo, @bsu_subensamble, @bst_hijo, @perini, @factconv, @perfin, @bst_trans
	END
	CLOSE crBOMInsert
	DEALLOCATE crBOMInsert





















GO
