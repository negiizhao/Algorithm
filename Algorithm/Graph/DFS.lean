
import Algorithm.Data.Classes.ToList
import Algorithm.Data.Graph.AdjList
import Mathlib.Data.Finset.Card
import Mathlib.Data.Fintype.Basic

namespace AdjList
variable {V : Type*} [DecidableEq V]
  {EType : Type*} [DecidableEq EType]
  {EColl : Type*} [ToList EColl EType] [Inhabited EColl]
  {StarList : Type*} [AssocArray StarList V EColl]

-- 这个实现中的 vs 大小可能和边的数量级别一样
-- 有什么办法让它既简单，也适合计算？
-- 也许在以后可以改成存迭代器，如果我们有了迭代器类型。不过看起来会更复杂些
-- 如何形式化各种使用 dfs 的算法？如 Tarjan's SCC
def dfs [Fintype V] {BoolArray : Type*} [AssocArray BoolArray V Bool]
    (g : AdjList V EType EColl StarList) (vs : List V) (visited : BoolArray) :
    BoolArray :=
  match vs with
  | [] => visited
  | v :: vs =>
    if visited[v] then
      g.dfs vs visited
    else
      g.dfs ((toList g.star[v]).map g.snd ++ vs) (AssocArray.update visited v true)
termination_by _ => ((Finset.univ.filter (fun v : V => !visited[v])).card, vs.length)
decreasing_by
  simp_wf
  first | simp [Prod.lex_iff]; done
        | apply Prod.Lex.left
          apply Finset.card_lt_card
          rw [Finset.ssubset_iff]
          refine ⟨v, by simp, ?_⟩
          rw [Finset.subset_iff]
          simp [*, Function.update]
          intro v
          split_ifs <;> simp

lemma dfs_lemma₁ {BoolArray : Type*} [AssocArray BoolArray V Bool]
    {g : AdjList V EType EColl StarList} {vs : List V} {visited : BoolArray}
    (h : ∀ v : V, visited[v] → ∀ e ∈ g.star[v], visited[g.snd e] ∨ g.snd e ∈ vs)
    {u v : g.Quiver} (hu : visited[g.ofQuiver u]) (p : Quiver.Path u v) :
    visited[g.ofQuiver v] = true ∨ ∃ u ∈ vs, Nonempty (Quiver.Path (g.toQuiver u) v) := by
  induction p with
  | nil => exact .inl hu
  | cons _ e ih =>
    obtain h := e
    obtain (ih | ⟨u, hu, ⟨p⟩⟩) := ih
    · obtain (h | h) := h _ ih (g.ofHom e).val (by convert (g.ofHom e).mem_star; simp)
      · simp only [E.snd_val, ofHom_snd] at h
        exact .inl h
      · refine .inr ⟨_, h, ⟨?_⟩⟩
        simp only [E.snd_val, ofHom_snd, toQuiver_ofQuiver]
        exact .nil
    · exact .inr ⟨u, hu, ⟨p.cons e⟩⟩
