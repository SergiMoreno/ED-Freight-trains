package body d_open_hash is

   procedure cvacio(s: out conjunto) is
      dt: dispersion_table renames s.dt;
   begin
      for i in 0..b-1 loop
         dt(i):=null;
      end loop;
   end cvacio;

   procedure poner(s: in out conjunto; k: in key; x: in item) is
      dt: dispersion_table renames s.dt;
      i: natural;
      p: pnodo;
   begin
      i:=hash(k, b); p:=dt(i);
      -- recorrer la lista que sea diferente de null
      -- y no encontrar la llave
      while p/=null and then p.k/=k loop
         p:=p.sig;
      end loop;
      if p/=null then raise ya_existe; end if;
      p:= new nodo; -- crear celda
      p.all := (k,x,null); -- llenar celda
      p.sig := dt(i); dt(i):=p; -- insertar al principio de la lista
   exception
         when Storage_Error => raise espacio_desbordado;
   end poner;

   procedure consultar(s: in conjunto; k: in key; x: out item) is
      dt: dispersion_table renames s.dt;
      i: natural;
      p: pnodo;
   begin
      i:= hash(k, b); p:=dt(i);
      while p/=null and then p.k/=k loop
         p:=p.sig;
      end loop;
      if p=null then raise no_existe; end if;
      x := p.x;
   end consultar;

   procedure actualiza(s: in out conjunto; k: in key; x: in item) is
      dt: dispersion_table renames s.dt;
      i: natural;
      p: pnodo;
   begin
      i:= hash(k, b); p:=dt(i);
      while p/=null and then p.k/=k loop
         p:=p.sig;
      end loop;
      if p=null then raise no_existe; end if;
      p.x := x;
   end actualiza;

   procedure borrar(s: in out conjunto; k: in key) is
      dt: dispersion_table renames s.dt;
      i: Natural;
      p, pp: pnodo;
   begin
      i:=hash(k, b); p:=dt(i); pp:=null;
      while p/=null and then p.k/=k loop
         pp:=p; p:=p.sig;
      end loop;
      if p=null then raise no_existe; end if;
      if pp=null then dt(i):=p.sig; -- principio lista
      else pp.sig := p.sig;
      end if;
   end borrar;


end d_open_hash;
