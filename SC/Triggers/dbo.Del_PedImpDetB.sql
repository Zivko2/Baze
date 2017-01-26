SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

CREATE trigger Del_PedImpDetB on dbo.PEDIMPDETB for DELETE as
SET NOCOUNT ON


   IF EXISTS (SELECT * FROM PedImpDetIdentifica ,deleted WHERE PedImpDetIdentifica.pib_indiceb = deleted.pib_indiceb)
      DELETE PedImpDetIdentifica FROM PedImpDetIdentifica ,deleted WHERE PedImpDetIdentifica.pib_indiceb = deleted.pib_indiceb

   IF EXISTS (SELECT * FROM PedImpDetBContribucion ,deleted WHERE PedImpDetBContribucion.pib_indiceb = deleted.pib_indiceb)
      DELETE PedImpDetBContribucion FROM PedImpDetBContribucion ,deleted WHERE PedImpDetBContribucion.pib_indiceb = deleted.pib_indiceb


   if not exists(select * from pedimpdetb where pi_codigo in (select pi_codigo from deleted))
    update pedimp 
    set pi_cuentadetb=0
    where pi_codigo in (select pi_codigo from deleted)

GO
