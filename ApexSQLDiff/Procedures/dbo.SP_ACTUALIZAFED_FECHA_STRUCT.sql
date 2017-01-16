SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO































CREATE PROCEDURE [dbo].[SP_ACTUALIZAFED_FECHA_STRUCT] (@fe_codigo int)   as

SET NOCOUNT ON 
declare @owner varchar(150)


	


	UPDATE FACTEXPDET
	SET FED_FECHA_STRUCT=CASE WHEN (SELECT COUNT(BSU_SUBENSAMBLE) FROM BOM_STRUCT WHERE BSU_SUBENSAMBLE = MA_CODIGO AND BST_PERINI<=FE_FECHA AND BST_PERFIN>=FE_FECHA)>0
							 THEN convert(varchar(10), getdate(),101) 
							 ELSE 
								CASE WHEN (select ti_nombre from tipo where ti_codigo = factexpdet.ti_codigo) like '%DESPERDICIOS%' 
										and (select tq_nombre from tembarque where tq_codigo = factexp.tq_codigo) like '%DESPERDICIO%' 
									THEN
										factexp.fe_fecha
									ELSE Null 
								END
							 END
	FROM FACTEXPDET INNER JOIN FACTEXP ON FACTEXPDET.FE_CODIGO=FACTEXP.FE_CODIGO
	WHERE FACTEXPDET.FE_CODIGO=@fe_codigo





GO
