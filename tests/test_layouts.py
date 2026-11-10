"""Compile the real class and check text positions in the resulting PDFs.

Run with Python 3 + pdfplumber and pdfLaTeX available:
    python3 -m unittest discover -s tests -v
"""
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest

import pdfplumber

ROOT = Path(__file__).resolve().parents[1]
PDFLATEX = shutil.which('pdflatex') or '/Library/TeX/texbin/pdflatex'
ENTRY = r'''
\begin{cventry}[organisation={ORGALPHA},role={ROLEALPHA},dates={2020--2024},location={PLACEALPHA}]
\cvdetail{BODYALPHA describes a research project using a complete paragraph of evidence.}
\cvsubentry[organisation={SUBALPHA},role={SUBROLE},dates={2022--2023},location={SUBPLACE}]
\cvdetail{AFTERSUB remains aligned with the parent entry.}
\end{cventry}
'''


def compile_document(settings='', body=ENTRY, expect_success=True, preamble=''):
    source = (r'\documentclass{cv}' + '\n' +
              r'\cvsetup{show-page-numbers=false,show-location-icons=false,' + settings + '}\n' +
              preamble + '\n' + r'\begin{document}' + '\n' + body + '\n' + r'\end{document}')
    with tempfile.TemporaryDirectory() as directory:
        folder = Path(directory)
        shutil.copyfile(ROOT / 'cv.cls', folder / 'cv.cls')
        (folder / 'test.tex').write_text(source)
        result = subprocess.run([PDFLATEX, '-interaction=nonstopmode', '-halt-on-error',
                                 'test.tex'], cwd=folder, capture_output=True, text=True)
        log = (folder / 'test.log').read_text()
        if not expect_success:
            return result.returncode, log
        if result.returncode:
            raise AssertionError('Compilation failed:\n' + result.stdout[-2000:])
        if 'Overfull' in log:
            raise AssertionError('Layout overflow:\n' + log[-3000:])
        with pdfplumber.open(folder / 'test.pdf') as pdf:
            return [page.extract_words(extra_attrs=['fontname']) for page in pdf.pages]


def word(pages, text):
    matches = [w for page in pages for w in page if w['text'] == text]
    if len(matches) != 1:
        raise AssertionError(f'Expected one occurrence of {text!r}, got {len(matches)}')
    return matches[0]


class LayoutTests(unittest.TestCase):
    def test_compact_reclaims_date_column_and_right_aligns_dates(self):
        pages = compile_document('layout=compact')
        org, role, date, location, body = [word(pages, s) for s in
            ['ORGALPHA', 'ROLEALPHA', '2020–2024', 'PLACEALPHA', 'BODYALPHA']]
        self.assertAlmostEqual(org['x0'], body['x0'], delta=0.5)
        self.assertGreater(date['x0'], body['x0'] + 200)
        self.assertAlmostEqual(org['top'], date['top'], delta=1)
        self.assertGreater(role['top'], org['top'] + 5)
        self.assertAlmostEqual(role['top'], location['top'], delta=1)
        self.assertAlmostEqual(date['x1'], location['x1'], delta=0.5)
        self.assertAlmostEqual(word(pages, 'AFTERSUB')['x0'], body['x0'], delta=0.5)
        self.assertAlmostEqual(word(pages, 'SUBALPHA')['x0'] - org['x0'], 10, delta=0.5)

    def test_timeline_is_default_and_keeps_existing_date_column(self):
        default = compile_document()
        explicit = compile_document('layout=timeline')
        for text in ['ORGALPHA', 'ROLEALPHA', 'BODYALPHA', '2020–2024', 'SUBALPHA']:
            for coordinate in ['x0', 'top', 'x1', 'bottom']:
                self.assertAlmostEqual(word(default, text)[coordinate],
                                       word(explicit, text)[coordinate], delta=0.01)
        self.assertGreater(word(default, 'BODYALPHA')['x0'], word(default, '2020–2024')['x0'] + 50)
        self.assertAlmostEqual(word(default, 'ORGALPHA')['top'], word(default, 'ROLEALPHA')['top'], delta=1)

    def test_compact_body_blocks_use_the_reclaimed_width(self):
        paragraph = ' '.join(['evidence'] * 100)
        for content in [r'\cvdetail{' + paragraph + '}',
                        r'\begin{cvbullets}\item ' + paragraph + r'\end{cvbullets}']:
            with self.subTest(content=content[:20]):
                body = r'\begin{cventry}[organisation={ORG}]' + content + r'\end{cventry}'
                compact = compile_document('layout=compact', body)
                timeline = compile_document('layout=timeline', body)
                positions = lambda pages: [w for page in pages for w in page if w['text'] == 'evidence']
                compact_words, timeline_words = positions(compact), positions(timeline)
                self.assertEqual(len(compact_words), 100)
                self.assertEqual(len(timeline_words), 100)
                self.assertLess(len({round(w['top'], 1) for w in compact_words}),
                                len({round(w['top'], 1) for w in timeline_words}))
                self.assertLess(min(w['x0'] for w in compact_words),
                                min(w['x0'] for w in timeline_words) - 50)

    def test_date_column_width_does_not_change_compact_geometry(self):
        ordinary = compile_document('layout=compact')
        wide = compile_document('layout=compact,date-width=8cm,date-gap=2cm')
        for text in ['ORGALPHA', 'BODYALPHA', '2020–2024', 'SUBALPHA']:
            self.assertEqual(word(ordinary, text), word(wide, text))

    def test_compact_uses_indented_dot_bullets_with_hanging_alignment(self):
        body = (r'\begin{cventry}[organisation={ORG}]\begin{cvbullets}\item START ' +
                ' '.join(['evidence'] * 80) + r'\end{cvbullets}\end{cventry}')
        pages = compile_document('layout=compact', body)
        org, start, dot = word(pages, 'ORG'), word(pages, 'START'), word(pages, '•')
        self.assertAlmostEqual(start['x0'] - org['x0'], 24, delta=0.5)
        self.assertGreater(dot['x0'], org['x0'] + 10)
        self.assertLess(dot['x1'], start['x0'] - 3)
        following = [w for p in pages for w in p if w['text'] == 'evidence' and w['top'] > start['top'] + 5]
        self.assertAlmostEqual(min(w['x0'] for w in following), start['x0'], delta=0.5)
        timeline = compile_document('layout=timeline', body)
        self.assertEqual(len([w for p in timeline for w in p if w['text'] == '•']), 1)

    def test_layouts_select_their_own_spacing_defaults(self):
        body = (r'\cvsection{FIRST}' + ENTRY + ENTRY.replace('ALPHA', 'BETA') +
                r'\cvsection{SECOND}\begin{cventry}[role={LAST}]' +
                r'\begin{cvbullets}\item ITEMONE\item ITEMTWO\end{cvbullets}\end{cventry}')
        cases = [('compact', 'section-gap=4pt,heading-gap=1pt,entry-gap=4pt,bullet-gap=1pt'),
                 ('timeline', 'section-gap=10pt,heading-gap=4pt,entry-gap=7pt,bullet-gap=2pt')]
        for layout, gaps in cases:
            with self.subTest(layout=layout):
                self.assertEqual(compile_document('layout=' + layout, body),
                                 compile_document('layout=' + layout + ',' + gaps, body))

    def test_explicit_spacing_overrides_survive_layout_selection(self):
        gaps = 'section-gap=9pt,heading-gap=6pt,entry-gap=8pt,bullet-gap=3pt'
        before = compile_document(gaps + ',layout=compact')
        after = compile_document('layout=compact,' + gaps)
        later = compile_document(gaps, preamble=r'\cvsetup{layout=compact}')
        self.assertEqual(before, after)
        self.assertEqual(after, later)

    def test_switching_back_to_timeline_restores_its_defaults(self):
        body = r'\cvsection{FIRST}' + ENTRY
        switched = compile_document('', body, preamble=r'\cvsetup{layout=compact}\cvsetup{layout=timeline}')
        self.assertEqual(compile_document('layout=timeline', body), switched)

    def test_bullet_size_changes_only_the_marker(self):
        body = r'\begin{cventry}[organisation={ORG}]\begin{cvbullets}\item BODY\end{cvbullets}\end{cventry}'
        default = compile_document('layout=compact', body)
        larger = compile_document('layout=compact,bullet-size=8pt', body)
        self.assertGreater(word(larger, '•')['height'], word(default, '•')['height'] + 2)
        self.assertEqual(word(larger, 'BODY')['fontname'], word(default, 'BODY')['fontname'])
        for key in ['x0', 'x1', 'top', 'bottom', 'height']:
            self.assertAlmostEqual(word(larger, 'BODY')[key], word(default, 'BODY')[key], delta=0.01)

    def test_roles_are_italic_in_both_layouts(self):
        for layout in ['timeline', 'compact']:
            with self.subTest(layout=layout):
                pages = compile_document('layout=' + layout)
                self.assertIn('CMTI', word(pages, 'ROLEALPHA')['fontname'])
                self.assertIn('CMBX', word(pages, 'ORGALPHA')['fontname'])

    def test_compact_supports_role_first(self):
        pages = compile_document('layout=compact,organisation-first=false')
        self.assertLess(word(pages, 'ROLEALPHA')['top'], word(pages, 'ORGALPHA')['top'])
        self.assertAlmostEqual(word(pages, 'ROLEALPHA')['top'], word(pages, '2020–2024')['top'], delta=1)

    def test_hidden_dates_do_not_leave_a_column(self):
        pages = compile_document('layout=compact,show-dates=false')
        self.assertNotIn('2020–2024', [w['text'] for p in pages for w in p])
        self.assertAlmostEqual(word(pages, 'ORGALPHA')['x0'], word(pages, 'BODYALPHA')['x0'], delta=0.5)

    def test_optional_fields_and_empty_entries(self):
        body = r'''
\begin{cventry}[organisation={ORGONLY}]\cvdetail{BODYONE}\end{cventry}
\begin{cventry}[role={ROLEONLY}]\cvdetail{BODYTWO}\end{cventry}
\begin{cventry}[dates={DATEONLY}]\cvdetail{BODYTHREE}\end{cventry}
\begin{cventry}[location={PLACEONLY}]\cvdetail{BODYFOUR}\end{cventry}
\begin{cventry}[organisation={ORGWITHPLACE},location={OTHERPLACE}]\cvdetail{BODYFIVE}\end{cventry}
\begin{cventry}\cvdetail{BODYONLY}\end{cventry}
\begin{cventry}[url={https://example.com}]\end{cventry}
\begin{cventry}[organisation={   },role={   }]\end{cventry}
'''
        pages = compile_document('layout=compact', body)
        self.assertEqual(len(pages), 1)
        self.assertAlmostEqual(word(pages, 'ORGONLY')['x0'], word(pages, 'ROLEONLY')['x0'], delta=0.5)
        self.assertAlmostEqual(word(pages, 'ORGONLY')['x0'], word(pages, 'BODYONLY')['x0'], delta=0.5)
        # A lone role must not acquire an empty row above it.
        self.assertAlmostEqual(word(pages, 'BODYONE')['top'] - word(pages, 'ORGONLY')['top'],
                               word(pages, 'BODYTWO')['top'] - word(pages, 'ROLEONLY')['top'], delta=0.5)
        self.assertEqual([w['text'] for p in pages for w in p].count('ORGONLY'), 1)

    def test_long_headings_wrap_without_overflow(self):
        body = r'''
\begin{cventry}[
organisation={A research organisation with a deliberately very long name that wraps over multiple lines},
role={A research engineering role with a deliberately long descriptive title},
dates={September 2020 through December 2024},
location={An unusually long location description spanning multiple geographical regions}]
\cvdetail{AFTERLONG follows the complete heading.}\end{cventry}
'''
        pages = compile_document('layout=compact', body)
        self.assertEqual(len(pages), 1)
        marker = word(pages, 'AFTERLONG')
        preceding = [w for p in pages for w in p if w['text'] != 'AFTERLONG' and w['top'] < marker['top']]
        self.assertGreater(marker['top'], max(w['bottom'] for w in preceding))

    def test_invalid_layout_has_actionable_error(self):
        code, log = compile_document('layout=dense', expect_success=False)
        self.assertNotEqual(code, 0)
        self.assertIn("Unknown layout 'dense'", log)
        self.assertIn('timeline or compact', log)


if __name__ == '__main__':
    unittest.main()
