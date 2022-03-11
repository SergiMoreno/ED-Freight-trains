--------------------------------------------------------------------------------
--                             destacion.ads                                  --
--   Estructura de datos para la gestión de trenes de carga de una estación   --
--   Autor: Sergi Moreno Pérez                                                --
--------------------------------------------------------------------------------
-- TADs utilizadas para la implementación de la estructura
with dpila;
with dcola;
with d_open_hash;
with davl;

generic
   -- Valor con el que definiremos el tamaño de la estructura hash necesitada
   size_hash : Positive;

package destacion is
   type cTrenes is limited private;

   -- EXCEPCIONES
   aparcamiento_locomotoras_completo: exception; -- no hay espacio en el parking
                                                 -- de locomotoras
   aparcamiento_vagones_completo: exception;     -- no hay espacio en el parking
                                                 -- de vagones
   locomotoras_agotadas: exception;              -- no hay locomotoras libres
   vagones_agotados: exception;                  -- no hay vagones libres
   inventario_trenes_completo: exception;        -- no hay espacio para almacenar
                                                 -- el tren
   tren_no_existe: exception;                    -- no existe el tren como montado

   -- codigo alfanumérico de 8 caracteres para identificar los vehículos de la
   -- estación
   subtype tcodigo is String(1..8);

   -- OPERACIONES
   procedure vacio(cia: out cTrenes);
   procedure aparcaLocomotora(cia: in out cTrenes; k: in tcodigo);
   procedure aparcaVagon(cia: in out cTrenes; k: in tcodigo; pmax: in Integer);
   procedure listarTrenes(cia: in cTrenes);
   procedure creaTren(cia: in out cTrenes; t: out tcodigo; num_vagones: in Integer);
   procedure consultaTren(cia: in cTrenes; t: in tcodigo);
   procedure desmantelarTren(cia: in out cTrenes);

private

   -- LOCOMOTORAS

   type locomotora;
   type plocomotora is access locomotora;
   type locomotora is record
      codigo : tcodigo;
   end record;

   -- el parking de locomotoras será una cola de locomotoras
   package aparcamiento_locomotoras is new dcola(locomotora);
   use aparcamiento_locomotoras;

   -- VAGONES

   type vagon;
   type pvagon is access vagon;
   type vagon is record
      codigo : tcodigo;
      cargaMaxima : Integer;
   end record;

   -- el parking de vagones será una pila de vagones
   package aparcamiento_vagones is new dpila(vagon);
   use aparcamiento_vagones;

   -- TRENES

   -- el tren tendrá una lista de nodos vagon, con un campo puntero al objeto
   -- vagón y con otro campo al siguiente nodo de la lista.
   type nodo_vagon;
   type pnodo_vagon is access nodo_vagon;
   type nodo_vagon is record
      vag : pvagon;
      sig : pnodo_vagon;
   end record;

   type tren;
   type ptren is access tren;
   type tren is record
      locomotora : plocomotora;
      lista_vagones : pnodo_vagon; -- puntero a la lista de nodos vagón
   end record;

   -- tendremos ordenados los trenes por peso a través de un árbol AVL con
   -- punteros a tren
   package avl_pesos is new davl(Integer,ptren,"<",">");
   use avl_pesos;

   -- Función del open hash que será implementada en el destacion.adb
   function hash (k: in tcodigo; b: in Positive) return Natural;

   -- podremos identificar el puntero a tren asociado a un identificador
   -- tcodigo mediante la estructura open hash
   package hash_codigos is new d_open_hash(tcodigo,ptren,hash,"=",size_hash);
   use hash_codigos;

   -- ESTACIÓN

   -- formada por el hashing de códigos de tren, el avl de sus pesos, la cola de
   -- locomotoras y la pila de vagones
   type cTrenes is record
      codigos_trenes : hash_codigos.conjunto;
      trenes_ordenados : avl_pesos.conjunto;
      parking_locomotoras : cola;
      parking_vagones : pila;
   end record;

end destacion;
