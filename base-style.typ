#import "deps.typ": marginalia, zebraw
#import zebraw: zebraw, zebraw-init

#let only-number-labelled-equations(ignored-labels: (), doc) = {
  let equation-labels = state("jliu/equation-labels", ())

  // remember all labels used for equations
  show math.equation.where(block: true): it => {
    if it.has("label") and it.label not in ignored-labels {
      equation-labels.update(labels => (..labels, it.label))
    }
    it
  }

  // set numbering for all equations with a known label
  context if equation-labels.final() != () {
    let labeled = equation-labels.final().map(label => math.equation.where(label: label))
    show selector.or(..labeled): set math.equation(numbering: "(1.1.1)")
    doc
  } else {
    doc
  }
}

#let base-style(
  title: none,
  author: (),
  margin: (inner: .75in, outer: .75in, top: 1in, bottom: 1in),
  heading-font: "Noto Sans",
  body-font: "Libertinus Serif",
  code-font: "Fira Code",
  font-size: 11pt,
  ignored-equation-labels: (), // will be skipped from numbering
  doc,
) = {
  set document(author: author, title: title)
  show: marginalia.setup.with(
    inner: (width: margin.inner),
    outer: (width: margin.outer),
    top: margin.top,
    bottom: margin.bottom,
    book: false,
  )
  set page(paper: "us-letter", numbering: "1")

  set par(justify: true)
  set text(font: body-font, size: font-size)

  set heading(numbering: "1.1.1")
  show heading: it => block(
    {
      set text(font: "Noto Sans", weight: "semibold")
      if it.numbering != none {
        numbering(it.numbering, ..counter(heading).at(it.location()))
        h(1em)
      }
      it.body
    },
    below: 1em,
  )

  // color external links blue
  show link: it => {
    if type(it.dest) != location and type(it.dest) != label {
      set text(blue)
      it
    } else {
      it
    }
  }

  // more spacing for various elements
  set math.mat(column-gap: 1em, row-gap: .5em) // https://github.com/typst/typst/issues/3302
  set math.vec(gap: .5em)
  set math.cases(gap: .5em)
  set list(indent: 1.5em)
  set enum(indent: 1.5em)

  show raw: set text(font: code-font)

  show: zebraw-init.with(lang: none, numbering-font-args: (weight: "light"), numbering-separator: true)
  show: zebraw

  show: only-number-labelled-equations.with(ignored-labels: ignored-equation-labels)

  doc
}
