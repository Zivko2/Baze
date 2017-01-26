SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SP_TRANSMISIONDET] (@trm_codigo int, @nombrearchivo varchar(50), @Estatus char(1), @tipo char(1), @User int)   as
      
     DECLARE @TRMD_INDICED INT,@TRMD_ESTATUS CHAR(1), @TRMD_TIPOSAAI CHAR(1), @TRMD_TIPOSAAI2 CHAR(1)

    SELECT @TRMD_TIPOSAAI=TRM_TIPOSAAI FROM TRANSMISION WHERE TRM_CODIGO=@trm_codigo

    SELECT @TRMD_ESTATUS = TD.TRMD_ESTATUS,@TRMD_INDICED = TD.TRMD_INDICED, @TRMD_TIPOSAAI2=TRMD_TIPOSAAI  FROM TRANSMISIONDET TD,VISTAULTIMOMOVTRANSMISIONDET VUMTD   WHERE TD.TRM_CODIGO = @TRM_CODIGO AND TD.TRMD_INDICED = VUMTD.TRMD_INDICED

    IF (@TRMD_ESTATUS = 'G'  and @Estatus = 'G') or (@TRMD_ESTATUS = 'S'  and @Estatus = 'S') and @TRMD_TIPOSAAI=@TRMD_TIPOSAAI2
        UPDATE transmisiondet SET TRMD_FECHAHORA=getdate(),TRMD_NOMBREARCH=@nombrearchivo,US_CODIGO=@User WHERE TRMD_INDICED = @TRMD_INDICED 
    ELSE
        INSERT INTO transmisiondet(TRM_CODIGO, TRMD_NOMBREARCH, TRMD_TIPO, TRMD_FECHAHORA, TRMD_ESTATUS, US_CODIGO, TRMD_TIPOSAAI)
        VALUES(@trm_codigo, @nombrearchivo, @tipo, getdate(), @Estatus, @User, @TRMD_TIPOSAAI)



GO
