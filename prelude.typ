#import "deps.typ": marginalia, zebraw
#import marginalia: note as margin-note
#import zebraw: zebraw

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
#let notin = $in.not$
#let cap = $inter$
#let bigcap = $inter.big$
#let cup = $union$
#let bigcup = $union.big$
#let subseteq = $subset.eq$
#let supseteq = $supset.eq$
#let oplus = $plus.circle$
#let setminus = $without$

// integration and differentiation
#let int = $integral$
#let dx = $dif x$
#let dy = $dif y$
#let dt = $dif t$
#let du = $dif u$
#let dv = $dif v$
#let deriv(deg: none, ..sink) = {
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

// arrows
#let forward = [($==>$)]
#let backward = [($<==$)]
#let implies = $==>$
#let impliedby = $<==$
#let iff = $<==>$

// operators
#let cong = $tilde.equiv$
#let sim = $tilde.op$
#let to = $arrow$
#let prod = $product$
#let pm = $plus.minus$

#let big(it) = math.lr(it, size: 125%)
#let Big(it) = math.lr(it, size: 150%)
#let smallskip = v(3pt)
#let medskip = v(6pt)
#let bigskip = v(12pt)
