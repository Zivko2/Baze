SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO































CREATE VIEW dbo.VPERMISOSALDOTOT
with encryption as
SELECT     dbo.PERMISO.PE_CODIGO, ROUND(dbo.PERMISO.PE_SALDO, 6) AS PE_SALDO, 
ROUND(dbo.PERMISO.PE_SALDOCOSTOT, 6) AS PE_SALDOCOSTOT, 
                      ROUND(dbo.PERMISO.PE_CANT - ISNULL
                          ((SELECT     SUM(KAR_CANTDESC)
                              FROM         dbo.KARDESPERMISO INNER JOIN PERMISODET P1 ON KARDESPERMISO.PED_INDICED=P1.PED_INDICED
                              WHERE     KAR_TIPO='C' AND P1.PE_CODIGO = PERMISO.PE_CODIGO), 0), 6) AS KAR_SALDO,
                      ROUND(dbo.PERMISO.PE_COSTOT - ISNULL
                          ((SELECT     SUM(KAR_CANTDESC)
                              FROM         dbo.KARDESPERMISO INNER JOIN PERMISODET P2 ON KARDESPERMISO.PED_INDICED=P2.PED_INDICED
                              WHERE     KAR_TIPO='V' AND P2.PE_CODIGO = PERMISO.PE_CODIGO), 0), 6) AS KAR_SALDOCOSTOT
FROM         dbo.PERMISO 
WHERE ROUND(dbo.PERMISO.PE_SALDO, 6) 
                      <> ROUND(dbo.PERMISO.PE_CANT - ISNULL
                          ((SELECT     SUM(KAR_CANTDESC)
                              FROM         dbo.KARDESPERMISO INNER JOIN PERMISODET P1 ON KARDESPERMISO.PED_INDICED=P1.PED_INDICED
                              WHERE    KAR_TIPO='C' AND P1.PE_CODIGO = PERMISO.PE_CODIGO), 0), 6) OR
ROUND(dbo.PERMISO.PE_SALDOCOSTOT, 6) 
                      <> ROUND(dbo.PERMISO.PE_COSTOT - ISNULL
                          ((SELECT     SUM(KAR_CANTDESC)
                              FROM         dbo.KARDESPERMISO INNER JOIN PERMISODET P2 ON KARDESPERMISO.PED_INDICED=P2.PED_INDICED
                              WHERE    KAR_TIPO='V' AND P2.PE_CODIGO = PERMISO.PE_CODIGO), 0), 6)































GO
