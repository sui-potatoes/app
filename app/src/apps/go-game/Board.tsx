//

type Matrix = number[][];

/**
 * Renders a Go board.
 */
export function Board({
  size,
  data,
  turn,
  disabled,
  onClick,
  zoom = "%100",
  padding = 2,
  cellSize = 20,
}: {
  size: 9 | 13 | 19;
  data: Matrix;
  turn: 1 | 2;
  zoom?: string;
  disabled: boolean;
  padding?: number;
  cellSize?: number;
  onClick: (x: number, y: number) => void;
}) {
  const width = size * (cellSize + 1) + size * padding;

  return (
    <svg
      style={{ zoom, display: "inline-flex" }}
      className={
        (disabled ? "disabled " : " ") + (turn == 1 ? "black" : "white")
      }
      width={width}
      height={width}
    >
      <defs>
        <pattern
          id="grid"
          width={cellSize + padding}
          x={cellSize / 2}
          y={cellSize / 2}
          height={cellSize + padding}
          patternUnits="userSpaceOnUse"
        >
          <path
            d="M 40 0 L 0 0 0 40"
            fill="none"
            stroke="gray"
            strokeWidth="1"
          />
        </pattern>
      </defs>
      <rect
        width={width - cellSize * 1.5}
        height={width - cellSize * 1.5}
        x={cellSize / 2}
        y={cellSize / 2}
        fill="url(#grid)"
      />
      {data.map((row, i) => (
        <g key={`row-${i}`} id={`row-${i}`}>
          {row.map((el, j) => (
            <circle
              id={`${i}-${j}`}
              key={`${i}-${j}`}
              cx={i * cellSize + i * padding + 10}
              cy={j * cellSize + j * padding + 10}
              r={cellSize / 2}
              className={
                (el === 1 ? "black" : el === 2 ? "white" : "empty") + " cell"
              }
              onClick={() => onClick(i, j)}
            />
          ))}
        </g>
      ))}
    </svg>
  );
}
