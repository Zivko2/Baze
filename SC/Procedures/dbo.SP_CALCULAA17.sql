SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

















































CREATE PROCEDURE [dbo].[SP_CALCULAA17]  (@A17_codigo int)   as

SET NOCOUNT ON 
declare @FECHAINI DATETIME, @FECHAFIN DATETIME, @valor decimal(38,6), @CL_CODIGO INT, @PID_CTOT_DLS decimal(38,6), @PR_CODIGO int, 
@PID_NOMBRE varchar(150), @MA_GENERICO int, @MA_CODIGO int, @FAMILIAPT varchar(150), @exportacion decimal(38,6), @valortotal decimal(38,6),
@total decimal(38,6), @nacional decimal(38,6), @proporcionexp decimal(38,6), @A17_TOTALEXP decimal(38,6), @A17_TOTALVENTAS decimal(38,6), @A17_PROPORCION decimal(38,6), @ma_familia int,
@PI_CODIGO int

	if exists (select * from A17Det where A17_CODIGO = @A17_codigo)
	delete from A17Det where A17_CODIGO = @A17_codigo

	SELECT     @FECHAINI= A17_FECHAINI, @FECHAFIN= A17_FECHAFIN, @ma_familia= MA_FAMILIA
	FROM         A17
	WHERE  A17_CODIGO = @A17_codigo

declare cur_a17 cursor for
SELECT     round(sum(isnull(valor,0)),0), sum(PID_CTOT_DLS), PR_CODIGO, 
	CL_CODIGO, MA_GENERICO, MAX(FAMILIAPT), PI_CODIGO
FROM         VA17
WHERE  A17_CODIGO = @A17_codigo and MA_CODIGO=@ma_familia
GROUP BY PR_CODIGO, MA_GENERICO, CL_CODIGO, PI_CODIGO


open cur_a17


	FETCH NEXT FROM cur_a17 INTO @valor, @PID_CTOT_DLS, @PR_CODIGO, 
	@CL_CODIGO, @MA_GENERICO, @FAMILIAPT, @PI_CODIGO 

	WHILE (@@FETCH_STATUS = 0) 
	BEGIN

		insert into A17DET(A17_CODIGO, MA_GENERICO, CL_CODIGO, A17D_VALORTRANS, 
		A17D_VALORADQ0, A17D_PROPORCION, PI_CODIGO)
			
		VALUES (@A17_codigo, @MA_GENERICO, @PR_CODIGO, @valor, @valor, '100', @PI_CODIGO)



	FETCH NEXT FROM cur_a17 INTO @valor, @PID_CTOT_DLS, @PR_CODIGO, 
	@CL_CODIGO, @MA_GENERICO, @FAMILIAPT, @PI_CODIGO


END

CLOSE cur_a17
DEALLOCATE cur_a17
















































GO
