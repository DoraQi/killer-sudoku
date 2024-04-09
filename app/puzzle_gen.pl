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

init_cages_with_sums(Board, Cages) :-
    findall(
		cage{cageId: ID, cells: [R-C], sum: Sum}, 
		(	
			between(0, 8, R), 
			between(0, 8, C), 
			ID is R * 9 + C, 
			nth0(R, Board, Row),
			nth0(C, Row, Sum)
		),
		Cages
	).

generate_merged_cages(0, Cages, Cages).
generate_merged_cages(N, Cages, MergedCages) :-
	findall(Row-Col, (between(0, 8, Row), between(0, 8, Col)), Cells),
	merge_cage_cells(Cells, Cages, MidMergeCages),
	N1 is N - 1,
	generate_merged_cages(N1, MidMergeCages, MergedCages).

merge_cage_cells([], Cages, Cages).
merge_cage_cells([Row-Col|Cells], Cages, MergedCages) :-
	merge_cage_cell(Row, Col, Cages, MidMergeCages),
	merge_cage_cells(Cells, MidMergeCages, MergedCages).

merge_cage_cell(Row, Col, Cages, MergedCages) :-
	% Find a cage from Row-Col
	member(Cage, Cages),
	member(Row-Col, Cage.cells),
	% verify there is only one cage that contains the cell
	findall(C, (member(C, Cages), member(Row-Col, C.cells)), [Cage], _),
	% Get all adjacent cages, that are not the same cage
	findall(
		AdjCage, 
		(
			between(0, 8, AdjRow),
			between(0, 8, AdjCol),
			adjacent_cell(Row, Col, AdjRow, AdjCol),
			member(AdjCage, Cages),
			member(AdjRow-AdjCol, AdjCage.cells),
			AdjCage \= Cage
		),
		AdjCages
	),
	% Merge the cages
	merge_cage_with_adjacent(Cage, AdjCages, Cages, MergedCages).

adjacent_cell(Row, Col, Row, AdjCol) :- abs(Col - AdjCol) =:= 1.
adjacent_cell(Row, Col, AdjRow, Col) :- abs(Row - AdjRow) =:= 1.

merge_cage_with_adjacent(_, [], Cages, Cages).
merge_cage_with_adjacent(Cage, [AdjacentCage|Rest], Cages, MergedCages) :-
	length(Cage.cells, CurrCageSize),
	length(AdjacentCage.cells, AdjCageSize),
	NewCageSize is CurrCageSize + AdjCageSize,
	% Merge with probability of 10%
	TopProb is 9 * NewCageSize,
	random(0, TopProb, P),
	(NewCageSize =< 9, P =:= 0 ->
		% Merge the cages
		merge_cage_pair(Cage, AdjacentCage, Cages, MidMergedCages),
		merge_cage_with_adjacent(Cage, Rest, MidMergedCages, MergedCages);
		% Skip the merge
		merge_cage_with_adjacent(Cage, Rest, Cages, MergedCages)
	).

merge_cage_pair(Cage1, Cage2, Cages, MergedCages) :-
	% Merge the cells
	append(Cage1.cells, Cage2.cells, NewCells),
	NewSum is Cage1.sum + Cage2.sum,
	% Remove the old cages
	select(Cage1, Cages, TempCages),
	select(Cage2, TempCages, TempCages2),
	% Create the new cage
	NewCage = cage{cageId: Cage1.cageId, cells: NewCells, sum: NewSum},
	% Add the new cage
	append(TempCages2, [NewCage], MergedCages).

generate_killer_sudoku_cages(Result) :-
	generate_sudoku(Board),
	init_cages_with_sums(Board, Cages),
	generate_merged_cages(3, Cages, Result).
