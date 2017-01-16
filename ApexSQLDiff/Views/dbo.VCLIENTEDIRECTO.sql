SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO







































CREATE VIEW dbo.VCLIENTEDIRECTO
with encryption as
SELECT     dbo.CLIENTE.CL_RAZON, dbo.CLIENTE.CL_RFC, dbo.CLIENTE.CL_ANIOPPS, dbo.CLIENTE.CL_NOPPS, dbo.DECANUALPPS.DAP_CODIGO
FROM         dbo.VPEDEXP INNER JOIN
                      dbo.DECANUALPPS ON dbo.VPEDEXP.PI_FEC_PAG >= dbo.DECANUALPPS.DAP_INICIO AND 
                      dbo.VPEDEXP.PI_FEC_PAG <= dbo.DECANUALPPS.DAP_FINAL LEFT OUTER JOIN
                      dbo.CLIENTE ON dbo.VPEDEXP.PR_CODIGO = dbo.CLIENTE.CL_CODIGO
WHERE     (dbo.CLIENTE.CL_TIPOPRODUCTOR = 'D') AND (dbo.CLIENTE.CL_TIPO <> 'X' AND dbo.CLIENTE.CL_TIPO <> 'N') AND
CP_CODIGO IN (select cp_codigo from configuraclaveped where ccp_tipo='ER')
GROUP BY dbo.CLIENTE.CL_RAZON, dbo.CLIENTE.CL_RFC, dbo.CLIENTE.CL_ANIOPPS, dbo.CLIENTE.CL_NOPPS, dbo.DECANUALPPS.DAP_CODIGO

































































GO
