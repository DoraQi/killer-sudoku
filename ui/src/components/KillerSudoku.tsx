// Board.tsx
import './KillerSudoku.css';

export interface KillerSudokuProps {
    board: { value: string, cageId: number }[][];
    setBoard: (board: { value: string, cageId: number }[][]) => void;
    cages: { cageId: number, cells: number[][], sum: number }[];
}


// Assuming each cell in the board is an object with a value and cage id
export default function KillerSudoku({ board, setBoard, cages }: KillerSudokuProps) {
    // Assign each cage an id 
    console.log(cages);
    cages = structuredClone(cages);
    cages = cages.map((cage) => {
        // Subtrace 1 from the index to make the ids 0-based
        cage.cells = cage.cells.map(cell => [cell[0] - 1, cell[1] - 1]);
        return cage;
    })
    console.log(cages);
    const cageMap = cages.reduce((acc, cage) => {
        cage.cells.forEach(cell => {
            acc[`${cell[0]}-${cell[1]}`] = cage.cageId;
        });
        return acc;
    }, {} as { [key: string]: number });
    const colorMap = {} as { [key: number]: string };


    const getCageIdByCell = (row: number, col: number) => cageMap[`${row}-${col}`];

    const handleChange = (row: number, col: number, value: string) => {
        const newBoard = board.map(row => row.map(cell => ({ ...cell })));
        if (/^[1-9]?$/.test(value)) {
            newBoard[row][col].value = value;
        }
        setBoard(newBoard);
    };

    const findCageByCell = (row: number, col: number) => {
        return cages.find(cage => cage.cells.some(cell => cell[0] === row && cell[1] === col));
    }


    return (
        <div className={"board"}>
            {
                Array.from({ length: 9 }, (_, i) => i).map(boxNum => (
                    <div className="box">
                        {Array.from({ length: 9 }, (_, i) => i).map(i => {
                            const row = Math.floor(boxNum / 3) * 3 + Math.floor(i / 3);
                            const col = (boxNum % 3) * 3 + (i % 3);
                            const cage = findCageByCell(row, col);
                            if (!cage) {
                                throw new Error(`Cage not found for cell ${boxNum}-${i}`);
                            }
                            // Assign the cell color depending on the cage id
                            // We want to use 5 colors, and assign them to the cages to ensure that no two cages with the same color are adjacent
                            const colors = ["#FFCCCC", "#CCFFCC", "#CCCCFF", "#FFFFCC", "#FFCCFF"];
                            let cageColor = colorMap[cage.cageId];
                            if (!cageColor) {
                                const adjacentCageColors = [] as string[];
                                for (i = 0; i < cage.cells.length; i++) {
                                    const cell = cage.cells[i];
                                    const currRow = cell[0];
                                    const currCol = cell[1];
                                    adjacentCageColors.push(colorMap[getCageIdByCell(currRow - 1, currCol)]);
                                    adjacentCageColors.push(colorMap[getCageIdByCell(currRow, currCol - 1)]);
                                    adjacentCageColors.push(colorMap[getCageIdByCell(currRow + 1, currCol)]);
                                    adjacentCageColors.push(colorMap[getCageIdByCell(currRow, currCol + 1)]);
                                }
                                const availableColors = colors.filter(color => !adjacentCageColors.includes(color));
                                cageColor = availableColors[cage.cageId % availableColors.length];
                                colorMap[cage.cageId] = cageColor;
                            }
                            const cellStyle = {
                                backgroundColor: cageColor,
                            };
                            // If it is the top leftmost cell, add a label in the top left corner
                            const cageLabel = cage.cells[0][0] === row && cage.cells[0][1] === col ? cage.sum : '';

                            return (
                                <div className={"cell"} style={cellStyle}>
                                    <>
                                        <div className={"cageLabel"}>{cageLabel}</div>
                                        <input
                                            type="text"
                                            maxLength={1}
                                            value={board[row][col].value}
                                            onChange={(e) => handleChange(row, col, e.target.value)}
                                            className={"cellInput"}
                                        />
                                    </>
                                </div>
                            )
                        })}
                    </div>
                ))
            }
        </div>
    );
}

