SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO




























CREATE PROCEDURE dbo.SP_BOMBORRAR (@pt int, @Bst_hijo Int, @percambios char(1))   as

SET NOCOUNT ON 

	DECLARE @Fecha DateTime, @ayer datetime, @ptcount int, @BM_ENTRAVIGOR datetime, @BM_ENTRAVIGORmenos1 datetime

	SET @Fecha =convert(datetime, convert(varchar(11), getdate(),101))

	SELECT @BM_ENTRAVIGOR = bst_perini FROM bom_struct WHERE bsu_SUBENSAMBLE=@PT AND bst_perini <=@Fecha AND bst_perfin >=@Fecha

	set @BM_ENTRAVIGORmenos1 = @BM_ENTRAVIGOR-1
	SET @Ayer = convert(datetime, floor(convert(decimal(38,6), getdate()-1)))

	select @ptcount = count(*) from bom where ma_subensamble= @PT


	if @percambios ='S'
	begin	
		if  @ptcount =1
		/* si esta en periodo de cambios es decir no guarda historial lo borra directamente */
		delete from bom_struct where bsu_subensamble =@pt and bst_hijo =@bst_hijo and bst_perini<=@fecha and bst_perfin >=@fecha
		
		if @ptcount >1

		update bom_struct
		set bst_perfin = @BM_ENTRAVIGORmenos1
		where bsu_subensamble =@pt and bst_hijo =@bst_hijo and bst_perini<=@fecha and bst_perfin >=@fecha
	end
	else
	begin

	/* si guarda historial lo unico que hace es que le pone fecha final pero para que no lo agarre debe de insertar un registro en bom*/

		update bom_struct
		set bst_perfin =@Ayer 
		where bst_hijo =@bst_hijo and bst_perini<=@fecha and bst_perfin >=@fecha
		and bsu_subensamble=@pt

	end



























GO
