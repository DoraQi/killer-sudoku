
import "./Button.css"

export default function Button({ onClick, buttonText }: { onClick: () => void, buttonText: string }) {
    return (
        <button className={"killerSudokuButton"} onClick={onClick}>{buttonText}</button>
    )
}