
:- use_module(library(clpfd)).
:- use_module(library(lists)).
:- use_module(library(random)).

sudoku(Rows) :-
    length(Rows, 9),
    maplist(same_length(Rows), Rows),
    append(Rows, Vs), Vs ins 1..9,
    maplist(all_distinct, Rows),
    transpose(Rows, Columns),
    maplist(all_distinct, Columns),
    Rows = [As,Bs,Cs,Ds,Es,Fs,Gs,Hs,Is],
    blocks(As, Bs, Cs),
    blocks(Ds, Es, Fs),
    blocks(Gs, Hs, Is).

blocks([], [], []).
blocks([N1,N2,N3|Ns1], [N4,N5,N6|Ns2], [N7,N8,N9|Ns3]) :-
    all_distinct([N1,N2,N3,N4,N5,N6,N7,N8,N9]),
    blocks(Ns1, Ns2, Ns3).

add_elem(X, Y) :-
    random(1, 10, Z),
    append(X, Z, Y).


% complete_board(Before, After) :-
%     boards_match(Before, After),
%     maplist([In,Out]>>length(), After),
%     length(After, 9).

to_board_safe(Lst, Board) :-
    once(to_board(Lst, Board)).

% this times out on trying for more than one solution from board to lst
to_board([], []).
to_board(Lst, [Row|Board]) :-
    length(Row, 9),
    append(Row, Rest, Lst),
    to_board(Rest, Board).
to_board(Lst, Board) :-
    length(Lst, X),
    X < 9,
    append([Lst], [], Board).
    
boards_match([], []).
boards_match([H1|T1], [H2|T2]) :-
    row_match(H1, H2),
    boards_match(T1, T2).

row_match([], _).
row_match([0|T1], [_|T2]) :- 
    row_match(T1, T2).
row_match([H1|T1], [H1|T2]) :-
    row_match(T1, T2).

has_solution(Board) :-
    boards_match(Board, Sol),
    sudoku(Sol).