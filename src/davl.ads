with dpila;

generic
   type key is private;
   type item is private;
   with function "<" (k1, k2: in key) return boolean;
   with function ">" (k1, k2: in key) return boolean;

package davl is
   type conjunto is limited private;

   espacio_desbordado: exception;
   ya_existe: exception;
   no_existe: exception;

   procedure cvacio (s: out conjunto);
   procedure poner (s: in out conjunto; k: in key; x: in item);
   procedure consultar (s: in conjunto; k:in key; x: out item);
   procedure borrar (s: in out conjunto; k: in key);
   procedure actualiza (s: in out conjunto; k: in key; x: in item);

   -- Iterator
   type iterator is limited private;
   bad_use: exception;

   procedure first (s: in conjunto; it: out iterator);
   procedure next (s: in conjunto; it: in out iterator);
   function is_valid (it: in iterator) return boolean;
   procedure get(s: in conjunto; it: in iterator; k: out key; x: out item);

private
   type nodo;
   type pnodo is access nodo;

   type factor_balanceo is new integer range -1..1;

   type nodo is record
      k: key;
      x: item;
      bl: factor_balanceo;
      lc, rc: pnodo;
   end record;

   type conjunto is record
      raiz: pnodo;
   end record;

   package dnodestack is new dpila(pnodo);
   use dnodestack;

   type iterator is
      record
         st: pila;
      end record;

end davl;
