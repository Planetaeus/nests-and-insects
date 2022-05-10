:- module(styles, [style_part/3
                  ]).

:-use_module(configuration).

/** <module> Style document parts' titles.

*/


%!      style_part(+Line,+Width,-Styled) is det.
%
%       Style a document part: the title of a Chapter, Section etc.
%
%       Line is an atom representing a line of text, beginning with a
%       part tag, one of: '\\chapter{T}', '\\section{T}',
%       '\\subsection{T}', '\\subsubsection{T}', '\\paragraph{T}', where
%       T is the title of the relevant part.
%
%       Width is the width of the page on which the document part is to
%       be placed and aligned either center- or left-.
%
%       Styled is the part in Line styled according to its kind. The
%       style of document parts is determined by the predicate styles/2.
%       If the part is to be underlined the kind of underline is
%       determined by line/2.
%
style_part(L,W,Ls):-
        document_part(L,P,T)
        ,configuration:styles(P,Ss)
        ,line_styles(Ss,LS,Ss_)
        ,style_part(T,Ss_,W,L_)
        ,(   LS = nil
         ->  Ls = [L_]
         ;   configuration:line(LS,C)
            ,underline(T,C,U)
            ,style_part(U,Ss_,W,U_)
            ,Ls = [L_,U_]
         ).

%!      style_part(+Line,+Styles,+Width,-Styled) is det.
%
%       Business end of style_part/3.
%
style_part(L,[],_W,L):-
        !.
style_part(L,[S|Ss],W,Bind_L):-
        memberchk(S,[emphasize,capitalise])
        ,!
        ,S_ =.. [S,L,L_]
        ,call(S_)
        ,style_part(L_,Ss,W,Bind_L).
style_part(L,[S|Ss],W,Bind_L):-
        configuration:line(S,C)
        ,!
        ,split_string(L,' ',' ',[L_])
        ,S_ =.. [S,L_,C,U]
        ,call(S_)
        ,style_part(U,Ss,W,Bind_L).
style_part(L,[S|Ss],W,Bind_L):-
        !
        ,memberchk(S,[center,left_align])
        ,S_ =.. [S,L,W,L_]
        ,call(S_)
        ,style_part(L_,Ss,W,Bind_L).


%!      line_styles(+Styles,-Line,-Other) is det.
%
%       Separate underlining styles from Other styles.
%
%       Underline styles are implemented in a two-step approach: first
%       the text to be underlined is styled, for example to align it on
%       the page. Then an underline is created and further styled,
%       particularly to align it, if necessary.
%
line_styles(Ss,S,Ss_):-
        configuration:line(S,_)
        ,selectchk(S,Ss,Ss_)
        ,!.
line_styles(Ss,nil,Ss).


%!      document_part(+Line,-Part,-Title) is det.
%
%       Identify a document Part and return its Title.
%
%       Used to determine whether Line starts with a document part tag,
%       and which one if so.
%
document_part(L,P_,T_):-
        atom_concat('\\',P,L)
        ,atom_chars(P,Cs)
        ,once(phrase(part(P_,T),Cs))
        ,atomic_list_concat(T,'',T_).


%!      part// is nondet.
%
%       Identify a document part tag.
%
part(chapter,T) --> [c,h,a,p,t,e,r], ['{'], string(T), ['}'].
part(title,T) --> [t,i,t,l,e], ['{'], string(T), ['}'].
part(section,T) --> [s,e,c,t,i,o,n], ['{'], string(T), ['}'].
part(subsection,T) --> [s,u,b,s,e,c,t,i,o,n], ['{'], string(T), ['}'].
part(subsubsection,T) --> [s,u,b,s,u,b,s,e,c,t,i,o,n], ['{'], string(T), ['}'].
part(paragraph,T) --> [p,a,r,a,g,r,a,p,h], ['{'], string(T), ['}'].

string([S|Ss]) --> [S], string(Ss).
string([S]) --> [S].


%!      center(+Line,+Width,-Centered) is det.
%
%       Format a Line of text to be Center-aligned.
%
%       Line is an atom representing a line of text.
%
%       Width is the width of the page, in columns, where Line is to be
%       centered.
%
%       Centered is Line formatted as an atom padded with the requisite
%       number of spaces to center-align it on a page with the given
%       Width.
%
center(L,W,L_):-
        format(atom(L_),'~t~w~t~*+',[L,W]).


%!      left_align(+Line,+Width,-Aligned) is det.
%
%       Format a Line of text to be Left-Aligned.
%
%       Line is an atom representing a line of text.
%
%       Width is the width of the page, in columns, where Line is to be
%       centered.
%
%       Left-Aligned is Line, formatted as an atom padded right with the
%       requisite number of spaces to left-align it on a page with the
%       given Width.
%
left_align(L,W,L_):-
        format(atom(L_),'~w~t~*|',[L,W]).


%!      dunderline(+Line,+Character,-Underlined) is det.
%
%       Double-underline a Line of text.
%
%       Line is an atom representing a line of text.
%
%       Character is the (atomic) character to use to underline Line.
%
%       Underlined is the Line, underlined with Character.
%
%       @tbd This is just a thin shell around underline/3. It's the
%       user's responsiblity to make sure that Character is a
%       double-underline character. This predicate only exists for the
%       semantic conveniencd of remembering to pass the right character
%       to underline/3.
%
dunderline(L,C,U):-
        underline(L,C,U).


%!      underline(+Line,+Character,-Underlined) is det.
%
%       Create an underline spanning the length of a Line of text.
%
%       Line is an atom representing a line of text. It should not be
%       padded with spaces, for example to left- or center-align the
%       text, unless the space must also be underlined.
%
%       Character is the character with which to create the underline.
%
%       Underlined is an underline of Line: an atom consisting of
%       Character repeated as many times as the atomic length of Line.
%
underline(L,C,U):-
        atom_length(L,N)
        ,atom_codes(C,[D])
        ,format(atom(U),'~*t~*+',[D,N]).


%!      emphasize(+Line,-Emphasized) is det.
%
%       Format a Line of text to emphasize it.
%
%       Line is an atom representing a line of text that is to be
%       emphasized.
%
%       Emphasized is Line, surrounded by the emphasis characters (an
%       _underscore_ for now).
%
emphasize(L,L_):-
        format(atom(L_),'_~w_',[L]).


%!      capitalise(+Line,-Capitalised) is det.
%
%       Format a Line of text to be ALL CAPITALS YAAAAH!!
%
%       Line is an atom representing a line of text to be capitalised.
%
%       Capitalised is Line, with all characters changed to their
%       capitals.
%
capitalise(L,L_):-
        upcase_atom(L,L_).

