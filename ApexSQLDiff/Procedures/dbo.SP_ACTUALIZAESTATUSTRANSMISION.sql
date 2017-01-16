SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[SP_ACTUALIZAESTATUSTRANSMISION] (@TRM_CODIGO INT)   as

     DECLARE @TRMD_ESTATUS CHAR(1),@TRMD_TIPO CHAR(1)

    SELECT @TRMD_ESTATUS = TD.TRMD_ESTATUS,@TRMD_TIPO = TD.TRMD_TIPO  FROM TRANSMISIONDET TD,VISTAULTIMOMOVTRANSMISIONDET VUMTD   WHERE TD.TRM_CODIGO = @TRM_CODIGO AND TD.TRMD_INDICED = VUMTD.TRMD_INDICED

    UPDATE TRANSMISION SET TRM_ESTATUS =
        CASE @TRMD_TIPO
            WHEN 'P' THEN
                CASE @TRMD_ESTATUS
                    WHEN 'S' THEN 'S'
                    WHEN 'R' THEN 'P'
                    WHEN 'E' THEN 'H'
                    ELSE 'N'
                END
            WHEN 'F' THEN
                CASE @TRMD_ESTATUS
                    WHEN 'S' THEN 'D'
                    WHEN 'R' THEN 'F'
                    WHEN 'E' THEN 'A'
                    ELSE 'N'
                END
            WHEN 'B' THEN
                CASE @TRMD_ESTATUS
                    WHEN 'S' THEN 'E'
                    WHEN 'R' THEN 'G'
                    ELSE 'N'
                END
            ELSE 'N'
        END
    WHERE TRM_CODIGO = @TRM_CODIGO






















GO
