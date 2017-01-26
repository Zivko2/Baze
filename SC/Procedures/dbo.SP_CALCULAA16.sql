SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

















































CREATE PROCEDURE [dbo].[SP_CALCULAA16]  (@A16_codigo int)   as

SET NOCOUNT ON 
declare @FECHAINI DATETIME, @FECHAFIN DATETIME, @valor decimal(38,6), @CL_CODIGO INT, @PID_CTOT_DLS decimal(38,6), @PR_CODIGO int, 
@PID_NOMBRE varchar(150), @MA_GENERICO int, @MA_CODIGO int, @FAMILIAPT varchar(150), @exportacion decimal(38,6), @valortotal decimal(38,6),
@total decimal(38,6), @nacional decimal(38,6), @proporcionexp decimal(38,6), @A16_TOTALEXP decimal(38,6), @A16_TOTALVENTAS decimal(38,6), @A16_PROPORCION decimal(38,6), @ma_familia int,
@PI_CODIGO int



	if exists (select * from A16Det where A16_CODIGO = @A16_codigo)
	delete from A16Det where A16_CODIGO = @A16_codigo

	SELECT     @FECHAINI= A16_FECHAINI, @FECHAFIN= A16_FECHAFIN, @ma_familia= MA_FAMILIA
	FROM         A16
	WHERE  A16_CODIGO = @A16_codigo

declare cur_a16 cursor for
SELECT     round(sum(isnull(valor,0)),0), sum(PID_CTOT_DLS), PR_CODIGO, 
	CL_CODIGO, MA_GENERICO, MAX(FAMILIAPT), PI_CODIGO
FROM         VA16
WHERE  A16_CODIGO = @A16_codigo and MA_CODIGO=@ma_familia
GROUP BY PR_CODIGO, MA_GENERICO, CL_CODIGO, PI_CODIGO


open cur_a16


	FETCH NEXT FROM cur_a16 INTO @valor, @PID_CTOT_DLS, @PR_CODIGO, 
	@CL_CODIGO, @MA_GENERICO, @FAMILIAPT, @PI_CODIGO

	WHILE (@@FETCH_STATUS = 0) 
	BEGIN

		insert into A16DET(A16_CODIGO, MA_GENERICO, CL_CODIGO, A16D_VALORTRANS, 
		A16D_VALORADQ0, A16D_PROPORCION, PI_CODIGO)
			
		VALUES (@A16_codigo, @MA_GENERICO, @PR_CODIGO, @valor, @valor, '100', @PI_CODIGO)


	FETCH NEXT FROM cur_a16 INTO @valor, @PID_CTOT_DLS, @PR_CODIGO, 
	@CL_CODIGO, @MA_GENERICO, @FAMILIAPT, @PI_CODIGO


END

CLOSE cur_a16
DEALLOCATE cur_a16

	
		SELECT     @exportacion= round(isnull(valor,0),0)
		FROM         VA16TOTAL
		WHERE  A16_CODIGO = @A16_codigo and MA_FAMILIA=@ma_familia
		and CP_CLAVE='J1'

		SELECT     @nacional= round(isnull(valor,0),0)
		FROM         VA16TOTAL
		WHERE  A16_CODIGO = @A16_codigo and MA_FAMILIA=@ma_familia
		and CP_CLAVE='F4'

		SELECT  @valortotal= round(sum(isnull(valor,0)),0)
		FROM         VA16
		WHERE  A16_CODIGO = @A16_codigo and ma_codigo=@ma_familia

	
		set @total= isnull(@exportacion,0) + isnull(@nacional,0)

		if @total>0 
			set @proporcionexp = (@exportacion *100)/@total
		else
			set @proporcionexp = 0
		
		set @A16_TOTALEXP= (@proporcionexp * @valortotal)/ 100

		set @A16_TOTALVENTAS= @valortotal
		
		if @A16_TOTALVENTAS>0
			set @A16_PROPORCION = (isnull(@A16_TOTALEXP,0)/isnull(@A16_TOTALVENTAS,0))*100
		else 
			set @A16_PROPORCION=100

		update A16
		SET A16_TOTALEXP = @A16_TOTALEXP, 
		A16_TOTALVENTAS = @A16_TOTALVENTAS, 
		A16_PROPORCION = @A16_PROPORCION
		WHERE  A16_CODIGO = @A16_codigo and ma_familia=@ma_familia
















































GO
