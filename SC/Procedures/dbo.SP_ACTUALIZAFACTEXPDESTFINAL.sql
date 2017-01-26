SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO






















CREATE PROCEDURE [dbo].[SP_ACTUALIZAFACTEXPDESTFINAL] (@tf_codigo int, @tq_codigo int, @fe_fechaini datetime, @fe_fechafin datetime, @cl_codigo int)  as

SET NOCOUNT ON 

UPDATE FACTEXP
SET CL_DESTFIN=@cl_codigo, DI_DESTFIN=(SELECT DI_INDICE FROM DIR_CLIENTE WHERE CL_CODIGO=@cl_codigo AND DI_FISCAL='S')
WHERE TF_CODIGO=@tf_codigo AND TQ_CODIGO=@tq_codigo
AND FE_FECHA>=@fe_fechaini
AND FE_FECHA<=@fe_fechafin
















































GO
