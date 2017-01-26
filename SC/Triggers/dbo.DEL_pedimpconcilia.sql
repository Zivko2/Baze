SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO




CREATE TRIGGER [DEL_pedimpconcilia] ON [dbo].[pedimpconcilia] 
FOR DELETE 
AS


  IF EXISTS (SELECT * FROM pedimpconciliaDetContribucion, Deleted  WHERE  pedimpconciliaDetContribucion.Pedimento = Deleted.Pedimento)
     DELETE pedimpconciliaDetContribucion FROM pedimpconciliaDetContribucion, Deleted  WHERE pedimpconciliaDetContribucion.Pedimento = Deleted.Pedimento

  IF EXISTS (SELECT * FROM pedimpconciliaDetContribucionTasa, Deleted  WHERE  pedimpconciliaDetContribucionTasa.Pedimento = Deleted.Pedimento)
     DELETE pedimpconciliaDetContribucionTasa FROM pedimpconciliaDetContribucionTasa, Deleted  WHERE pedimpconciliaDetContribucionTasa.Pedimento = Deleted.Pedimento


  IF EXISTS (SELECT * FROM pedimpconciliaContribucion, Deleted  WHERE  pedimpconciliaContribucion.Pedimento = Deleted.Pedimento)
     DELETE pedimpconciliaContribucion FROM pedimpconciliaContribucion, Deleted  WHERE pedimpconciliaContribucion.Pedimento = Deleted.Pedimento

  IF EXISTS (SELECT * FROM pedimpconciliaContribucionTasa, Deleted  WHERE  pedimpconciliaContribucionTasa.Pedimento = Deleted.Pedimento)
     DELETE pedimpconciliaContribucionTasa FROM pedimpconciliaContribucionTasa, Deleted  WHERE pedimpconciliaContribucionTasa.Pedimento = Deleted.Pedimento


  IF EXISTS (SELECT * FROM pedimpconciliaIdentifica, Deleted  WHERE  pedimpconciliaIdentifica.Pedimento = Deleted.Pedimento)
     DELETE pedimpconciliaIdentifica FROM pedimpconciliaIdentifica, Deleted  WHERE pedimpconciliaIdentifica.Pedimento = Deleted.Pedimento

  IF EXISTS (SELECT * FROM pedimpconciliaDetIdentifica, Deleted  WHERE  pedimpconciliaDetIdentifica.Pedimento = Deleted.Pedimento)
     DELETE pedimpconciliaDetIdentifica FROM pedimpconciliaDetIdentifica, Deleted  WHERE pedimpconciliaDetIdentifica.Pedimento = Deleted.Pedimento


  IF EXISTS (SELECT * FROM pedimpconciliaDet, Deleted  WHERE  pedimpconciliaDet.Pedimento = Deleted.Pedimento)
     DELETE pedimpconciliaDet FROM pedimpconciliaDet, Deleted  WHERE pedimpconciliaDet.Pedimento = Deleted.Pedimento

  IF EXISTS (SELECT * FROM pedimpconciliaInvoice, Deleted  WHERE  pedimpconciliaInvoice.Pedimento = Deleted.Pedimento)
     DELETE pedimpconciliaInvoice FROM pedimpconciliaInvoice, Deleted  WHERE pedimpconciliaInvoice.Pedimento = Deleted.Pedimento













































GO
