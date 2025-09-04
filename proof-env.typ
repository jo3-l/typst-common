#let qed-symbol = $square.stroked$

#let proof-has-qed-stack = state("jliu/proof-has-qed", ())
#let display-qed-symbol() = {
  box(height: 0.65em, qed-symbol)
  proof-has-qed-stack.update(prev => (..prev.slice(0, -1), true))
}

#let qedhere = <qedhere>

#let proof(..args) = {
  let pos = args.pos()
  assert(pos.len() in (1, 2))
  let (title, body) = if pos.len() == 1 {
    ("Proof", pos.at(0))
  } else {
    (pos.at(0), pos.at(1))
  }

  [
    #set text(style: "italic")
    #title.
  ]
  {
    proof-has-qed-stack.update(prev => (..prev, false))
    body
    context if not proof-has-qed-stack.get().last() {
      h(1fr)
      display-qed-symbol()
    }
    proof-has-qed-stack.update(prev => prev.slice(0, -1))
  }
}

#let proof-env-rules(doc) = {
  // display qedhere
  show math.equation: eq => {
    if eq.numbering == none and eq.has("label") and eq.label == qedhere {
      math.equation(
        block: eq.block,
        numbering: (..) => display-qed-symbol(),
        number-align: bottom,
        supplement: eq.supplement,
        eq.body,
      )
    } else {
      eq
    }
  }
  show enum.item: it => {
    show qedhere: orig => {
      if not proof-has-qed-stack.at(orig.location()).last() {
        orig
        h(1fr)
        display-qed-symbol()
      } else {
        orig
      }
    }
    it
  }
  show list.item: it => {
    show qedhere: orig => {
      if not proof-has-qed-stack.at(orig.location()).last() {
        orig
        h(1fr)
        display-qed-symbol()
      } else {
        orig
      }
    }
    it
  }

  doc
}
