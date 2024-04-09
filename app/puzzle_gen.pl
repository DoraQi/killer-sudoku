:- use_module(library(random)).
:- use_module(library(clpfd)).
:- use_module(library(assoc)).

% Generate a random  solved sudoku board

generate_sudoku(Rows) :-
	length(Rows, 9), 
	maplist(
		same_length(Rows), Rows), 
	append(Rows, Vs), Vs ins 1..9, 
	maplist(all_distinct, Rows), 
	transpose(Rows, Columns), 
	maplist(all_distinct, Columns), Rows = [As, Bs, Cs, Ds, Es, Fs, Gs, Hs, Is], 
	blocks(As, Bs, Cs), 
	blocks(Ds, Es, Fs), 
	blocks(Gs, Hs, Is), 
	random_permutation(Vs, ShuffledVs), % Shuffle the list of variables
	
	labeling([ffc], ShuffledVs).% Label variables with ffc heuristic
	
	blocks([], [], []).

blocks([N1, N2, N3|Ns1], [N4, N5, N6|Ns2], [N7, N8, N9|Ns3]) :-
	all_distinct([N1, N2, N3, N4, N5, N6, N7, N8, N9]), 
	blocks(Ns1, Ns2, Ns3).

initialize_cages(Board, Cages) :-
    empty_assoc(EmptyCages),
    flatten(Board, AllCells),
    length(AllCells, TotalCells),
    numlist(1, TotalCells, CageIndices),  % Generate a list of unique indices
    initialize_cages(Board, 1, 1, CageIndices, EmptyCages, Cages).

initialize_cages([], _, _, [], Cages, Cages).
initialize_cages([Row|Rows], RowIndex, ColIndex, [CageIndex|CageIndices], CagesIn, CagesOut) :-
    initialize_cages_row(Row, RowIndex, ColIndex, [CageIndex|CageIndices], CagesIn, CagesNext, RemainingCageIndices),
    RowIndexNext is RowIndex + 1,
    initialize_cages(Rows, RowIndexNext, 1, RemainingCageIndices, CagesNext, CagesOut).

initialize_cages_row([], _, _, CageIndices, Cages, Cages, CageIndices).
initialize_cages_row([Cell|Cells], RowIndex, ColIndex, [CageIndex|CageIndices], CagesIn, CagesOut, RemainingCageIndices) :-
    Key = RowIndex-ColIndex,
    NewCage = cage{sum:Cell, cells:[Key], cageId:CageIndex},
    put_assoc(Key, CagesIn, NewCage, CagesNext),
    ColIndexNext is ColIndex + 1,
    initialize_cages_row(Cells, RowIndex, ColIndexNext, CageIndices, CagesNext, CagesOut, RemainingCageIndices).


merge_cage_iters(0, Cages, Cages).
merge_cage_iters(N, CagesIn, CagesOut) :-
	% generate positions from 1-1 to 9-9
	findall(Row-Col, (between(1, 9, Row), between(1, 9, Col)), Positions),
	merge_cage_iter(Positions, CagesIn, CagesMid),
	N1 is N - 1,
	merge_cage_iters(N1, CagesMid, CagesOut).


% Process each position one by one for merging
merge_cage_iter([], Cages, Cages).
merge_cage_iter([Row-Col|Tail], CagesIn, CagesOut) :-
    get_assoc(Row-Col, CagesIn, Cage),
    merge_cage(Row, Col, Cage, CagesIn, CagesMid),
    merge_cage_iter(Tail, CagesMid, CagesOut).

% Merge a single cage at a given position with its neighbors
merge_cage(Row, Col, Cage, CagesIn, CagesOut) :-
    findall(AdjacentRow-AdjacentCol,
            (
				adjacent(Row, Col, AdjacentRow, AdjacentCol),
				get_assoc(AdjacentRow-AdjacentCol, CagesIn, AdjacentCage),
				AdjacentCage \= Cage),
            AdjacentPositions),
    merge_adjacent_cages(Cage, AdjacentPositions, CagesIn, CagesOut).

% Merge all adjacent cages with the current cage
merge_adjacent_cages(_, [], Cages, Cages).
merge_adjacent_cages(Cage, [AdjPos|AdjPoses], CagesIn, CagesOut) :-
    get_assoc(AdjPos, CagesIn, AdjacentCage),
	% randomly merge the cages
	merge_cage_pair(Cage, AdjacentCage, CagesIn, CagesMid),
    merge_adjacent_cages(Cage, AdjPoses, CagesMid, CagesOut).

% Merge two cages into one
% Merge two cages into one
merge_cage_pair(Cage1, Cage2, CagesIn, CagesOut) :-
	% with 10% probability, merge the cages
	length(Cage1.cells, Cage1Size),
	length(Cage2.cells, Cage2Size),
	(
		Cage1Size + Cage2Size > 9 -> 
		CagesOut = CagesIn;
		true
	),
	(
		Cage1Size + Cage2Size > 2 -> 
		TopBound is 10 * (Cage1Size + Cage2Size);
		TopBound is 2
	),
	random(0, TopBound, R),
	(R < 1 -> 
    Cage1Pos = Cage1.cells, 
    Cage2Pos = Cage2.cells,
    NewSum is Cage1.sum + Cage2.sum,
    append(Cage1Pos, Cage2Pos, NewCells),
    NewCage = cage{sum: NewSum, cells: NewCells, cageId: Cage1.cageId},
	set_new_cage_assoc(NewCells, NewCage, CagesIn, CagesOut);
	CagesOut = CagesIn).

set_new_cage_assoc([], _, Cages, Cages).
set_new_cage_assoc([Cell|Cells], NewCage, CagesIn, CagesOut) :-
	put_assoc(Cell, CagesIn, NewCage, CagesMid),
	set_new_cage_assoc(Cells, NewCage, CagesMid, CagesOut).

adjacent(Row, Col, AdjRow, AdjCol) :- AdjRow is Row - 1, AdjCol is Col.
adjacent(Row, Col, AdjRow, AdjCol) :- AdjRow is Row + 1, AdjCol is Col.
adjacent(Row, Col, AdjRow, AdjCol) :- AdjRow is Row, AdjCol is Col - 1.
adjacent(Row, Col, AdjRow, AdjCol) :- AdjRow is Row, AdjCol is Col + 1.


generate_killer_sudoku_cages(FinalCages) :-
	generate_sudoku(Board),
	initialize_cages(Board, CagesIn),
	merge_cage_iters(3, CagesIn, Cages),
	assoc_to_list(Cages, CageList),
    maplist(cage_id_pair, CageList, CageIdPairs),
    predsort(compare_cage_id, CageIdPairs, SortedCageIdPairs),
    remove_consecutive_duplicates(SortedCageIdPairs, UniqueCageIdPairs),
	maplist(cage_id_pair_to_cage, UniqueCageIdPairs, FinalCages).

cage_id_pair_to_cage(_-Cage, Cage).

cage_id_pair(_-Cage, CageId-Cage) :-
	CageId = Cage.cageId.

compare_cage_id(Delta, CageId1-_, CageId2-_) :-
    compare(Delta, CageId1, CageId2).

remove_consecutive_duplicates([], []).
remove_consecutive_duplicates([X], [X]).
remove_consecutive_duplicates([X, X|Xs], Ys) :-
    remove_consecutive_duplicates([X|Xs], Ys).
remove_consecutive_duplicates([X, Z|Xs], [X|Ys]) :-
    X \= Z,
    remove_consecutive_duplicates([Z|Xs], Ys).

print_killer_sudoku_cages(Cages) :-
	maplist(print_killer_sudoku_cage, Cages).

print_killer_sudoku_cage(Cage) :-
	format('Cage ~w: ~w~n', [Cage.cageId, Cage]).