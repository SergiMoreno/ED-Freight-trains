--    Programa main para la gestión de los trenes de carga de la estación     --
with destacion;

procedure Trenes_Carga is
   -- DECLARACIONES
   -- instanciamos el paquete de la estructura de datos implementada
   package estacion_trenes is new destacion(7);
   use estacion_trenes;

   -- declaración objeto del package destacion
   conj_trenes : cTrenes;
   tren1,tren2,tren3, tren4 : tcodigo;

begin
   -- CONJUNTO DE PRUEBAS
   -- preparamos la estructura
   vacio(conj_trenes);

   -- aparcamos 1a locomotora
   aparcaLocomotora(conj_trenes,"L1234567");
   -- aparcamos 7 vagones
   aparcaVagon(conj_trenes,"V1234567",5);
   aparcaVagon(conj_trenes,"V1234568",5);
   aparcaVagon(conj_trenes,"V1234569",41);
   aparcaVagon(conj_trenes,"V1234560",20);
   aparcaVagon(conj_trenes,"V1234561",7);
   aparcaVagon(conj_trenes,"V1234562",15);
   aparcaVagon(conj_trenes,"V1234563",10);

   -- creamos 1r tren con 5 vagones, dejando solo dos en el parking
   creaTren(conj_trenes,tren1,5);
   -- consultamos que se haya creado adecuadamente
   consultaTren(conj_trenes,tren1);

   -- aparcamos 2a locomotora
   aparcaLocomotora(conj_trenes,"L0440000");
   -- aparcamos 3a locomotora
   aparcaLocomotora(conj_trenes,"L1187441");
   -- aparcamos 3 vagones más, teniendo un total de 5 en el parking
   aparcaVagon(conj_trenes,"V0000000",9);
   aparcaVagon(conj_trenes,"V0000001",25);
   aparcaVagon(conj_trenes,"V0000002",1);
   -- creamos 2o tren
   creaTren(conj_trenes,tren2,2);

   aparcaLocomotora(conj_trenes,"L2252222");
   aparcaVagon(conj_trenes,"V2222222",55);
   aparcaVagon(conj_trenes,"V2222223",100);
   creaTren(conj_trenes,tren3,4);
   consultaTren(conj_trenes,tren3);
   creaTren(conj_trenes,tren4,1);

   -- listamos los trenes creados hasta ahora con su información correspondiente
   listarTrenes(conj_trenes);
   -- desmantelamos un tren, el que tiene menor peso acumulado de carga
   desmantelarTren(conj_trenes);
   -- volvemos a listar los trenes montados
   listarTrenes(conj_trenes);
end Trenes_Carga;
