import { useEffect, useState } from 'react';
import './App.css'
import KillerSudoku from './components/KillerSudoku';
import Button from './components/Button';

const initialBoard = Array(9).fill(null).map(() => Array(9).fill({ value: '', cageId: null }));

function checkSolution(board: { value: string, cageId: number }[][], cages: { cageId: number, cells: number[][], sum: number }[]) {
  // copy values in board to a 2D array of integers
  const boardValues = board.map(row => row.map(cell => parseInt(cell.value) || 0));
  // copy cageId in board to a 2D array of integers
  const boardCageIds = board.map(row => row.map(cell => cell.cageId));
  // print boardValues and boardCageIds
  console.log("boardValue=", boardValues);
  console.log("boardCageIds=", boardCageIds);
  // store cages sorted by cageId
  const cagesById = cages.slice().sort((a, b) => a.cageId - b.cageId);
  // store the sum of each cage into an array
  const cageSums = cagesById.map(cage => cage.sum);

  // call http://localhost:8000/api/killer-sudoku/verify-solution with the boardValues and boardCageIds and cageSums
  fetch('http://localhost:8000/api/killer-sudoku/verify-puzzle', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({
      board: boardValues,
      cages: boardCageIds,
      cagevalues: cageSums
    })
  })
    .then(response => {
      if (!response.ok) {
        throw new Error('Failed to fetch');
      }
      return response.json();
    })
    .then(data => {
      if (data.valid) {
        alert('Solution is correct!');
      } else {
        alert('Solution is incorrect!');
      }
    });
}

function App() {
  const [board, setBoard] = useState(initialBoard);
  const [cages, setCages] = useState([])
  const [loading, setLoading] = useState(true);
  const [reload, setReload] = useState(false);
  useEffect(() => {
    fetch('http://localhost:8000/api/killer-sudoku/generate', {
      method: 'GET',
    })
      .then(response => {
        if (!response.ok) {
          throw new Error('Failed to fetch');
        }
        return response.json();
      })
      .then(data => {
        setCages(data);
        setLoading(false);
      });
  }, [reload]);

  return (
    <div>
      <h1>Killer Sudoku</h1>
      {loading ? (
        <div className="loading-wheel">Loading...</div>
      ) : (
        <div style={
          {
            display: 'flex',
            flexDirection: 'column',
            alignItems: 'center',
            justifyContent: 'center',
            height: '100%',
            padding: '4rem'
          }

        }>
          <div className={"buttonRow"}>
            <Button buttonText="Reset Entries" onClick={() => { setBoard(initialBoard) }} />
            <Button buttonText="Generate New Board" onClick={() => { setReload(!reload) }} />
            <Button buttonText="Check Solution" onClick={() => { checkSolution(board, cages) }} />
          </div>
          <KillerSudoku
            board={board}
            setBoard={(board: { value: string, cageId: number }[][]) => setBoard(board)}
            cages={cages}
          />
        </div>
      )}
    </div>
  )
}

export default App
