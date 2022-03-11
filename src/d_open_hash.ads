generic
   type key is private;
   type item is private;
   with function hash(k: in key; b: in positive) return natural;
   with function "=" (k1: in key; k2: in key) return boolean;
   size: positive; -- número primo
package d_open_hash is
   -- igual que mapping
   type conjunto is limited private;
   ya_existe: exception;
   no_existe: exception;
   espacio_desbordado: exception;

   procedure cvacio(s: out conjunto);
   procedure poner(s: in out conjunto; k: in key; x: in item);
   procedure consultar(s: in conjunto; k: in key; x: out item);
   procedure borrar(s: in out conjunto; k: in key);
   procedure actualiza(s: in out conjunto; k: in key; x: in item);
private
   b: constant natural := size;
   type nodo;
   type pnodo is access nodo;
   type nodo is record
      k: key;
      x: item;
      sig: pnodo;
   end record;

   type dispersion_table is array(natural range 0..b-1) of pnodo;
   type conjunto is record
      dt: dispersion_table;
   end record;

end d_open_hash;
