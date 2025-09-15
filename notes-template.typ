#import "deps.typ": intextual, marginalia, outrageous, thmbox
#import intextual: eqref, flushl, flushr, intertext-rule, tag
#import marginalia: note as margin-note
#import thmbox: sectioned-counter, thmbox, thmbox-init

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

#let breakable-thmbox(body) = {
  show figure: set block(breakable: true)
  body
}

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

#let yellowbox = basebox.with(color: orange.darken(40%), fill: yellow.lighten(95%))

#let theorem = greenbox.with(variant: "Theorem")
#let proposition = greenbox.with(variant: "Proposition")
#let corollary = greenbox.with(variant: "Corollary")
#let lemma = greenbox.with(variant: "Lemma")
#let definition = redbox.with(variant: "Definition")
#let example = blackbox.with(variant: "Example")
#let remark = bluebox.with(variant: "Remark", numbering: none)
#let tip = yellowbox.with(variant: "Tip", numbering: none)

// lecture/tutorial tracking
#let lecture-num = counter("jliu/lecture-num")
#let tutorial-num = counter("jliu/tutorial-num")
#let last-content-page = state("jliu/last-lecture-end-page", 0)

// session: either a lecture or a tutorial
#let session(num: auto, date: none, name: none, counter: none) = {
  if num != auto {
    counter.update(num)
  }

  context {
    let date-display = date.display("[month repr:short] [day]")

    [ #metadata([#name #counter.display()]) <session-marker> ]
    place(line(length: 100% + 5pt, stroke: 1pt + gray.darken(25%)))
    margin-note(numbering: none, dy: -5pt)[
      #show figure.caption: (..) => none // hide caption; only used for outline
      #set align(center)
      #set text(font: "Noto Sans", size: 10pt, fill: gray.darken(50%))
      #figure(
        [#text(weight: "semibold")[#name #counter.display()] \ #date.display("[month repr:short] [day padding:none]")],
        kind: "session",
        supplement: none,
        caption: [#set text(weight: "semibold")
          #name #counter.display() --- #date.display("[weekday] [month repr:short] [day padding:none]")],
      )
    ]
  }
  counter.step()
}

#let lecture = session.with(name: "Lecture", counter: lecture-num)
#let tutorial = session.with(name: "Tutorial", counter: tutorial-num)

#let end-session() = context {
  last-content-page.update(here().page())
}
#let end-lecture = end-session
#let end-tutorial = end-session

#let query-lecture-or-tutorial-at-page(current-page) = {
  if current-page > last-content-page.final() {
    return none
  }

  let all-markers = query(<session-marker>)
  let select-markers-by-page(accept) = {
    all-markers.filter(marker => {
      let marker-page = counter(page).at(marker.location()).first()
      accept(marker-page)
    })
  }

  let markers-on-page = select-markers-by-page(page => page == current-page)
  if markers-on-page.len() > 0 {
    let first-marker = markers-on-page.first()
    if first-marker.location().position().y < page.height / 3 {
      return first-marker.value
    }
  }

  let markers-before-page = select-markers-by-page(page => page < current-page)
  if markers-before-page.len() > 0 {
    return markers-before-page.last().value
  }
  return none
}

#let notes(
  course: none,
  author: "Joseph Liu",
  prof: none,
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

    let lecture-or-tutorial = query-lecture-or-tutorial-at-page(current-page)
    set align(right)
    set text(size: 10pt)
    if lecture-or-tutorial != none {
      [#course (#term) \ #lecture-or-tutorial]
    } else {
      [#course (#term)]
    }
  })

  show: intertext-rule
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
    [Taught by Prof. #prof]
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

  {
    show outline.entry: set text(size: 10pt)
    show outline.entry: outrageous.show-entry.with(
      prefix-transform: (..) => "", // remove prefix
      font-weight: (auto,),
      fill: (align(right, repeat(gap: 6pt)[.]), auto),
    )

    heading(numbering: none, outlined: false, depth: 2)[
      Lectures and Tutorials
    ]
    v(.5em)
    outline(title: none, target: figure.where(kind: "session"))
  }
  pagebreak()

  lecture-num.update(1)
  tutorial-num.update(1)
  context first-content-page.update(here().page())
  doc
}
