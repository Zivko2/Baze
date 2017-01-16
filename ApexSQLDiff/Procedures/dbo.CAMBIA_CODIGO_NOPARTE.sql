SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CAMBIA_CODIGO_NOPARTE] (@user int, @ma_codigoOrig int, @ma_codigoNvo int)    as

declare @noparte varchar(30), @auxiliar varchar(10), @noparte1 varchar(30), @auxiliar1 varchar(10)

SELECT @noparte=MA_NOPARTE, @auxiliar=MA_NOPARTEAUX FROM MAESTRO WHERE MA_CODIGO=@ma_codigoNvo
SELECT @noparte1=MA_NOPARTE, @auxiliar1=MA_NOPARTEAUX FROM MAESTRO WHERE MA_CODIGO=@ma_codigoOrig

	UPDATE PCKLISTDET
	SET MA_CODIGO=@ma_codigoNvo
	WHERE MA_CODIGO=@ma_codigoOrig

	UPDATE LISTAEXPDET
	SET MA_CODIGO=@ma_codigoNvo
	WHERE MA_CODIGO=@ma_codigoOrig


	UPDATE FACTIMPDET
	SET MA_CODIGO=@ma_codigoNvo
	WHERE MA_CODIGO=@ma_codigoOrig

	UPDATE PEDIMPDET
	SET MA_CODIGO=@ma_codigoNvo
	WHERE MA_CODIGO=@ma_codigoOrig

	UPDATE FACTEXPDET
	SET MA_CODIGO=@ma_codigoNvo
	WHERE MA_CODIGO=@ma_codigoOrig

	UPDATE BOM_STRUCT
	SET BST_HIJO=@ma_codigoNvo,
	BST_NOPARTE=@noparte, 
	BST_NOPARTEAUX=@auxiliar
	WHERE BST_HIJO=@ma_codigoOrig


	UPDATE BOM_STRUCT
	SET BSU_SUBENSAMBLE=@ma_codigoNvo,
	BSU_NOPARTE=@noparte,
	BSU_NOPARTEAUX=@auxiliar
	WHERE BSU_SUBENSAMBLE=@ma_codigoOrig


	exec SP_CREATABLALOG 230
	insert into sysusrlog230 (user_id, mov_id, referencia, frmtag, fechahora)
	values (@user, 2, 'Actualizacion Masa-Reemplazo No. Parte ('+@noparte+','+@auxiliar+' Anterior:'+@noparte1+','+@auxiliar1+')', 230, getdate())

























GO
