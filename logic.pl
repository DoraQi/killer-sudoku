
:- use_module(library(clpfd)).
:- use_module(library(lists)).
:- use_module(library(random)).

% sudoku solver, from:
% https://github.com/triska/clpz/tree/master
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

% % generates a "random" filled sudoku board
% random_filled_sudoku(1, P) :-
%     rand_fill(A),
%     rand_fill(B),
%     rand_fill(C),
%     rand_fill(D),
%     rand_fill(E),
%     rand_fill(F),
%     rand_fill(G),
%     rand_fill(H),
%     rand_fill(I),
%     rand_fill(J),
%     rand_fill(K),
%     rand_fill(L),
%     P = [[A,_,_,_,_,_,_,E,_],
%             [_,_,B,_,_,_,_,_,_],
%             [_,_,_,C,_,_,_,_,_],
%             [_,_,_,_,_,_,D,_,_],
%             [_,F,_,_,G,_,_,_,_],
%             [_,_,_,_,_,H,_,_,_],
%             [I,_,_,_,_,_,_,_,_],
%             [_,_,_,J,_,_,_,_,K],
%             [_,_,_,_,_,_,_,L,_]].

% rand_fill(X) :- 
%     random(1, 10, X).

% A killer-sudoku board is represented as: 
%   - a 9x9 2D matrix of labels representing the cage each square is in
%   - an array where i-th element is the sum of cage i

killer_sudoku(Rows, Cages, CageValues) :-
    sudoku(Rows),
    obey_cages(Rows, Cages, CageValues).

obey_cages(Rows, Cages, CageValues) :-
    generate_zero_list(81, Zeros),
    sum_cages(Rows, Cages, Zeros, Sums),
    equal(Sums, CageValues).

sum_cages([], [], Sums, Sums).
sum_cages([Row|Rest], [CRow|CRest], Sums, Sums2) :-
    sum_row(Row, CRow, Sums, Sums1),
    sum_cages(Rest, CRest, Sums1, Sums2).

sum_row([], _, Cage_sums, Cage_sums).
sum_row([X|T], [XCage|TCages], Cage_sums, Cage_sums2) :-
    update_ith(XCage, Cage_sums, X, Cage_sums1),
    sum_row(T, TCages, Cage_sums1, Cage_sums2).

% Adds X to element at index I in second parameter list -> last parameter
update_ith(0, [H|T], X, [X1|T]) :-
    X1 #= X + H.
update_ith(I, [H|T], X, [H|T2]) :-
    I1 is I-1,
    update_ith(I1, T, X, T2).

equal([], []).
equal([H1|T1], [H2|T2]) :-
    H1 = H2,
    equal(T1, T2).

generate_zero_list(0, []).
generate_zero_list(N, [0|Zeros]) :-
    N > 0,                 
    N1 is N - 1,          
    generate_zero_list(N1, Zeros). 
add_elem(X, Y) :-
    random(1, 10, Z),
    append(X, Z, Y).


% % complete_board(Before, After) :-
% %     boards_match(Before, After),
% %     maplist([In,Out]>>length(), After),
% %     length(After, 9).

% to_board_safe(Lst, Board) :-
%     once(to_board(Lst, Board)).

% % this times out on trying for more than one solution from board to lst
% to_board([], []).
% to_board(Lst, [Row|Board]) :-
%     length(Row, 9),
%     append(Row, Rest, Lst),
%     to_board(Rest, Board).
% to_board(Lst, Board) :-
%     length(Lst, X),
%     X < 9,
%     append([Lst], [], Board).
    
% boards_match([], []).
% boards_match([H1|T1], [H2|T2]) :-
%     row_match(H1, H2),
%     boards_match(T1, T2).

% row_match([], _).
% row_match([0|T1], [_|T2]) :- 
%     row_match(T1, T2).
% row_match([H1|T1], [H1|T2]) :-
%     row_match(T1, T2).

% has_solution(Board) :-
%     boards_match(Board, Sol),
%     sudoku(Sol).