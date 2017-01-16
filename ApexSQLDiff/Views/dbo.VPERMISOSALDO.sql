SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO






CREATE VIEW dbo.VPERMISOSALDO
with encryption as
SELECT     dbo.PERMISODET.PED_INDICED, ROUND(dbo.PERMISODET.PED_SALDO, 6) AS PED_SALDO, 
ROUND(dbo.PERMISODET.PED_SALDOCOSTOT, 6) AS PED_SALDOCOSTOT, 
                      ROUND(dbo.PERMISODET.PED_CANT - ISNULL
                          ((SELECT     SUM(KAR_CANTDESC)
                              FROM         dbo.KARDESPERMISO
                              WHERE     KAR_TIPO='C' AND PED_INDICED = PERMISODET.PED_INDICED), 0), 6) AS KAR_SALDO,
                      ROUND(dbo.PERMISODET.PED_COSTOT - ISNULL
                          ((SELECT     SUM(KAR_CANTDESC)
                              FROM         dbo.KARDESPERMISO
                              WHERE     KAR_TIPO='V' AND PED_INDICED = PERMISODET.PED_INDICED), 0), 6) AS KAR_SALDOCOSTOT
FROM         dbo.PERMISODET 
WHERE ROUND(dbo.PERMISODET.PED_SALDO, 6) 
                      <> ROUND(dbo.PERMISODET.PED_CANT - ISNULL
                          ((SELECT     SUM(KAR_CANTDESC)
                              FROM         dbo.KARDESPERMISO
                              WHERE    KAR_TIPO='C' AND PED_INDICED = PERMISODET.PED_INDICED), 0), 6) OR
ROUND(dbo.PERMISODET.PED_SALDOCOSTOT, 6) 
                      <> ROUND(dbo.PERMISODET.PED_COSTOT - ISNULL
                          ((SELECT     SUM(KAR_CANTDESC)
                              FROM         dbo.KARDESPERMISO
                              WHERE    KAR_TIPO='V' AND PED_INDICED = PERMISODET.PED_INDICED), 0), 6)












GO
