
package body davl is
   type modo is (insert_mode, remove_mode);

   procedure cvacio (s: out conjunto) is
      raiz: pnodo renames s.raiz;
   begin
      raiz := null;
   end cvacio;

   procedure consultar (s: in pnodo; k: in key; x: out item) is
   begin
      if s= null then
         raise no_existe;
      else
         if k<s.k then consultar(s.lc, k, x);
         elsif k>s.k then consultar(s.rc, k, x);
         else
            x:= s.x;
         end if;
      end if;
   end consultar;

   procedure consultar (s: in conjunto; k: in key; x: out item) is
      raiz: pnodo renames s.raiz;
   begin
      consultar(raiz, k, x);
   end consultar;

   procedure actualiza (s: in out pnodo; k: in key; x: in item) is
   begin
      if s= null then
         raise no_existe;
      else
         if k<s.k then actualiza(s.lc, k, x);
         elsif k>s.k then actualiza(s.rc, k, x);
         else
            s.x:= x;
         end if;
      end if;
   end actualiza;

   procedure actualiza (s: in out conjunto; k: in key; x: in item) is
      raiz: pnodo renames s.raiz;
   begin
      actualiza(raiz, k, x);
   end actualiza;

   procedure rebalanceo_izq(p: in out pnodo; h: out Boolean; m: in modo) is
      a: pnodo;
      b: pnodo;
      c, b2: pnodo;
      c1, c2: pnodo;
   begin
      a := p; b := a.lc;
      if b.bl <= 0 then
         b2 := b.rc;
         a.lc := b2; b.rc := a; p:= b;
         if b.bl = 0 then
            a.bl := -1; b.bl := 1;
            if m = remove_mode then h:= false; end if;
         else
            a.bl := 0; b.bl := 0;
            if m = insert_mode then h:= false; end if;
         end if;
      else
         c := b.rc; c1 := c.lc; c2 := c.rc;
         b.rc := c1; a.lc :=c2; c.lc := b; c.rc := a; p := c;
         if c.bl <= 0 then b.bl := 0; else b.bl := -1; end if;
         if c.bl >= 0 then a.bl := 0; else a.bl := 1; end if;
         c.bl := 0;
         if m=insert_mode then h:= false; end if;
      end if;
   end rebalanceo_izq;

   procedure rebalanceo_der (p: in out pnodo; h: out Boolean; m: in modo) is
      a: pnodo;
      b: pnodo;
      c, b2: pnodo;
      c1, c2: pnodo;
   begin
      a := p; b := a.rc;
      if b.bl >= 0 then
         b2 := b.lc;
         a.rc := b2; b.lc := a; p:= b;
         if b.bl = 0 then
            a.bl := 1; b.bl := -1;
            if m = remove_mode then h:= false; end if;
         else
            a.bl := 0; b.bl := 0;
            if m = insert_mode then h:= false; end if;
         end if;
      else
         c := b.lc; c1 := c.rc; c2 := c.lc;
         b.lc := c1; a.rc :=c2; c.lc := a; c.rc := b; p := c;
         if c.bl <= 0 then a.bl := 0; else a.bl := -1; end if;
         if c.bl >= 0 then b.bl := 0; else b.bl := 1; end if;
         c.bl := 0;
         if m=insert_mode then h:= false; end if;
      end if;
   end rebalanceo_der;


   procedure balanceo_izq(p: in out pnodo; h: in out Boolean; m: in modo) is
   begin
      if p.bl = 1 then
         p.bl := 0;
         if m=insert_mode then h:= false; end if;
      elsif p.bl=0 then
         p.bl := -1;
         if m=remove_mode then h:= false; end if;
      else
         rebalanceo_izq(p, h, m);
      end if;
   end balanceo_izq;

   procedure balanceo_der(p: in out pnodo; h: in out Boolean; m: in modo) is
   begin
      if p.bl = -1 then
         p.bl := 0;
         if m=insert_mode then h:= false; end if;
      elsif p.bl=0 then
         p.bl := 1;
         if m=remove_mode then h:= false; end if;
      else
         rebalanceo_der(p, h, m);
      end if;
   end balanceo_der;


   procedure poner (p: in out pnodo; k: in key; x: in item; h: out boolean) is
   begin
      if p=null then
         p:= new nodo; p.all := (k, x, 0, null, null);
         h := true;
      else
         if k<p.k then
            poner(p.lc, k, x, h);
            if h then balanceo_izq (p, h, insert_mode); end if;
         elsif k>p.k then
            poner(p.rc, k, x, h);
            if h then balanceo_der(p, h, insert_mode); end if;
         else
            -- k=p.k
            raise ya_existe;
         end if;
      end if;
   exception
         when Storage_Error => raise espacio_desbordado;
   end poner;

   procedure poner (s: in out conjunto; k: in key; x: in item) is
      raiz: pnodo renames s.raiz;
      h: Boolean;
   begin
      poner(raiz, k, x, h);
   end poner;

   procedure borrado_masbajo(p: in out pnodo; pmasbajo: out pnodo; h: out boolean) is
      -- prec: p/=null
   begin
      if p.lc/=null then borrado_masbajo(p.lc, pmasbajo, h);
         if h then balanceo_der(p, h, remove_mode); end if;
      else pmasbajo := p; p:=p.rc; h := true;
      end if;
   end borrado_masbajo;

   procedure borrado_real (p: in out pnodo; h: out boolean) is
      pmasbajo: pnodo;
   begin
      if p.lc = null and p.rc = null then
         p := null; h := true;
      elsif p.lc = null and p.rc /= null then
         p := p.rc; h := true;
      elsif p.lc /= null and p.rc = null then
         p := p.lc; h := true;
      else
         borrado_masbajo(p.rc, pmasbajo, h);
         pmasbajo.lc := p.lc; pmasbajo.rc := p.rc; pmasbajo.bl := p.bl;
         p := pmasbajo;
         if h then balanceo_izq(p, h, remove_mode); end if;
      end if;
   end borrado_real;

   procedure borrar (p: in out pnodo; k: in key; h: out Boolean) is
   begin
      if p=null then raise no_existe; end if;
      if k<p.k then
         borrar(p.lc, k, h);
         if h then balanceo_der(p, h, remove_mode); end if;
      elsif k>p.k then
         borrar(p.rc, k, h);
         if h then balanceo_izq(p, h, remove_mode); end if;
      else
         borrado_real(p, h);
      end if;
   end borrar;

   procedure borrar (s: in out conjunto; k: in key) is
      raiz: pnodo renames s.raiz;
      h: Boolean;
   begin
      borrar(raiz, k, h);
   end borrar;

   procedure first(s: in conjunto; it: out iterator) is
      raiz: pnodo renames s.raiz;
      st: pila renames it.st;
      p: pnodo;
   begin
      pvacia(st);
      if raiz/= null then
         p:= raiz;
         while p.lc /= null loop
            empila(st, p); p:= p.lc;
         end loop;
         empila(st, p);
      end if;
   end first;

   procedure next (s: in conjunto; it: in out iterator) is
      st: pila renames it.st;
      p: pnodo;
   begin
      p:= cima(st); desempila(st);
      if p.rc /= null then
         p:=p.rc;
         while p.lc /= null loop
            empila(st, p); p:=p.lc;
         end loop;
         empila(st,p);
      end if;
   exception
         when dnodestack.mal_uso => raise davl.bad_use;
   end next;

   function is_valid (it: in iterator) return boolean is
      st: pila renames it.st;
   begin
      return not estavacia(st);
   end is_valid;

   procedure get(s: in conjunto; it: in iterator; k: out key; x: out item) is
      st: pila renames it.st;
      p: pnodo;
   begin
      p:= cima(st);
      k:=p.k; x := p.x;
   end get;

end davl;
