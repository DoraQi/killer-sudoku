import { useState } from 'react';
import './App.css'
import KillerSudoku from './components/KillerSudoku';

const initialBoard = Array(9).fill(null).map(() => Array(9).fill({ value: '', cageId: null }));
const cages = [
  { sum: 15, cells: [[0, 0], [0, 1], [1, 0]] },
  { sum: 3, cells: [[0, 2], [1, 1], [1, 2]] },
  { sum: 6, cells: [[0, 3], [0, 4]] },
  { sum: 12, cells: [[0, 5], [1, 5], [1, 4]] },
  { sum: 14, cells: [[0, 6], [0, 7], [1, 6]] },
  { sum: 2, cells: [[0, 8]] },
  { sum: 7, cells: [[1, 3]] },
  { sum: 14, cells: [[1, 7], [2, 7]] },
  { sum: 2, cells: [[1, 8], [2, 8]] },
  { sum: 14, cells: [[2, 0], [2, 1], [3, 0]] },
  { sum: 8, cells: [[2, 2], [3, 2]] },
  { sum: 16, cells: [[2, 3], [2, 4], [3, 3], [3, 4]] },
  { sum: 10, cells: [[2, 5], [2, 6]] },
  { sum: 13, cells: [[3, 1], [4, 1]] },
  { sum: 12, cells: [[3, 5], [4, 5], [4, 4]] },
  { sum: 2, cells: [[3, 6], [3, 7]] },
  { sum: 8, cells: [[3, 8]] },
  { sum: 9, cells: [[4, 0], [5, 0]] },
  { sum: 7, cells: [[4, 2], [5, 2]] },
  { sum: 13, cells: [[4, 3], [5, 3]] },
  { sum: 2, cells: [[4, 6], [4, 7]] },
  { sum: 3, cells: [[4, 8], [5, 8], [5, 7]] },
  { sum: 17, cells: [[5, 1], [6, 1], [5, 4], [5, 5], [5, 6]] },
  { sum: 6, cells: [[6, 0], [7, 0]] },
  { sum: 5, cells: [[6, 2]] },
  { sum: 19, cells: [[6, 3], [7, 3], [6, 4], [6, 5], [6, 6], [6, 7]] },
  { sum: 12, cells: [[6, 8], [7, 7], [7, 8]] },
  { sum: 17, cells: [[7, 1], [7, 2], [8, 1], [8, 2], [8, 3]] },
  { sum: 10, cells: [[7, 4], [7, 5], [7, 6]] },
  { sum: 3, cells: [[8, 0]] },
  { sum: 4, cells: [[8, 4], [8, 5]] },
  { sum: 3, cells: [[8, 6]] },
  { sum: 5, cells: [[8, 7]] },
  { sum: 4, cells: [[8, 8]] }
];


function App() {
  const [board, setBoard] = useState(initialBoard);
  return (
    <div>
      <h1>Killer Sudoku</h1>
      <KillerSudoku
        board={board}
        setBoard={(board: { value: string, cageId: number }[][]) => setBoard(board)}
        cages={cages}
      />
    </div>
  )
}

export default App
