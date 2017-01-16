SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

























CREATE VIEW dbo.VTRANSMISIONDET
with encryption as
SELECT     TRM_CODIGO, TRMD_TIPO, MAX(TRMD_FECHAHORA) AS TRMD_FECHAHORA,
                          (SELECT     TRANSMISIONDET1.TRMD_ESTATUS
                            FROM          TRANSMISIONDET TRANSMISIONDET1
                            WHERE      TRANSMISIONDET1.TRM_CODIGO = TRANSMISIONDET.TRM_CODIGO AND 
                                                   TRANSMISIONDET1.TRMD_FECHAHORA = MAX(TRANSMISIONDET.TRMD_FECHAHORA)) AS TRMD_ESTATUS,
                          (SELECT     TRANSMISIONDET2.TRMD_NOMBREARCH
                            FROM          TRANSMISIONDET TRANSMISIONDET2
                            WHERE      TRANSMISIONDET2.TRM_CODIGO = TRANSMISIONDET.TRM_CODIGO AND 
                                                   TRANSMISIONDET2.TRMD_FECHAHORA = MAX(TRANSMISIONDET.TRMD_FECHAHORA)) AS TRMD_NOMBREARCH
FROM         dbo.TRANSMISIONDET
GROUP BY TRMD_TIPO, TRM_CODIGO



































GO
