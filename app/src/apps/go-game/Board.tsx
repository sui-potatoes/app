//

type Matrix = number[][];

/**
 * Renders a Go board.
 */
export function Board({
  size,
  data,
  disabled,
  onClick,
}: {
  size: 9 | 13 | 19;
  data: Matrix;
  disabled: boolean;
  onClick: (x: number, y: number) => void;
}) {
  const cellSize = 20;
  const padding = 2;
  const width = size * (cellSize + 1) + size * padding;

  return (
    <svg className={disabled ? 'disabled' : ''} width={width + cellSize} height={width + cellSize}>
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
        width={width - (cellSize * 1.5)}
        height={width - (cellSize * 1.5)}
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
              style={{ cursor: 'pointer' }}
              className={el === 1 ? "black" : el === 2 ? "white" : "empty"}
              onClick={() => onClick(i, j)}
            />
          ))}
        </g>
      ))}
    </svg>
  );
}
