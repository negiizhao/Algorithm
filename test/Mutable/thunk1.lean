import Algorithm.Data.Mutable

universe u

def Thunk' (α : Type u) : Type u := Mutable (Unit → α)

variable {α : Type u}

def Thunk'.mk (fn : Unit → α) : Thunk' α := Mutable.mk fn

protected def Thunk'.pure (a : α) : Thunk' α :=
  .mk fun _ ↦ a

protected def Thunk'.get (x : Thunk' α) : α :=
  Mutable.getWith₂ x (fun f ↦ f ()) (fun a _ ↦ a) (fun _ ↦ rfl)

/-! lean4/tests/lean/thunk.lean -/

#eval (Thunk.pure 1).get
#eval (Thunk.mk fun _ => 2).get
#eval
  let t1 := Thunk.mk fun _ => dbg_trace 4; 5
  let t2 := Thunk.mk fun _ => dbg_trace 3; 0
  let v2 := t2.get
  let v1 := t1.get
  v1 + v2
#eval
  let t1 := Thunk.pure 8 |>.map fun n => dbg_trace 7; n
  let t2 := Thunk.mk fun _ => dbg_trace 6; 0
  let v2 := t2.get
  let v1 := t1.get
  v1 + v2
#eval
  let t1 := Thunk.pure 11 |>.bind fun n => dbg_trace 10; Thunk.pure n
  let t2 := Thunk.mk fun _ => dbg_trace 9; 0
  let v2 := t2.get
  let v1 := t1.get
  v1 + v2
