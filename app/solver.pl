
:- use_module(library(clpfd)).
:- use_module(library(lists)).
:- use_module(library(random)).

% sudoku solver, from:
% https://github.com/triska/clpz/tree/master
sudoku_solve(Rows) :-
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

killer_sudoku(Rows, Cages, CageValues) :-
    sudoku_solve(Rows),
    obey_cages(Rows, Cages, CageValues),
    flatten(Rows, FlattenedRows), 
    labeling([ff], FlattenedRows).

obey_cages(Rows, Cages, CageValues) :-
    length(CageValues, L),
    generate_zero_list(L, Zeros),
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

print_list([]).
print_list([H|T]) :-
    write(H), nl,
    print_list(T).