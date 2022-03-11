with Ada.Text_IO; use Ada.Text_IO;
with Ada.Containers; use Ada.Containers;
with Ada.Strings.Hash;

package body destacion is

   -- Función para el open hash
   function hash(k: in tcodigo; b: in Positive) return natural is
      final: Hash_Type;
      maxim: constant Ada.Containers.Hash_Type:= Ada.Containers.Hash_Type(b);
   begin
      final:= Ada.Strings.Hash(String(k)) mod maxim;
      return natural(final);
   end hash;

   -- Prepara la estructura de la compañía de trenes para trabajar con ella
   -- vacíamos todas las estructuras que la conforman
   procedure vacio(cia: out cTrenes) is
   begin
      cvacio(cia.codigos_trenes);
      cvacio(cia.trenes_ordenados);
      pvacia(cia.parking_vagones);
      cvacia(cia.parking_locomotoras);
   end vacio;

   -- Da de alta una nueva locomotora y la aparca en el aparcamiento
   -- de locomotoras libres
   procedure aparcaLocomotora(cia: in out cTrenes; k: in tcodigo) is
      nueva_locomotora : locomotora;
   begin
      nueva_locomotora.codigo := k;
      poner(cia.parking_locomotoras,nueva_locomotora);
   exception
         when aparcamiento_locomotoras.espacio_desbordado => raise aparcamiento_locomotoras_completo;
   end aparcaLocomotora;

   -- Da de alta un nuevo vagón y lo aparca en el aparcamiento de vagones libres
   procedure aparcaVagon(cia: in out cTrenes; k: in tcodigo; pmax: in Integer) is
      nuevo_vagon : vagon;
   begin
      nuevo_vagon.codigo := k;
      nuevo_vagon.cargaMaxima := pmax;
      empila(cia.parking_vagones,nuevo_vagon);
   exception
         when aparcamiento_vagones.espacio_desbordado => raise aparcamiento_vagones_completo;
   end aparcaVagon;

   -- Lista la información de todos los trenes que se encuentran montados
   -- ordenados por su peso máximo de carga acumulado
   procedure listarTrenes(cia: in cTrenes) is
      tren_iterado : ptren;
      cod_tren, cod_loc : tcodigo;
      peso : Positive;
      it_tren : iterator;
      cont_vagones, cont_trenes : Positive;
      p_aux : pnodo_vagon;
   begin
      first(cia.trenes_ordenados,it_tren);
      New_Line;
      Put_Line("******** Lista de trenes montados ********");
      New_Line;
      cont_trenes := 1;
      -- iteración de trenes
      while is_valid(it_tren) loop
         get(cia.trenes_ordenados,it_tren,peso,tren_iterado);

         cod_loc := tren_iterado.locomotora.codigo;
         -- a partir del código de la locomotora del tren, podemos obtener el
         -- propio código del tren
         cod_tren := cod_loc;
         cod_tren(1) := 'T';
         Put_Line("Código tren" & Integer'Image(cont_trenes) & ":     " & cod_tren & "  Peso tren: " & Integer'Image(peso));
         Put_Line("Código locomotora: " & cod_loc);

         p_aux := tren_iterado.lista_vagones;
         cont_vagones := 1;
         -- listado de vagones del tren iterado
         while p_aux /= null loop
            Put_Line("Código vagón" & Integer'Image(cont_vagones) & ":    " & p_aux.vag.codigo & "  Peso vagón:" & Integer'Image(p_aux.vag.cargaMaxima));
            cont_vagones := cont_vagones + 1;
            p_aux := p_aux.sig;
         end loop;
         Put_Line("-----------------------------------------------");
         next(cia.trenes_ordenados,it_tren);
         cont_trenes := cont_trenes + 1;
      end loop;
      New_Line;
   end listarTrenes;

   -- Crear un nuevo tren a partir de una locomotora libre y el número
   -- indicado de vagones (de entre los vagones libres aparcados)
   procedure creaTren(cia: in out cTrenes; t: out tcodigo; num_vagones: in Integer) is
      p_tren : ptren;
      pesoTren : Integer;
      plista : pnodo_vagon;
   begin
      p_tren := new tren;

      p_tren.locomotora := new locomotora;
      -- sacamos la primera locomotora del parking
      p_tren.locomotora.all := coger_primero(cia.parking_locomotoras);
      borrar_primero(cia.parking_locomotoras);

      pesoTren := 0;
      -- Bucle en el que añadiremos justo detrás de la locomotora los vagones
      for i in 1..num_vagones loop
         plista := new nodo_vagon;

         plista.vag := new vagon;
         -- sacamos el vagón más alejado de la pared
         plista.vag.all := cima(cia.parking_vagones);
         desempila(cia.parking_vagones);
         pesoTren := pesoTren + plista.vag.cargaMaxima;

         -- añadimos el vagón a la lista
         plista.sig := p_tren.lista_vagones;
         p_tren.lista_vagones := plista;
      end loop;
      -- a partir del código de la locomotora, generamos el código del tren
      t := p_tren.locomotora.codigo;
      t(1) := 'T';
      -- añadimos el puntero al tren creado al hashing y al avl
      poner(cia.codigos_trenes,t,p_tren);
      poner(cia.trenes_ordenados,pesoTren,p_tren);
   exception
         when aparcamiento_locomotoras.mal_uso => raise locomotoras_agotadas;
         when aparcamiento_vagones.mal_uso => raise vagones_agotados;
         when hash_codigos.espacio_desbordado => raise inventario_trenes_completo;
   end creaTren;

   -- Mostrar toda la información correspondiente al tren de código pasado por
   -- parámetro
   procedure consultaTren(cia: in cTrenes; t: in tcodigo) is
      consulta_tren : ptren;
      cont_vagones : Positive := 1;
      p_aux : pnodo_vagon;
   begin
      -- apuntamos al tren que queremos consultar
      consultar(cia.codigos_trenes,t,consulta_tren);
      Put_Line("****** Consulta tren ******");
      Put_Line("Código tren:       " & t);
      Put_Line("Código locomotora: " & consulta_tren.locomotora.codigo);

      -- Bucle para mostrar la información de los vagones del tren
      p_aux := consulta_tren.lista_vagones;
      while p_aux /= null loop
            Put_Line("Código vagón " & Integer'Image(cont_vagones) & ":   " & p_aux.vag.codigo & " Peso vagón: " & Integer'Image(p_aux.vag.cargaMaxima));
            cont_vagones := cont_vagones + 1;
            p_aux := p_aux.sig;
      end loop;
      Put_Line("-----------------------------------------------");
      New_Line;
   exception
         when hash_codigos.no_existe => raise tren_no_existe;
   end consultaTren;

   -- Desmantela un tren con el menor peso de carga máxima acumulada, eliminando
   -- los datos relacionades a él de todas las estructuras
   procedure desmantelarTren(cia: in out cTrenes) is
      peso_tren : Integer;
      tren_borrado : ptren;
      cod_tren : tcodigo;
      it_tren : iterator;
      p_aux : pnodo_vagon;
   begin
      -- seleccionamos el tren montado de menor peso que encontramos en el avl
      first(cia.trenes_ordenados,it_tren);
      if is_valid(it_tren) then
         get(cia.trenes_ordenados,it_tren,peso_tren,tren_borrado);

         p_aux := tren_borrado.lista_vagones;
         -- aparcamos todos los vagones de nuevo en su aparcamiento
         while p_aux /= null loop
            aparcaVagon(cia,p_aux.vag.codigo,p_aux.vag.cargaMaxima);
            p_aux := p_aux.sig;
         end loop;
         -- aparcamos la locomotora
         aparcaLocomotora(cia,tren_borrado.locomotora.codigo);

         cod_tren := tren_borrado.locomotora.codigo;
         cod_tren(1) := 'T';
         -- borramos todo puntero al tren creado
         borrar(cia.trenes_ordenados,peso_tren);
         borrar(cia.codigos_trenes,cod_tren);
      end if;
   exception
      when avl_pesos.bad_use => raise tren_no_existe;
      when aparcamiento_vagones.espacio_desbordado => raise aparcamiento_vagones_completo;
      when aparcamiento_locomotoras.espacio_desbordado => raise aparcamiento_locomotoras_completo;
   end desmantelarTren;

end destacion;
