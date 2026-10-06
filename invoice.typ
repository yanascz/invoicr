#import "@preview/cades:0.3.1": qr-code
#import "@preview/zero:0.1.0": num

#let margin = 1.25cm
#let font = "IBM Plex Sans"
#let text-size = 10pt
#let dark-gray = rgb("#777")
#let light-gray = rgb("#ccc")
#let hair-stroke = 0.5pt + light-gray

#set page(
  paper: "a4",
  margin: margin,
  footer: [Fyzická osoba zapsaná v živnostenském rejstříku. #h(1fr) \/\/ vystavil *invoicr*],
  footer-descent: -text-size,
)
#set text(
  font: font,
  size: text-size,
  fill: dark-gray,
)
#set par(leading: text-size, spacing: 0.75cm)
#show math.equation: set text(font: font)

#let unpad(value) = {
  value.replace(regex("^0+"), "")
}

#let account-number(iban) = {
  let bank = iban.slice(4, 8)
  let prefix = unpad(iban.slice(8, 14))
  let number = unpad(iban.slice(14, 24))
  if prefix == "" {
    number + "/" + bank
  } else {
    prefix + "-" + number + "/" + bank
  }
}

#let date(date) = {
  let (year, month, day) = date.split("-")
  unpad(day) + ". " + unpad(month) + ". " + year
}

#let amount(value) = {
  num(str(value), digits: 2, decimal-separator: ",", group: (separator: " ")) + " Kč"
}

#let spd(iban: str, amount: decimal, vs: str) = {
  "SPD*1.0*ACC:" + iban + "*AM:" + str(amount) + "*CC:CZK*X-VS:" + vs
}

#let invoice(
  number: int,
  supplier: dictionary,
  customer: dictionary,
  issued: str,
  due: str,
  items: [],
  note: "",
) = {
  let heading(title) = {
    text(size: 9pt)[#upper(title)]
  }
  let party(name) = {
    block(width: 100%, stroke: (bottom: hair-stroke), inset: (bottom: 5pt))[
      #heading(name)
    ]
  }
  let value(value) = {
    text(fill: black)[#value]
  }

  block(below: 1cm)[
    #text(size: 20pt)[*#value([Faktura č. #number])*]
  ]

  columns(2, gutter: margin)[
    #party([Dodavatel])

    *#value(supplier.name)*\
    #value(supplier.street)\
    #value(supplier.city)

    IČO #h(1fr) #value(supplier.ico)\
    #value([Neplátce DPH])

    Bankovní účet #h(1fr) *#value(account-number(supplier.iban))*\
    Variabilní symbol #h(1fr) *#value(number)*\
    Způsob platby #h(1fr) #value([Převodem])

    #colbreak()

    #party([Odběratel])

    *#value(customer.name)*\
    #value(customer.street)\
    #value(customer.city)

    IČO #h(1fr) #value(customer.ico)\
    DIČ #h(1fr) #value(customer.dic)

    Datum vystavení #h(1fr) #value(date(issued))\
    Datum splatnosti #h(1fr) *#value(date(due))*
  ]

  if note != "" {
    block(above: 1cm)[
      _#value(note)_
    ]
  }

  block(above: 1cm)[
    #table(
      columns: (1fr, auto, auto, auto),
      column-gutter: 1cm,
      row-gutter: 10pt,
      inset: (x: 0pt, top: 0pt, bottom: 5pt),
      align: (left, right, right, right),
      stroke: none,
      table.hline(stroke: hair-stroke, position: bottom),
      table.header(heading([Služba]), heading([Hod.]), heading([Cena/hod.]), heading([Cena celkem])),
      ..for (title, hours, rate) in items {
        let total = hours * decimal(rate)
        (value(title), value(str(hours)), value(amount(rate)), value(amount(total)))
      },
    )
  ]

  let total = items.fold(0, (acc, it) => acc + it.hours * decimal(it.rate))
  columns(2, gutter: margin)[
    #stack(
      dir: ttb,
      spacing: -5pt,
      block(stroke: hair-stroke, inset: 10pt)[
        #let qr-data = spd(iban: supplier.iban, amount: total, vs: number)
        #qr-code(qr-data, error-correction: "L", width: 3cm)
      ],
      pad(left: 5pt)[
        #block(fill: white, inset: 5pt)[QR platba]
      ],
    )
    #colbreak()
    #align(right)[
      #block(width: 100%, stroke: (top: light-gray), inset: (top: 10pt))[
        #text(size: 15pt)[*#value(amount(total))*]
      ]
    ]
  ]
}

#let data-path = sys.inputs.at("data", default: "invoice.json")
#invoice(..json(data-path))
