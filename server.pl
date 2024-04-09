% Configures the web app.
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

% Import required HTTP modules.
:- use_module(library(http/thread_httpd)).
:- use_module(library(http/http_files)).
:- use_module(library(http/http_dispatch)).
:- use_module(library(http/http_json)).

% Load web app modules.
:- [app/init].

% Serve static files for each web app module.
:- http_handler('/api/ping', serve_ping, []).
% :- http_handler('/api/sudoku/new-puzzle', serve_new_sudoku, []).
:- http_handler('/api/sudoku/verify-puzzle', serve_verify_soln, []).
:- http_handler('/api/sudoku/solve', serve_solve, []).
:- http_handler('/api/killer-sudoku/generate', serve_generate_killer, []).


serve_ping(_) :-
    reply_json_dict(_{status: "ok"}).


% Serve the new sudoku puzzle.

% serve_new_sudoku(Request) :-
%     new_sudoku_puzzle(Puzzle),
%     reply_json_dict(Puzzle).


% % Serve the solution verification.
serve_verify_soln(Request) :-
    http_read_json_dict(Request, JSON),
    verify_sudoku_soln(JSON, Result),
    reply_json_dict(Result).

verify_sudoku_soln(JSON, Result) :-
    get_dict(board, JSON, Board),
    get_dict(cages, JSON, Cages),
    get_dict(cagevalues, JSON, CageValues),
    verify_sudoku(Board, Cages, CageValues, Result).

serve_generate_killer(_) :-
    generate_killer_sudoku_cages(Cages),
    cages_to_json(Cages, JSON),
    reply_json_dict(JSON).

cages_to_json(Cages, CagesJSON) :-
    % cages have compounds, they need to be converted to lists for JSON serialization
    maplist(cage_to_json, Cages, CagesJSON).

cage_to_json(Cage, JSON) :-
    Sum = Cage.sum,
    Cells = Cage.cells,
    CageId = Cage.cageId,
    maplist(cell_to_list, Cells, CellsList),
    JSON = _{sum: Sum, cells: CellsList, cageId: CageId}.

cell_to_list(X-Y, [X, Y]).




verify_sudoku(Board, Cages, CageValues, Result) :-
    (killer_sudoku(Board, Cages, CageValues) -> Result = _{status: "ok"};
    Result = _{status: "error"}).

% Serve the solution.
serve_solve(Request) :-
    http_read_json_dict(Request, JSON),
    solve_sudoku(JSON, Result),
    reply_json_dict(Result).

solve_sudoku(JSON, Result) :-
    get_dict(cages, JSON, Cages),
    get_dict(cagevalues, JSON, CageValues),
    solve_sudoku(Cages, CageValues, Result).

solve_sudoku(Cages, CageValues, Result) :-
    once(killer_sudoku(Board, Cages, CageValues)),
    Result = _{status: "ok", solution: Board}.

serve_static(Request) :-
    http_404([], Request).

% Predicate to start the server.
serve(Port) :-
    http_server(http_dispatch, [port(Port)]).

% Predicate to stop the server.
stop(Port) :-
    http_stop_server(Port, []).
