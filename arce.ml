module E = Errormsg
open Printf
open Cil
open Frontc

let rec containsDC(t:typ) : bool = (*dose this type has DC?*)
  match unrollTypeDeep t with
  | TComp(ci, _) -> (*look into subfields*)
      List.exists (fun fi -> containsDC fi.ftype) ci.cfields
  | TPtr(nt, _)       -> begin
      match unrollTypeDeep nt with
      | TFun(nnt, _, _, _) -> true
      | _                  -> false
    end
  | _                  -> false

let rec containsIC(t:typ) : bool = (*dose this type has IC?*)
  match unrollTypeDeep t with
  | TComp(ci, _) -> (*look into subfields*)
      List.exists (fun fi -> containsIC fi.ftype) ci.cfields
  | TPtr(nt, _)       -> begin
      let ut = unrollTypeDeep nt in
      match ut with
      | TComp(nnci, _)     ->
        List.exists containsDC (List.map (fun e -> e.ftype) nnci.cfields)  || List.exists containsIC (List.map (fun e -> e.ftype) nnci.cfields)
      | _                  -> containsDC ut || containsIC ut
    end
  | TArray(nt, _, _)   -> containsDC nt || containsIC nt
  | _                  -> false

let isVoidT (t:typ) = isVoidType t
let rec containsVoidPtr(t:typ) : bool = (*dose this type has <void *>?*)
  match unrollTypeDeep t with
  | TComp(ci, _) -> (*look into subfields*)
      List.exists (fun fi -> containsVoidPtr fi.ftype) ci.cfields
  | TPtr(nt, _)       -> begin
      match unrollTypeDeep nt with
      | TComp(nnci, _)     -> List.exists containsVoidPtr (List.map (fun e -> e.ftype) nnci.cfields)
      | TPtr(nnt, _)       -> isVoidT nnt || containsVoidPtr nnt
      | TArray(nnt, _, _)  -> isVoidT nnt || containsVoidPtr nnt
      | TVoid(nnt)         -> true
      | _                  -> false
    end
  | TArray(nt, _, _)  -> begin
      match unrollTypeDeep nt with
      | TComp(nnci, _)     -> List.exists containsVoidPtr (List.map (fun e -> e.ftype) nnci.cfields)
      | TPtr(nnt, _)       -> isVoidType nnt || containsVoidPtr nnt
      | TArray(nnt, _, _)  -> isVoidType nnt || containsVoidPtr nnt
      | TVoid(nnt)         -> true
      | _                  -> false
    end
  | _                    -> false

let dumpSP(vi:varinfo) =
    if containsDC vi.vtype then
          E.log "Direct Code Pointer: name=%s loc=%a\n" vi.vname d_loc vi.vdecl
    else
      if containsIC vi.vtype then
          E.log "Indirect Code Pointer: name=%s loc=%a\n" vi.vname d_loc vi.vdecl
      else
        if containsVoidPtr vi.vtype then
          E.log "void pointer: name=%s loc=%a\n" vi.vname d_loc vi.vdecl

class findSPClass : cilVisitor = object(self)
  inherit nopCilVisitor

  method vvdec(vi:varinfo) : varinfo visitAction = 
    dumpSP vi;
    DoChildren
end

let doGlobals g =
  match g with
    GFun(fi, lc)     ->
      (*E.log "\nvisit func(%s): %a\n" fi.svar.vname d_loc lc;*)
      let vf = new findSPClass in
      ignore(visitCilFunction vf fi); ()
  | GVar(vi, _, _) -> dumpSP vi
  | _ -> ()

let () =
  let argc = Array.length Sys.argv in
  if argc <> 2 then begin
    eprintf "Usage: %s <FILE>\n" Sys.argv.(0);
    exit 1
  end;
  let file = Frontc.parse Sys.argv.(1) () in
  Rmtmps.removeUnusedTemps file;
  iterGlobals file doGlobals
  (*
  ;
  ignore(E.log "\n========================\n");
  dumpFile defaultCilPrinter stdout "a.cil.c" file
  *)

(***************************************************************)
(*
let rec ptrLevel(t: typ) (l:int) = 
  let ut = unrollTypeDeep t in
  match ut with
  | TPtr(nt, _) -> ptrLevel nt l+1
  | _           -> l

let rec isFunType(t: typ) = 
  let ut = unrollTypeDeep t in
  match ut with
  | TPtr(nt, _)       -> isFunType nt
  | TFun(nt, _, _, _) -> true
  | _                 -> false

let isVoidPtr(t: typ) = isVoidPtrType t

let isDC(t:typ) =
  let l=0 in
  let pl=ptrLevel t l in
  (pl=1) && isFunType t

let isIC(t:typ) =
  let l=0 in
  let pl=ptrLevel t l in
  (pl>=2) && isFunType t

let isDCType(t:typ) =
  match unrollTypeDeep t with
  | TPtr(nt, _) -> begin
      match unrollTypeDeep nt with
      | TFun(nnt, _, _, _) -> true
      | _                  -> false
    end
  | _ -> false

let isSP(t:typ) =
  isDC t || isIC t || isVoidPtr t
*)
