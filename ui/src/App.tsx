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
        <div>
          <div className={"buttonRow"}>
            <Button buttonText="Reset Entries" onClick={() => { setBoard(initialBoard) }} />
            <Button buttonText="Generate New Board" onClick={() => { setReload(!reload) }} />
            <Button buttonText="Check Solution" onClick={() => { alert('Checking solution') }} />
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
