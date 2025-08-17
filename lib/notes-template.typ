#import "@preview/outrageous:0.4.0" as outrageous
#import "@preview/marginalia:0.2.0": note as margin-note
#import "@preview/thmbox:0.2.0": sectioned-counter, thmbox, thmbox-init

#import "base-style.typ": base-style
#import "proof-env.typ": proof, proof-env-rules, qedhere

// inline commentary (eg to motivate a proof)
#let note(body) = {
  text(fill: gray.darken(10%), font: "Noto Sans", size: 10pt, style: "italic")[#body]
}

// for midterm content cutoff etc
#let custom-marker(color: none, body) = {
  place(line(length: 100%, stroke: 1pt + color))
  divider-line(color: color)
  margin-note(numbering: none, text-style: (font: "Noto Sans", fill: color))[
    #set align(center)
    #body
  ]
}

// theorem boxes
#let base-counter = counter("jliu/thm-base-counter")

#let basebox(..args) = {
  // HACK: override font weight of title
  let pos = args.pos()
  assert(pos.len() in (1, 2))
  let (title, body) = if pos.len() == 1 {
    (none, pos.at(0))
  } else {
    (pos.at(0), pos.at(1))
  }

  thmbox(
    title-fonts: "Noto Sans",
    bar-thickness: 2pt,
    counter: base-counter,
    sans: false,
    ..args.named(),
    text(weight: "regular", title),
    body,
  )
}

#let sienna = color.rgb("#882D17")
#let salmon = color.rgb("#FA8072")
#let redbox = basebox.with(color: sienna, fill: salmon.lighten(95%))

#let red-violet = color.rgb("#C71585")
#let blackbox = basebox.with(color: black, fill: red-violet.lighten(95%).mix(gray.lighten(99%)))

#let midnight-blue = color.rgb("#191970")
#let bluebox = basebox.with(color: midnight-blue, fill: midnight-blue.lighten(95%))

#let greenbox = basebox.with(color: green.darken(50%), fill: green.lighten(95%))

#let theorem = greenbox.with(variant: "Theorem")
#let proposition = greenbox.with(variant: "Proposition")
#let corollary = greenbox.with(variant: "Corollary")
#let lemma = greenbox.with(variant: "Lemma")
#let definition = redbox.with(variant: "Definition")
#let example = blackbox.with(variant: "Example")
#let remark = bluebox.with(variant: "Remark", numbering: none)

// lecture tracking
#let lecture-num = counter("jliu/lecture-num")
#let last-lecture-end-page = state("jliu/last-lecture-end-page", 0)

#let lecture(num: auto, date: none) = {
  if num != auto {
    lecture-num.update(num)
  }

  context [
    #metadata((
      kind: "start",
      lec: lecture-num.get().at(0),
      date: date.display("[month repr:short] [day]"),
      page: here().page(),
    )) <lecture-marker>
  ]

  place(line(length: 100% + 5pt, stroke: 1pt + gray.darken(25%)))
  margin-note(numbering: none, dy: -5pt)[
    #set align(center)
    #set text(font: "Noto Sans", size: 10pt, fill: gray.darken(50%))
    #figure(
      text(weight: "semibold")[Lecture #context lecture-num.display()],
      kind: "lecture",
      supplement: none,
      caption: date.display("[month repr:short] [day]"),
    )
  ]
  lecture-num.step()
}

#let end-lecture() = context {
  [ #metadata((kind: "end", page: here().page())) <lecture-marker> ]
  last-lecture-end-page.update(here().page())
}

#let query-lecture-at-page(current-page) = {
  if current-page > last-lecture-end-page.final() {
    return none
  }

  let all-markers = query(figure.where(kind: "lecture"))
  let select-markers-by-page(accept) = {
    all-markers.filter(marker => {
      let marker-page = counter(page).at(marker.location()).first()
      accept(marker-page)
    })
  }

  let markers-on-page = select-markers-by-page(page => page == current-page)
  if markers-on-page.len() > 0 {
    let first-marker-loc = markers-on-page.first().location()
    if first-marker-loc.position().y < page.height / 3 {
      return lecture-num.at(first-marker-loc).first()
    }
  }

  let markers-before-page = select-markers-by-page(page => page < current-page)
  if markers-before-page.len() > 0 {
    return lecture-num.at(markers-before-page.last().location()).first()
  }
  return none
}

#let notes(
  course: none,
  author: none,
  term: none,
  doc,
) = {
  show: base-style.with(
    title: [#course Course Notes (#term)],
    author: author,
    ignored-equation-labels: (qedhere,), // <qedhere> is a dummy label; don't number it
  )

  let first-content-page = state("jliu/content-start-page", 0)
  // show lecture number in header
  set page(header: context {
    let current-page = here().page()
    if current-page < first-content-page.final() {
      return none
    }

    let lecture = query-lecture-at-page(current-page)
    set align(right)
    set text(size: 10pt)
    if lecture != none {
      [#course (#term) \ Lecture #lecture]
    } else {
      [#course (#term)]
    }
  })

  show: proof-env-rules

  show: thmbox-init()
  show: sectioned-counter(base-counter, level: 3)
  // color references to theorems
  show ref: it => {
    if it.element.func() == figure and it.element.kind == "thmbox" {
      set text(fill: maroon)
      it
    } else {
      it
    }
  }

  // title
  {
    set text(font: "Noto Sans")
    set align(center)

    text(size: 16pt)[#course Course Notes]
    v(4pt)
    author
    v(2pt)
    term
  }

  // table of contents
  {
    show outline.entry: outrageous.show-entry
    show outline.entry: set block(below: .8em)
    show outline.entry.where(level: 1): set block(below: 1em)
    heading(numbering: none, outlined: false)[
      Contents
    ]
    v(.5em)
    outline(title: none)

    v(1em)
  }

  // list of lectures

  // associate lecture numbers with marker figures so outline numbers are correct
  show figure.where(kind: "lecture"): set figure(numbering: (..) => lecture-num.get().first())
  {
    show outline.entry: outrageous.show-entry.with(
      ..outrageous.presets.outrageous-toc,
      font-weight: ("semibold", auto),
      fill: (align(right, repeat(gap: 6pt)[.]), auto),
    )

    heading(numbering: none, outlined: false)[
      Lectures
    ]
    v(.5em)
    outline(title: none, target: figure.where(kind: "lecture"))
  }
  pagebreak()

  lecture-num.update(1)
  context first-content-page.update(here().page())
  doc
}
