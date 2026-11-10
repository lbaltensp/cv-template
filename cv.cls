% Configurable CV template
% Author: Lars Baltensperger
% Originally based on Micha Bosshart's 2023 CV template.
% Original project: https://github.com/LaTeX-Template-Share
%
% SPDX-License-Identifier: MIT
% See LICENSE for copyright notices and licence terms.

\NeedsTeXFormat{LaTeX2e}[2022-06-01]
\ProvidesClass{cv}[2026/10/03 Configurable CV template]

% Public API:
%   Setup:   \cvsetup, \cvheader, \makecvheader
%   Content: \cvsection, cventry, \cvdetail, cvbullets, \cvsubentry, \cvlink, \cvseparator
% Internal commands use the cv@ prefix. See cv-example.tex for usage examples.

% ============================================================================
% 1. Base class and packages
% ============================================================================

\RequirePackage{fix-cm} % Allow arbitrary Computer Modern font sizes.
\DeclareOption*{\PassOptionsToClass{\CurrentOption}{article}}
\PassOptionsToClass{a4paper,10pt}{article}
\ProcessOptions\relax
\LoadClass{article}

\RequirePackage{keyval}      % Named configuration and entry fields.
\RequirePackage{etoolbox}    % Empty-value checks and boolean settings.
\RequirePackage{bold-extra}
\RequirePackage{xcolor}
\RequirePackage{fontawesome5}
\RequirePackage{enumitem}
\RequirePackage[margin=2cm]{geometry}
\RequirePackage{fancyhdr}    % Centred page footer.
\RequirePackage{lastpage}    % Total page count, resolved on the next LaTeX run.
\RequirePackage{hyperref}

\hypersetup{hidelinks}
\setlength{\parindent}{0pt}
\setlength{\parskip}{0pt}

% ============================================================================
% 2. Appearance: defaults, then configurable keys
% ============================================================================

% Font sizes remain linked to body-size until explicitly overridden.
\newcommand{\cv@fontFamily}{cmr}
\newcommand{\cv@bodySize}{10pt}
\newcommand{\cv@headingSize}{\cv@bodySize}
\newcommand{\cv@subentrySize}{\cv@bodySize}
\newcommand{\cv@dateSize}{\cv@bodySize}
\newcommand{\cv@locationSize}{\cv@bodySize}
\newcommand{\cv@contactSize}{\cv@bodySize}
\newcommand{\cv@bioSize}{\cv@bodySize}
\newcommand{\cv@footerSize}{\cv@bodySize}
\newcommand{\cv@documentTitle}{\cv@name\space--\space CV}
\newcommand{\cv@nameSize}{17.28pt}
\newcommand{\cv@sectionSize}{12pt}
\newcommand{\cv@locationIconSize}{7pt}
\newcommand{\cv@bulletSize}{5.5pt}

\colorlet{cvLink}{blue}
\colorlet{cvLocation}{black!55}
\colorlet{cvContactIcon}{black!40}

% Vertical gaps are additional space beyond normal line spacing.
\newlength{\cv@headingGap}      \setlength{\cv@headingGap}{4pt}
\newlength{\cv@bulletIndent}
\newlength{\cv@bulletLabelGap}
\newlength{\cv@bulletGap}       \setlength{\cv@bulletGap}{2pt}
\newlength{\cv@entryGap}        \setlength{\cv@entryGap}{7pt}
\newlength{\cv@sectionGap}      \setlength{\cv@sectionGap}{10pt}
\newlength{\cv@headerGap}       \setlength{\cv@headerGap}{6pt}
\newlength{\cv@bioGap}          \setlength{\cv@bioGap}{10pt}
\newlength{\cv@dateGap}         \setlength{\cv@dateGap}{8pt}
\newlength{\cv@locationGap}     \setlength{\cv@locationGap}{10pt}
\newlength{\cv@subentryIndent}  \setlength{\cv@subentryIndent}{10pt}
\newlength{\cv@rowInset}        \setlength{\cv@rowInset}{6pt}
\newcommand{\cv@dateWidthSetting}{auto}

\newbool{cv@customSectionGap} \setbool{cv@customSectionGap}{false}
\newbool{cv@customHeadingGap} \setbool{cv@customHeadingGap}{false}
\newbool{cv@customEntryGap} \setbool{cv@customEntryGap}{false}
\newbool{cv@customBulletGap} \setbool{cv@customBulletGap}{false}

\newbool{cv@compactLayout}      \setbool{cv@compactLayout}{false}
\newbool{cv@organisationFirst}  \setbool{cv@organisationFirst}{true}
\newbool{cv@showDates}          \setbool{cv@showDates}{true}
\newbool{cv@showLocationIcons}  \setbool{cv@showLocationIcons}{true}
\newbool{cv@showContactIcons}   \setbool{cv@showContactIcons}{true}
\newbool{cv@showPageNumbers}    \setbool{cv@showPageNumbers}{true}

% Map readable font names to the font families installed with TeX.
\@namedef{cv@font@computer-modern}{cmr}
\@namedef{cv@font@latin-modern}{lmr}
\@namedef{cv@font@times}{ptm}
\@namedef{cv@font@palatino}{ppl}
\@namedef{cv@font@helvetica}{phv}
\newcommand{\cv@selectFont}[1]{%
    \ifcsdef{cv@font@#1}{%
        \edef\cv@fontFamily{\csname cv@font@#1\endcsname}%
    }{%
        \ClassError{cv}{Unknown font '#1'}%
            {Choose computer-modern, latin-modern, times, palatino, or helvetica.}%
    }%
}

% PDF metadata, typography and colours.
\define@key{cv}{document-title}{\def\cv@documentTitle{#1}}
\define@key{cv}{font}{\cv@selectFont{#1}}
\define@key{cv}{body-size}{\def\cv@bodySize{#1}}
\define@key{cv}{heading-size}{\def\cv@headingSize{#1}}
\define@key{cv}{subentry-size}{\def\cv@subentrySize{#1}}
\define@key{cv}{date-size}{\def\cv@dateSize{#1}}
\define@key{cv}{location-size}{\def\cv@locationSize{#1}}
\define@key{cv}{contact-size}{\def\cv@contactSize{#1}}
\define@key{cv}{bio-size}{\def\cv@bioSize{#1}}
\define@key{cv}{footer-size}{\def\cv@footerSize{#1}}
\define@key{cv}{name-size}{\def\cv@nameSize{#1}}
\define@key{cv}{section-size}{\def\cv@sectionSize{#1}}
\define@key{cv}{location-icon-size}{\def\cv@locationIconSize{#1}}
\define@key{cv}{bullet-size}{\def\cv@bulletSize{#1}}
\define@key{cv}{link-color}{\colorlet{cvLink}{#1}}
\define@key{cv}{location-color}{\colorlet{cvLocation}{#1}}
\define@key{cv}{contact-icon-color}{\colorlet{cvContactIcon}{#1}}

% Spacing and page layout.
\define@key{cv}{heading-gap}{\setlength{\cv@headingGap}{#1}\setbool{cv@customHeadingGap}{true}}
\define@key{cv}{bullet-gap}{\setlength{\cv@bulletGap}{#1}\setbool{cv@customBulletGap}{true}}
\define@key{cv}{entry-gap}{\setlength{\cv@entryGap}{#1}\setbool{cv@customEntryGap}{true}}
\define@key{cv}{section-gap}{\setlength{\cv@sectionGap}{#1}\setbool{cv@customSectionGap}{true}}
\define@key{cv}{header-gap}{\setlength{\cv@headerGap}{#1}}
\define@key{cv}{bio-gap}{\setlength{\cv@bioGap}{#1}}
\define@key{cv}{date-gap}{\setlength{\cv@dateGap}{#1}}
\define@key{cv}{location-gap}{\setlength{\cv@locationGap}{#1}}
\define@key{cv}{subentry-indent}{\setlength{\cv@subentryIndent}{#1}}
\define@key{cv}{row-inset}{\setlength{\cv@rowInset}{#1}}
\define@key{cv}{date-width}{\def\cv@dateWidthSetting{#1}}
\define@key{cv}{margin}{\geometry{margin=#1}}

% Entry layout. Timeline remains the default for existing documents.
\newcommand{\cv@setLayout}[1]{%
    \ifstrequal{#1}{timeline}{%
        \setbool{cv@compactLayout}{false}%
    }{%
        \ifstrequal{#1}{compact}{%
            \setbool{cv@compactLayout}{true}%
        }{%
            \ClassError{cv}{Unknown layout '#1'}{Choose timeline or compact.}%
        }%
    }%
}
\define@key{cv}{layout}{\cv@setLayout{#1}}

% Resolve layout defaults once the final preamble settings are known.
% Explicit gap settings take precedence, regardless of key/call ordering.
\newcommand{\cv@layoutGap}[4]{%
    \ifbool{cv@custom#1Gap}{}{%
        \ifbool{cv@compactLayout}{\setlength{#2}{#4}}{\setlength{#2}{#3}}%
    }%
}
\newcommand{\cv@applyLayoutSpacing}{%
    \cv@layoutGap{Section}\cv@sectionGap{10pt}{4pt}%
    \cv@layoutGap{Heading}\cv@headingGap{4pt}{1pt}%
    \cv@layoutGap{Entry}\cv@entryGap{7pt}{4pt}%
    \cv@layoutGap{Bullet}\cv@bulletGap{2pt}{1pt}%
}

% Visibility and heading order.
\define@key{cv}{organisation-first}[true]{\setbool{cv@organisationFirst}{#1}}
\define@key{cv}{show-dates}[true]{\setbool{cv@showDates}{#1}}
\define@key{cv}{show-location-icons}[true]{\setbool{cv@showLocationIcons}{#1}}
\define@key{cv}{show-contact-icons}[true]{\setbool{cv@showContactIcons}{#1}}
\define@key{cv}{show-page-numbers}[true]{\setbool{cv@showPageNumbers}{#1}}

\newcommand{\cvsetup}[1]{\setkeys{cv}{#1}}
\@onlypreamble\cvsetup

% ============================================================================
% 3. Shared helpers and entry fields
% ============================================================================

% Test the value of a stored field, including whitespace-only values.
% Usage: \cv@ifEmpty\field{empty branch}{nonempty branch}
\newcommand{\cv@ifEmpty}[1]{\expandafter\ifblank\expandafter{#1}}

% Use the same 1.2 line-spacing factor for every configurable text size.
\newcommand{\cv@setTextSize}[1]{%
    \fontsize{#1}{\dimexpr#1*6/5\relax}\selectfont
}

\define@key{cvEntry}{organisation}{\def\cv@organisation{#1}}
\define@key{cvEntry}{role}{\def\cv@role{#1}}
\define@key{cvEntry}{dates}{\def\cv@dates{#1}}
\define@key{cvEntry}{location}{\def\cv@location{#1}}
\define@key{cvEntry}{url}{\def\cv@url{#1}}

% Reset fields before each entry; omitted fields must never inherit content.
\newcommand{\cv@setEntryFields}[1]{%
    \setkeys{cvEntry}{organisation={},role={},dates={},location={},url={},#1}%
}

% A URL alone is invisible. Dates count only when date display is enabled.
\newcommand{\cv@ifHeading}[2]{%
    \cv@ifEmpty\cv@organisation{%
        \cv@ifEmpty\cv@role{%
            \cv@ifEmpty\cv@location{%
                \ifbool{cv@showDates}{\cv@ifEmpty\cv@dates{#2}{#1}}{#2}%
            }{#1}%
        }{#1}%
    }{#1}%
}

% ============================================================================
% 4. Entry layout: columns, headings, then body spacing
% ============================================================================

\newlength{\cv@dateWidth}
\newlength{\cv@contentOffset}
\newlength{\cv@contentWidth}
\newlength{\cv@locationWidth}
\newsavebox{\cv@measureBox}
\newif\ifcv@hasHeading
\newif\ifcv@bodyStarted
\newif\ifcv@firstEntry
\cv@firstEntrytrue

% Timeline reserves a date column; compact reclaims it for all body blocks.
\newcommand{\cv@measureColumns}{%
    \setlength{\cv@contentOffset}{\cv@rowInset}%
    \ifbool{cv@compactLayout}{}{%
        \ifbool{cv@showDates}{%
            \ifdefstring{\cv@dateWidthSetting}{auto}{%
                \settowidth{\cv@dateWidth}{\cv@setTextSize{\cv@dateSize}00/0000--00/0000}%
            }{%
                \setlength{\cv@dateWidth}{\cv@dateWidthSetting}%
            }%
            \addtolength{\cv@contentOffset}{\cv@dateWidth}%
            \addtolength{\cv@contentOffset}{\cv@dateGap}%
        }{}%
    }%
    \setlength{\cv@contentWidth}{\dimexpr\linewidth-\cv@contentOffset\relax}%
}

\newcommand{\cv@linkedLabel}[1]{%
    \cv@ifEmpty\cv@url{#1}{\href{\cv@url}{#1}}%
}

\newcommand{\cv@renderOrganisation}{%
    \cv@ifEmpty\cv@organisation{}{\cv@linkedLabel{\textbf{\cv@organisation}}}%
}

% Link the role only when there is no organisation to link instead.
\newcommand{\cv@renderRole}{%
    \cv@ifEmpty\cv@role{}{%
        \textit{\cv@ifEmpty\cv@organisation{\cv@linkedLabel{\cv@role}}{\cv@role}}%
    }%
}

\newcommand{\cv@renderRoleSeparator}{%
    \cv@ifEmpty\cv@organisation{}{%
        \cv@ifEmpty\cv@role{}{\nobreak\enspace\cvseparator\enspace}%
    }%
}

\newcommand{\cv@renderTitle}{%
    \ifbool{cv@organisationFirst}{%
        \cv@renderOrganisation\cv@renderRoleSeparator\cv@renderRole
    }{%
        \cv@renderRole\cv@renderRoleSeparator\cv@renderOrganisation
    }%
}

\newcommand{\cv@renderLocation}{%
    \cv@setTextSize{\cv@locationSize}%
    \color{cvLocation}%
    \ifbool{cv@showLocationIcons}{%
        {\cv@setTextSize{\cv@locationIconSize}\faMapMarker*}\enspace
    }{}%
    \cv@location
}

% Reserve only the location's actual width, capped at 40% for long locations.
\newcommand{\cv@renderHeading}{%
    \cv@ifEmpty\cv@location{%
        \strut\cv@renderTitle\strut
    }{%
        \sbox{\cv@measureBox}{\cv@renderLocation}%
        \setlength{\cv@locationWidth}{\wd\cv@measureBox}%
        \ifdim\cv@locationWidth>0.4\linewidth
            \setlength{\cv@locationWidth}{0.4\linewidth}%
        \fi
        \parbox[t]{\dimexpr\linewidth-\cv@locationWidth-\cv@locationGap\relax}{%
            \raggedright\strut\cv@renderTitle\strut
        }%
        \hfill
        \parbox[t]{\cv@locationWidth}{\raggedleft\strut\cv@renderLocation\strut}%
    }%
}

% Arguments: content indentation, heading font size. Dates never indent.
\newcommand{\cv@renderTimelineHeadingRow}[2]{%
    \noindent\hspace*{\cv@rowInset}%
    \ifbool{cv@showDates}{%
        \parbox[t]{\cv@dateWidth}{%
            \raggedright\cv@setTextSize{\cv@dateSize}\strut\cv@dates\strut
        }%
        \hspace*{\cv@dateGap}%
    }{}%
    \hspace*{#1}%
    \parbox[t]{\dimexpr\cv@contentWidth-#1\relax}{%
        \raggedright\cv@setTextSize{#2}\cv@renderHeading
    }%
    \par
}

% A compact heading has two rows: primary title/dates, then secondary/location.
% Missing titles are promoted to the first row; entirely empty rows disappear.
\newcommand{\cv@setCompactTitles}{%
    \ifbool{cv@organisationFirst}{%
        \let\cv@compactPrimary\cv@organisation
        \let\cv@compactSecondary\cv@role
        \let\cv@compactRenderPrimary\cv@renderOrganisation
        \let\cv@compactRenderSecondary\cv@renderRole
    }{%
        \let\cv@compactPrimary\cv@role
        \let\cv@compactSecondary\cv@organisation
        \let\cv@compactRenderPrimary\cv@renderRole
        \let\cv@compactRenderSecondary\cv@renderOrganisation
    }%
    \cv@ifEmpty\cv@compactPrimary{%
        \let\cv@compactPrimary\cv@compactSecondary
        \let\cv@compactRenderPrimary\cv@compactRenderSecondary
        \let\cv@compactSecondary\@empty
    }{}%
    \let\cv@compactDates\@empty
    \ifbool{cv@showDates}{\let\cv@compactDates\cv@dates}{}%
}

% Arguments: left content, right-hand field, formatted right content.
% Measure metadata, cap its width, and let both sides wrap independently.
\newcommand{\cv@renderCompactLine}[3]{%
    \cv@ifEmpty#2{%
        \strut#1\strut\par
    }{%
        \sbox{\cv@measureBox}{#3}%
        \setlength{\cv@locationWidth}{\wd\cv@measureBox}%
        \ifdim\cv@locationWidth>0.4\linewidth
            \setlength{\cv@locationWidth}{0.4\linewidth}%
        \fi
        \noindent\parbox[t]{\dimexpr\linewidth-\cv@locationWidth-\cv@locationGap\relax}{%
            \raggedright\strut#1\strut
        }%
        \hfill
        \parbox[t]{\cv@locationWidth}{\raggedleft\strut#3\strut}%
        \par
    }%
}

\newcommand{\cv@renderCompactHeading}{%
    \cv@setCompactTitles
    \cv@ifEmpty\cv@compactPrimary{%
        \cv@ifEmpty\cv@compactDates{}{%
            \cv@renderCompactLine{}\cv@compactDates{\cv@setTextSize{\cv@dateSize}\cv@compactDates}%
        }%
    }{%
        \cv@renderCompactLine{\cv@compactRenderPrimary}\cv@compactDates{\cv@setTextSize{\cv@dateSize}\cv@compactDates}%
    }%
    \cv@ifEmpty\cv@compactSecondary{%
        \cv@ifEmpty\cv@location{}{%
            \cv@renderCompactLine{}\cv@location{\cv@renderLocation}%
        }%
    }{%
        \cv@renderCompactLine{\cv@compactRenderSecondary}\cv@location{\cv@renderLocation}%
    }%
}

% Both layouts share content commands, sizes, spacing and subentry indentation.
\newcommand{\cv@renderHeadingRow}[2]{%
    \ifbool{cv@compactLayout}{%
        \noindent\hspace*{\dimexpr\cv@rowInset+#1\relax}%
        \parbox[t]{\dimexpr\cv@contentWidth-#1\relax}{%
            \raggedright\cv@setTextSize{#2}\cv@renderCompactHeading
        }\par
    }{%
        \cv@renderTimelineHeadingRow{#1}{#2}%
    }%
}

% The first body block follows heading-gap; later blocks use bullet-gap.
\newcommand{\cv@startBodyBlock}{%
    \par
    \ifcv@bodyStarted
        \vspace{\cv@bulletGap}%
    \else
        \ifcv@hasHeading\vspace{\cv@headingGap}\fi
    \fi
    \cv@bodyStartedtrue
}

% ============================================================================
% 5. Public content commands
% ============================================================================

\newcommand{\cvsection}[1]{%
    \par\addvspace{\cv@sectionGap}%
    {\cv@setTextSize{\cv@sectionSize}\scshape#1\par}%
    \nobreak\vspace{2pt}\hrule\nobreak\vspace{\cv@sectionGap}%
    \global\cv@firstEntrytrue
}

% Keep each entry together on a page. Empty entries produce no spacing.
\newcommand{\cv@renderEntry}[1]{%
    \par
    \ifcv@firstEntry\else\addvspace{\cv@entryGap}\fi
    \global\cv@firstEntryfalse
    \noindent\begin{minipage}{\linewidth}
        \cv@setTextSize{\cv@bodySize}%
        \cv@measureColumns
        \cv@bodyStartedfalse
        \ifcv@hasHeading\cv@renderHeadingRow{0pt}{\cv@headingSize}\fi
        #1%
    \end{minipage}\par
}

\NewDocumentEnvironment{cventry}{O{} +b}{%
    \cv@setEntryFields{#1}%
    \cv@ifHeading{\cv@hasHeadingtrue}{\cv@hasHeadingfalse}%
    \ifcv@hasHeading
        \cv@renderEntry{#2}%
    \else
        \ifblank{#2}{}{\cv@renderEntry{#2}}%
    \fi
}{}

\NewDocumentCommand{\cvdetail}{+m}{%
    \ifblank{#1}{}{%
        \cv@startBodyBlock
        \noindent\hspace*{\cv@contentOffset}%
        \parbox[t]{\cv@contentWidth}{\raggedright\strut#1\strut}\par
    }%
}

\NewDocumentEnvironment{cvbullets}{+b}{%
    \ifblank{#1}{}{%
        \cv@startBodyBlock
        \noindent\hspace*{\cv@contentOffset}%
        \begin{minipage}[t]{\cv@contentWidth}
            \raggedright
            \def\cv@bulletMarker{{\cv@setTextSize{\cv@bulletSize}\textbullet}}%
            \ifbool{cv@compactLayout}{%
                \setlength{\cv@bulletIndent}{2.4em}%
                \setlength{\cv@bulletLabelGap}{0.55em}%
            }{%
                \setlength{\cv@bulletIndent}{0.667em}%
                \setlength{\cv@bulletLabelGap}{0.333em}%
            }%
            \begin{itemize}[
                label={\cv@bulletMarker}, leftmargin=\cv@bulletIndent, labelsep=\cv@bulletLabelGap,
                topsep=0pt, partopsep=0pt, parsep=0pt, itemsep=\cv@bulletGap
            ]
                #1%
            \end{itemize}
        \end{minipage}\par
    }%
}{}

\NewDocumentCommand{\cvsubentry}{O{}}{%
    \begingroup
        \cv@setEntryFields{#1}%
        \cv@ifHeading{%
            \cv@startBodyBlock
            \cv@renderHeadingRow{\cv@subentryIndent}{\cv@subentrySize}%
            % Restore parent fields, but remember that its body has started.
            \aftergroup\cv@bodyStartedtrue
        }{}%
    \endgroup
}

% Slightly stronger separator dots, at the surrounding text size.
\newcommand{\cvseparator}{\textbf{\textperiodcentered}}

\newcommand{\cvlink}[2]{\href{#1}{\textcolor{cvLink}{\textit{#2}}}}

% ============================================================================
% 6. Header fields and contact list
% ============================================================================

\newcommand{\cv@name}{}
\newcommand{\cv@headerTitle}{}
\newcommand{\cv@email}{}
\newcommand{\cv@phone}{}
\newcommand{\cv@website}{}
\newcommand{\cv@github}{}
\newcommand{\cv@linkedin}{}
\newcommand{\cv@googleScholar}{}
\newcommand{\cv@bio}{}
\newcommand{\cv@headerLocation}{}
\newcommand{\cv@emailLabel}{Email}
\newcommand{\cv@websiteLabel}{Website}
\newcommand{\cv@githubLabel}{GitHub}
\newcommand{\cv@linkedinLabel}{LinkedIn}
\newcommand{\cv@googleScholarLabel}{Google Scholar}

\define@key{cvHeader}{name}{\def\cv@name{#1}}
\define@key{cvHeader}{title}{\def\cv@headerTitle{#1}}
\define@key{cvHeader}{email}{\def\cv@email{#1}}
\define@key{cvHeader}{phone}{\def\cv@phone{#1}}
\define@key{cvHeader}{website}{\def\cv@website{#1}}
\define@key{cvHeader}{github}{\def\cv@github{#1}}
\define@key{cvHeader}{linkedin}{\def\cv@linkedin{#1}}
\define@key{cvHeader}{google-scholar}{\def\cv@googleScholar{#1}}
\define@key{cvHeader}{bio}{\def\cv@bio{#1}}
\define@key{cvHeader}{location}{\def\cv@headerLocation{#1}}
\define@key{cvHeader}{email-label}{\def\cv@emailLabel{#1}}
\define@key{cvHeader}{website-label}{\def\cv@websiteLabel{#1}}
\define@key{cvHeader}{github-label}{\def\cv@githubLabel{#1}}
\define@key{cvHeader}{linkedin-label}{\def\cv@linkedinLabel{#1}}
\define@key{cvHeader}{google-scholar-label}{\def\cv@googleScholarLabel{#1}}

\newcommand{\cvheader}[1]{\setkeys{cvHeader}{#1}}
\@onlypreamble\cvheader

\newcommand{\cv@contacts}{}
\newcommand{\cv@phoneURI}{}
\newif\ifcv@headerLineStarted

% Append separators only between contacts that actually exist.
\newcommand{\cv@appendContact}[1]{%
    \cv@ifEmpty\cv@contacts{}{%
        \appto\cv@contacts{\quad\cvseparator\quad}%
    }%
    \appto\cv@contacts{\mbox{#1}}%
}

\newcommand{\cv@contactIcon}[1]{%
    \ifbool{cv@showContactIcons}{\textcolor{cvContactIcon}{#1}\enspace}{}%
}

% Arguments: stored field, icon, URL, display label.
\newcommand{\cv@addLinkContact}[4]{%
    \cv@ifEmpty#1{}{%
        \cv@appendContact{\href{#3}{\cv@contactIcon{#2}\textcolor{cvLink}{#4}}}%
    }%
}

\newcommand{\cv@buildContacts}{%
    \let\cv@contacts\@empty
    \cv@addLinkContact\cv@email{\faEnvelope}{mailto:\cv@email}{\cv@emailLabel}%
    % Keep the displayed phone number; remove spaces only from its tel: URL.
    \edef\cv@phoneURI{\cv@phone\space}%
    \edef\cv@phoneURI{\expandafter\zap@space\cv@phoneURI\@empty}%
    \cv@addLinkContact\cv@phone{\faPhone}{tel:\cv@phoneURI}{\cv@phone}%
    \cv@addLinkContact\cv@website{\faGlobe}{\cv@website}{\cv@websiteLabel}%
    \cv@addLinkContact\cv@github{\faGithub}{\cv@github}{\cv@githubLabel}%
    \cv@addLinkContact\cv@linkedin{\faLinkedin}{\cv@linkedin}{\cv@linkedinLabel}%
    \cv@addLinkContact\cv@googleScholar{\faGraduationCap}{\cv@googleScholar}{\cv@googleScholarLabel}%
    \cv@ifEmpty\cv@headerLocation{}{%
        \cv@appendContact{\cv@contactIcon{\faMapMarker*}\cv@headerLocation}%
    }%
}

% ============================================================================
% 7. Header rendering and document initialisation
% ============================================================================

\newcommand{\cv@startHeaderLine}{%
    \ifcv@headerLineStarted\vspace{\cv@headerGap}\fi
    \cv@headerLineStartedtrue
}

% The optional bio is left-aligned below the contact row, without a title.
\newcommand{\cv@renderBio}{%
    \cv@ifEmpty\cv@bio{}{%
        \ifcv@headerLineStarted\vspace{\cv@bioGap}\fi
        \parbox{\linewidth}{%
            \raggedright\cv@setTextSize{\cv@bioSize}\cv@bio\par
        }\par
    }%
}

\newcommand{\cv@renderHeader}{%
    \begin{center}
        \cv@headerLineStartedfalse
        \cv@ifEmpty\cv@name{}{%
            \cv@startHeaderLine
            {\cv@setTextSize{\cv@nameSize}\scshape\cv@name\par}%
        }%
        \cv@ifEmpty\cv@headerTitle{}{%
            \cv@startHeaderLine
            {\cv@headerTitle\par}%
        }%
        \cv@ifEmpty\cv@contacts{}{%
            \cv@startHeaderLine
            {\cv@setTextSize{\cv@contactSize}\cv@contacts\par}%
        }%
        \cv@renderBio
    \end{center}%
}

% An entirely empty header must not create an empty centre environment.
\newcommand{\makecvheader}{%
    \begingroup
        \cv@buildContacts
        \cv@ifEmpty\cv@name{%
            \cv@ifEmpty\cv@headerTitle{%
                \cv@ifEmpty\cv@contacts{%
                    \cv@ifEmpty\cv@bio{}{\cv@renderHeader}%
                }{\cv@renderHeader}%
            }{\cv@renderHeader}%
        }{\cv@renderHeader}%
    \endgroup
}

% Show the current page and total without a rule or hyperlink frame.
\fancypagestyle{cv}{%
    \fancyhf{}%
    \renewcommand{\headrulewidth}{0pt}%
    \renewcommand{\footrulewidth}{0pt}%
    \fancyfoot[C]{%
        \normalfont\cv@setTextSize{\cv@footerSize}%
        page \thepage\ of \pageref*{LastPage}%
    }%
}

\AtBeginDocument{%
    \cv@applyLayoutSpacing
    \renewcommand{\familydefault}{\cv@fontFamily}%
    \renewcommand{\rmdefault}{\cv@fontFamily}%
    \renewcommand{\normalsize}{\cv@setTextSize{\cv@bodySize}}%
    \normalfont\normalsize
    \ifbool{cv@showPageNumbers}{\pagestyle{cv}}{\pagestyle{empty}}%
    \hypersetup{pdfauthor={\cv@name},pdftitle={\cv@documentTitle}}%
}
