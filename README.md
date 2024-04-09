# Killer Sudoku

This is a web application to generate, verify solution for, and solve killer-sudoku puzzles.



## Running the application
Start the servers and go to http://localhost:5173/

### Prolog server
To start the server, run in root directory:
```
swipl run.pl
```
To stop:
```
?- stop(8000)
```



### Web server
To start the server, run in `ui`:
```
npm run dev
```



## Resources used
Server is based off of https://github.com/lloydtao/prolog-web-application

Referenced the sudoku example in https://github.com/triska/clpz