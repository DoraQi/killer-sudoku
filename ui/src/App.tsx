import { useEffect, useState } from 'react';
import './App.css'
import KillerSudoku from './components/KillerSudoku';

const initialBoard = Array(9).fill(null).map(() => Array(9).fill({ value: '', cageId: null }));


function App() {
  const [board, setBoard] = useState(initialBoard);
  const [cages, setCages] = useState([])
  const [loading, setLoading] = useState(true);
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
  }, []);

  return (
    <div>
      <h1>Killer Sudoku</h1>
      {loading ? (
        <div className="loading-wheel">Loading...</div>
      ) : (
        <KillerSudoku
          board={board}
          setBoard={(board: { value: string, cageId: number }[][]) => setBoard(board)}
          cages={cages}
        />
      )}
    </div>
  )
}

export default App
