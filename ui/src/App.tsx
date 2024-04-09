import { useEffect, useState } from 'react';
import './App.css'
import KillerSudoku from './components/KillerSudoku';
import Button from './components/Button';

const initialBoard = Array(9).fill(null).map(() => Array(9).fill({ value: '', cageId: null }));


function App() {
  const [board, setBoard] = useState(initialBoard);
  const [cages, setCages] = useState([])
  const [loading, setLoading] = useState(true);
  const [reload, setReload] = useState(false);
  useEffect(() => {
    fetch('/api/killer-sudoku/generate', {
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

  const getCageMatrix = (cages: { cageId: number, cells: number[][], sum: number }[]) => {
    const cageMatrix = Array(9).fill(null).map(() => Array(9).fill(null));
    cages.forEach((cage, newIndex) => {
      cage.cells.forEach(cell => {
        cageMatrix[cell[0]][cell[1]] = newIndex;
      });
    });
    return cageMatrix;
  }
  const getCageValues = (cages: { cageId: number, cells: number[][], sum: number }[]) => {
    // Put all sums of cages into array sorted by cageId
    const cageIdPairs = cages.map(cage => [cage.cageId, cage.sum]);
    cageIdPairs.sort((a, b) => a[0] - b[0]);
    return cageIdPairs.map(pair => pair[1]);
  }

  const verifyBoard = () => {
    const cageMatrix = getCageMatrix(cages);
    const cageValues = getCageValues(cages);
    fetch('/api/killer-sudoku/verify-puzzle', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Referrer-Policy': 'unsafe-url'
      },
      body: JSON.stringify({
        board: board.map(row => row.map(cell => {
          if (cell.value === '') {
            return 0;
          }
          return parseInt(cell.value);
        })),
        cages: cageMatrix,
        cagevalues: cageValues,
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

  return (
    <div>
      <h1>Killer Sudoku</h1>
      {loading ? (
        <div className="loading-wheel">Loading...</div>
      ) : (
        <div>
          <div className={"buttonRow"}>
            <Button buttonText="Reset Entries" onClick={() => { setBoard(initialBoard) }} />
            <Button buttonText="Generate New Board" onClick={() => { setReload(!reload) }} />
            <Button buttonText="Verify Solution" onClick={verifyBoard} />
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
