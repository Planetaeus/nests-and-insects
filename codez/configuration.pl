:-module(configuration, [styles/2
                        ,theorem/2
                        ,label/2
                        ,line/2
                        ]).

/** <module> Configuration options for typesetting code.

*/


%!      styles(?Part,?Styles) is semidet.
%
%       A rulebook Part and its Styles.
%
styles(chapter,[center,dunderline]).
styles(section,[center,underline]).
styles(subsection,[left_align,underline]).
styles(subsubsection,[emphasize]).
styles(paragraph,[capitalise]).


%!      theorem(?Title,?Name) is semidet.
%
%       A theorem command Title and its user-friendly Name.
%
theorem(note_reader,'Note to the reader').
theorem(example,'Example').
theorem(note,'Note').
theorem(rules_summary,'Rules Summary').


%!      label(?Type,?Name) is semidet.
%
%       A caption/ label to be counted.
%
label(table, 'Table').
label(figure, 'Figure').


%!      line(?Style,?Character) is semidet.
%
%       A line to use for underlining.
%
%       Style is the underlining style, one of "underline" or
%       "dunderline".
%
%       Character is the character to use when underlining with a line
%       of the given Style.
%
line(underline,-).
line(dunderline,=).
