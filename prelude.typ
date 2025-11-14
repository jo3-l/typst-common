#import "deps.typ": marginalia, zebraw
#import marginalia: note as margin-note
#import zebraw: zebraw

#let indented(body) = pad(left: 2em, top: .5em, bottom: .5em, right: 2em, body)

#let colored-math(display: true, fill: none, body) = text(fill: fill, if display { [$ #body $] } else { [$#body$] })
#let mblue = colored-math.with(fill: color.rgb("#0000FB"))
#let mred = colored-math.with(fill: color.rgb("#FF0800"))
#let mpurple = colored-math.with(fill: purple)

#let todo(note) = margin-note(numbering: none, block-style: (fill: yellow.lighten(75%), inset: 4pt, stroke: gray), {
  set text(size: 10pt)
  set par(justify: false)
  [TODO: #note]
})

#let boxed(display: true, body) = context if display {
  // Don't use $ body $; package intextual messes with display equations.
  rect($std.math.display(body)$, inset: (top: 8pt, bottom: 8pt))
} else {
  rect($#body$)
}

// dots
#let cdot = $dot.op$
#let cdots = math.class("relation", $dot thin dot thin dot$) // more spaced
#let vdots = $dots.v$
#let ddots = $dots.down$
#let vdotswithin(body) = context {
  let vdots-size = measure(vdots)
  let body-size = measure(body)
  place(
    center + horizon,
    dx: body-size.width / 2,
    dy: body-size.height / 2 - vdots-size.height / 2,
  )[#vdots]
}

// set operations
#let notin = sym.in.not
#let cap = sym.inter
#let bigcap = sym.inter.big
#let cup = sym.union
#let bigcup = sym.union.big
#let subseteq = sym.subset.eq
#let supseteq = sym.supset.eq
#let oplus = sym.plus.circle
#let setminus = sym.without

// integration and differentiation
#let dx = $dif x$
#let dy = $dif y$
#let dt = $dif t$
#let du = $dif u$
#let dv(deg: none, ..sink) = {
  let args = sink.pos()
  assert(args.len() in (1, 2))
  let (y, x) = if args.len() == 1 {
    (none, args.at(0))
  } else {
    (args.at(0), args.at(1))
  }

  if deg == none {
    $(dif#y)/(dif #x)$
  } else {
    $(dif^#deg#y)/(dif #x^#deg)$
  }
}
#let pdv(deg: none, ..sink) = {
  let args = sink.pos()
  assert(args.len() in (1, 2))
  let (y, x) = if args.len() == 1 {
    (none, args.at(0))
  } else {
    (args.at(0), args.at(1))
  }

  if deg == none {
    $(partial#y)/(partial #x)$
  } else {
    $(partial^#deg#y)/(partial #x^#deg)$
  }
}

// arrows
#let forward = [($==>$)]
#let backward = [($<==$)]
#let implies = $==>$
#let impliedby = $<==$
#let iff = $<==>$

// operators
#let cong = sym.tilde.equiv
#let sim = sym.tilde.op
#let to = sym.arrow
#let prod = sym.product
#let pm = sym.plus.minus

#let big(it) = math.lr(it, size: 125%)
#let Big(it) = math.lr(it, size: 150%)
#let smallskip = v(3pt)
#let medskip = v(6pt)
#let bigskip = v(12pt)
#let qquad = $quad quad$
