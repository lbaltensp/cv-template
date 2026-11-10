# LaTeX CV and cover-letter template

A configurable LaTeX template with two CV layouts and a matching standalone
cover letter. All example people, organisations and achievements are fictional.

[![Example CV preview](preview.png)](cv-example.pdf)

Download the example [CV](cv-example.pdf) or
[cover letter](cover-letter-example.pdf), then replace the placeholder content
in `cv-example.tex` or `cover-letter-example.tex`. Both use `cv.cls`.

## Compile online with Overleaf

No local TeX installation is needed.

1. Download this repository using **Code → Download ZIP** and extract it.
2. Create a blank Overleaf project and upload `cv.cls`, `cv-example.tex` and
   `cover-letter-example.tex`. The local `.latexmkrc` and `build/` are not needed.
3. Select the source you want as the main document and use **pdfLaTeX**.
4. Recompile and download the resulting PDF.

## Compile locally

Install MacTeX or TeX Live, including `latexmk`, then run from this folder:

```sh
latexmk -pdf cv-example.tex
latexmk -pdf cover-letter-example.tex
```

Each source produces a separate PDF. The project `.latexmkrc` puts all compiler
output in `build/` and copies only finished PDFs beside their sources. Logs,
auxiliary files and SyncTeX data stay in `build/`. The build configuration uses
latexmk's `out2_dir` support and is tested with latexmk 4.88.

Select **latexmk** as your editor's build command to use this configuration.
Direct `pdflatex` commands do not read `.latexmkrc`. For PDF/source navigation,
point the editor's viewer at `build/<document-name>.pdf`, beside its SyncTeX file.

To remove intermediate files while retaining the PDFs:

```sh
latexmk -c cv-example.tex
```

Generated files and `build/` are ignored by Git. Example PDFs remain versioned.

## Choose a CV layout

Set the layout in the existing `\cvsetup` block:

```latex
\cvsetup{
    layout = timeline,  % Date column beside the content (default).
    % layout = compact,  % Organisation/dates, then role/location.
    body-size = 10pt,
    bullet-size = 5.5pt
}
```

Both layouts use identical content commands, so switching needs no duplicated
CV source. Compact mode gives the body the full available width and indents
its dot bullets more deeply. Both layouts use italic roles, dot bullets and
aligned continuation lines. Optional fields and long headings are supported
in both, including education subentries and `organisation-first=false`.

## Appearance and spacing

`\cvsetup` controls fonts, sizes, colours, visibility and spacing. The commented
settings in `cv-example.tex` show the available options. Supported font families
are `computer-modern`, `latin-modern`, `times`, `palatino` and `helvetica`.
`body-size` also controls heading, subentry, date, location, contact, biography
and footer sizes unless those are overridden individually.

Each layout selects its own extra vertical spacing:

| Setting | Timeline | Compact | Separates |
| --- | --- | --- | --- |
| `section-gap` | 10pt | 4pt | Sections; also space below the section rule |
| `heading-gap` | 4pt | 1pt | Entry heading and its first body block |
| `entry-gap` | 7pt | 4pt | Entries in the same section |
| `bullet-gap` | 2pt | 1pt | Bullets and successive detail blocks |

An explicit gap key overrides the selected layout's default, regardless of key
order. Remove that key to restore automatic layout spacing. These settings do
not change line spacing within a paragraph.

- `show-dates=false` hides dates in either layout and reclaims the timeline column.
- `date-width` and `date-gap` affect timeline mode only.
- `row-inset` and `subentry-indent` work in both layouts.
- `location-gap` separates heading text from metadata, including compact dates.
- `show-page-numbers=false` hides the page footer.
- `show-contact-icons=false` and `show-location-icons=false` hide the icons.
- `bullet-size` changes the marker size without changing body text.

## Contact header

Use `\cvheader` for name, title, email, phone, website, GitHub, LinkedIn,
Google Scholar, location and an optional biography. Omit a field or set it to
`{}` to hide it; separators appear only between visible contacts.

Display labels are independent of destinations:

```latex
\cvheader{
    name = {Alex Example},
    email = {alex@example.com},
    email-label = {alex@example.com},
    phone = {+41 00 000 00 00},
    linkedin = {https://www.linkedin.com/in/your-name/},
    linkedin-label = {in/your-name/}
}
```

Email and phone appear first, followed by any website, GitHub, LinkedIn,
Google Scholar and location fields. `website-label`, `github-label` and
`google-scholar-label` customise the other link labels.

## Content commands

- `\cvsection{Title}` creates a section heading and rule.
- `cventry` accepts optional `organisation`, `role`, `dates`, `location`, `url` fields.
- `\cvdetail{Text}` adds a body block.
- `cvbullets` contains ordinary `\item` bullets.
- `\cvsubentry[...]` uses the same heading fields for an indented subentry.
- `\cvlink{URL}{Text}` creates a coloured italic body link.
- `\cvseparator` creates the slightly stronger inline separator dot used in headings,
  contacts and the example skills list.
- `\makecvheader` renders the configured header.

Organisation names are bold and roles italic. A heading URL links the
organisation, or the role when no organisation is supplied. Contact links
remain regular; body links made with `\cvlink` are italic.

Each entry, including subentries, stays together and must fit within one page.
Longer documents flow to additional pages with page X of Y footers. Explicit
page breaks can be placed between complete entries.

## Paper size and cover letters

A4 is the class default. For US Letter, add this in the preamble, outside
`\cvsetup`:

```latex
\geometry{letterpaper}
```

The standalone cover letter shares the CV header and font family, with 11pt
body text, a 9pt contact row, left-aligned paragraphs and no page numbering.
Recipient, date, subject, salutation and closing are editable in its source.

The `document-title` key sets PDF metadata independently of the visible header:

```latex
document-title = {Alex Example -- Cover Letter},
```

When omitted, it defaults to the configured name followed by “CV”.

## Layout checks

The optional test suite needs pdfLaTeX on PATH and Python 3 with `pdfplumber`:

```sh
python3 -m pip install pdfplumber
python3 -m unittest discover -s tests -v
```

Checks compile the real class and inspect PDF positions, optional fields,
wrapping, subentries, typography, marker sizing and spacing overrides.

## Licence

MIT; see [LICENSE](LICENSE) for attribution and terms.
