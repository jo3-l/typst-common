#import "deps.typ": intextual
#import intextual: eqref, flushl, flushr, intertext-rule, tag
#import "base-style.typ": base-style
#import "proof-env.typ": proof, proof-env-rules, qedhere

#let leftpad-num(n, width: none) = {
  let s = str(n)
  let pad = width - s.len()
  "0" * pad + s
}

#let plainthm(body, variant: none) = {
  figure(
    caption: none,
    gap: 0em,
    kind: "jliu/plainthm",
    supplement: variant,
    outlined: false,
  )[
    *#variant #{ context counter(figure.where(kind: "jliu/plainthm")).get().at(0) }.* _#{ body }_
  ]
}

#let proposition = plainthm.with(variant: "Proposition")
#let corollary = plainthm.with(variant: "Corollary")
#let lemma = plainthm.with(variant: "Lemma")

#let problem(..args) = {
  let pos = args.pos()
  assert(pos.len() in (1, 2))
  let (problem, body) = if pos.len() == 1 {
    ([*Problem.*], pos.at(0))
  } else {
    ([*Problem #pos.at(0).*], pos.at(1))
  }
  block(
    inset: 1em,
    below: .75em,
    fill: gray.lighten(95%),
    stroke: (left: 2pt + black),
    width: 100%,
  )[#problem #body]
}
#let solution(body, include-qed: true) = proof("Solution", body, include-qed: include-qed) // reuse proof environment

#let assignment(
  kind: "Assignment",
  num: none,
  course: none,
  section: none,
  term: none,
  doc,
) = {
  show: base-style.with(
    title: [#course #kind #num],
    ignored-equation-labels: (qedhere,), // <qedhere> is a dummy label; don't number it
  )

  set page(header: {
    set align(right)
    set text(size: 10pt)
    [#course \ Section #leftpad-num(section, width: 3), #term \ #kind #num]
    place(line(length: 100%, stroke: 0.5pt + black), dy: 6pt)
  })

  show: intertext-rule
  show: proof-env-rules
  // https://github.com/typst/typst/discussions/1409
  show figure.where(kind: "jliu/plainthm"): set align(left)
  // color references to theorems
  show ref: it => {
    if it.element.func() == figure and it.element.kind == "jliu/plainthm" {
      set text(fill: maroon)
      it
    } else {
      it
    }
  }

  doc
}
