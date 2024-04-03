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
% :- http_handler('/api/sudoku/verify-puzzle', serve_verify_soln, []).


serve_ping(Request) :-
    reply_json_dict(_{status: "ok"}).

reply_json_dict(Dict) :-
    reply_json(Dict, [json_object(dict)]).

% Serve the new sudoku puzzle.

% serve_new_sudoku(Request) :-
%     new_sudoku_puzzle(Puzzle),
%     reply_json_dict(Puzzle).


% % Serve the solution verification.
% serve_verify_soln(Request) :-
%     http_read_json_dict(Request, JSON),
%     verify_sudoku_soln(JSON, Result),
%     reply_json_dict(Result).



serve_static(Request) :-
    http_404([], Request).

% Predicate to start the server.
serve(Port) :-
    http_server(http_dispatch, [port(Port)]).

% Predicate to stop the server.
stop(Port) :-
    http_stop_server(Port, []).
