# invoicr

Generates Czech non-VAT invoices to PDF with [Typst](https://typst.app) and keeps JSON records of them.

![invoicr](https://repository-images.githubusercontent.com/1409281814/de94b71f-4394-4bfc-af86-68c9caa74e2c)

## Requirements

- `bash` 3.2 or newer
- `jq` 1.5 or newer – bundled with macOS
- `typst` – see [Install the compiler](https://typst.app/open-source/)

## Installation

```bash
git clone https://github.com/yanascz/invoicr.git
cd invoicr

mkdir -p ~/.invoicr
cp config.json invoice.typ ~/.invoicr/
cp invoicr ~/.local/bin/ # or anywhere on your PATH
```

Then edit `~/.invoicr/config.json` to describe your business and your customers.

## Usage

Run `invoicr` with no arguments for the full option listing.

### Create an invoice

```bash
invoicr invoice -c cnb -n "Fakturu lze zaplatit i hotově, nebo bitcoinem." \
  -i "Konzultace k Ankapu h=21 r=1000.00" \
  -i "Vývoj software na míru h=73 r=1200.00"
```

```
./faktura-20261001.pdf
```

The PDF is stored in the current directory; `-o <dir>` stores it elsewhere.
Invoice numbers are `YYYYMMNN`, allocated per month and never reused.
A record of every invoice is kept as JSON in `~/.invoicr/invoices/<year>/`.

### Summarise a year

```bash
invoicr stats
```

```
Year 2026 Statistics

Invoices count: 1
Total invoiced: 108600.00 Kč
```

The year defaults to the current one; `-y <year>` sets a specific one.
