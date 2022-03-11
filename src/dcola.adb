package body dcola is
   procedure cvacia(qu: out cola) is
      p: pnodo renames qu.p;
      q: pnodo renames qu.q;
   begin
      p := null; q := null;
   end cvacia;

   function esta_vacia(qu: in cola) return Boolean is
      q: pnodo renames qu.q;
   begin
      return q=null;
   end esta_vacia;

   function coger_primero(qu: in cola) return elem is
      q: pnodo renames qu.q;
   begin
      return q.x;
   exception
      when Constraint_Error => raise mal_uso;
   end coger_primero;

   procedure poner(qu: in out cola; x: in elem) is
      p: pnodo renames qu.p;
      q: pnodo renames qu.q;
      r: pnodo;
   begin
      r := new nodo;
      r.all := (x, null);
      if p = null then -- la cola esta vacia
         p := r; q := r;
      else
         p.sig := r; p := r;
      end if;
   exception
      when Storage_Error => raise espacio_desbordado;
   end poner;

   procedure borrar_primero(qu: in out cola) is
      p: pnodo renames qu.p;
      q: pnodo renames qu.q;
   begin
      q := q.sig;
      if q=null then p:=null; end if;
   exception
      when Constraint_Error => raise mal_uso;
   end borrar_primero;

   function is_last_item (qu: in cola) return boolean is
      q: pnodo renames qu.q;
   begin
      return q/=null and then q.sig=null;
   end is_last_item;

end dcola;
