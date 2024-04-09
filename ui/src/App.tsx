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
  const [difficulty, setDifficulty] = useState("easy");

  useEffect(() => {
    const dif: { [key: string]: number } = {
      "super_easy": 0,
      "easy": 1,
      "medium": 2,
      "hard": 3
    };
    const difficultyNum = dif[difficulty];
    fetch(`/api/killer-sudoku/generate?difficulty=${difficultyNum}`, {
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
        setBoard(initialBoard);
        setLoading(false);
      });
  }, [reload, difficulty]);

  const getCageMatrix = (cages: { cageId: number, cells: number[][], sum: number }[]) => {
    const cageMatrix = Array(9).fill(null).map(() => Array(9).fill(null));
    const sortedCages = [...cages].sort((a, b) => a.cageId - b.cageId);
    sortedCages.forEach((cage, newIndex) => {
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
        'Content-Type': 'application/json'
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
        if (data.status === "ok") {
          alert('Solution is correct!');
        } else {
          alert('Solution is incorrect!');
        }
      });
  }

  const toBoard = (data: number[][]) => {
    return data.map(row => row.map(cell => {
      return { value: cell };
    }));
  }

  const solveBoard = () => {
    const cageMatrix = getCageMatrix(cages);
    const cageValues = getCageValues(cages);
    fetch('/api/killer-sudoku/solve-puzzle', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
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
        console.log(data.solution)
        setBoard(toBoard(data.solution));
      });
  }

  const handleDifficultyChange = (event: React.ChangeEvent<HTMLSelectElement>) => {
    setDifficulty(event.target.value);
  };

  return (
    <div>
      <h1>Killer Sudoku</h1>
      {loading ? (
        <div className="loading-wheel">Loading...</div>
      ) : (
        <div style={{
          maxWidth: "100%",
        }}>
          <div className={"buttonRow"}>
            <Button buttonText="Reset Entries" onClick={() => { setBoard(initialBoard) }} />
            <Button buttonText="Generate New Board" onClick={() => { setReload(!reload) }} />
            <Button buttonText="Verify Solution" onClick={verifyBoard} />
            <Button buttonText="Solve Puzzle" onClick={solveBoard} />
            {/* select difficuluty of generated board*/}
            <select value={difficulty} onChange={handleDifficultyChange}>
              <option value="super_easy">Super Easy</option>
              <option value="easy">Easy</option>
              <option value="medium">Medium</option>
              <option value="hard">Hard</option>
            </select>
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
