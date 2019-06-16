# Set your path to CIL's object directory here (the one containing cil.cmxa):
SRC = arce
CIL = $(PWD)/../cil
CIL_BLD = $(CIL)/_build

all: clean $(SRC)

$(SRC): $(SRC).cmx
	ocamlopt.opt unix.cmxa str.cmxa nums.cmxa $(CIL_BLD)/src/cil.cmxa $^ -o $@

$(SRC).cmx: $(SRC).ml
	ocamldep.opt -modules $(SRC).ml > $(SRC).ml.depends
	ocamlopt.opt -c -g -I $(CIL_BLD)/src -I $(CIL_BLD)/ocamlutil -I $(CIL_BLD)/src/frontc -I $(CIL_BLD)/src/ext -I $(CIL_BLD)/src/ext/pta -o $(SRC).cmo $^
	ocamlopt.opt -c -I $(CIL_BLD)/src -I $(CIL_BLD)/ocamlutil -I $(CIL_BLD)/src/frontc -I $(CIL_BLD)/src/ext -I $(CIL_BLD)/src/ext/pta -o $(SRC).cmx $^

test:
	./arce tests/arce.c
clean:
	-rm -f $(SRC) $(SRC).cm[ix] $(SRC).o $(SRC).mli
	-rm -f *.o *.cmo *.cmx *.cma *.cmxa *.depends *.log
