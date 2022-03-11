generic
   type elem is private; -- generico
package dpila is
   type pila is limited private; -- evitas asignacion y comparacion de igualdad/desigualdad

   mal_uso: exception;
   espacio_desbordado: exception; --overflow

   procedure pvacia(p: out pila);
   procedure empila(p: in out pila; x: in elem);
   procedure desempila(p: in out pila);
   function cima(p: in pila) return elem;
   function estavacia(p: in pila) return boolean;
private
   type nodo;
   type pnodo is access nodo;
   type nodo is record
      x: elem;
      sig: pnodo;
   end record;

   type pila is record
      top: pnodo;
   end record;

end dpila;
