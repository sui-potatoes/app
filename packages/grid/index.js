// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

// SAT solver; all of the following constraints must be satisfied.

// |_|_|_|_|_|
// |_|_|1|M|_|
// |_|1|2|_|_|
// |M|1|1|M|_|
// |_|_|_|_|_|

const CONSTRAINTS = [
    { solutions: [ 404, 204, 202, 304 ], pick: 2 },
    { solutions: [ 401, 201, 301, 202 ], pick: 1 },
    { solutions: [ 504, 502, 304, 404, 503 ], pick: 1 },
    { solutions: [ 503, 501, 301, 401, 502 ], pick: 1 },
    { solutions: [ 304, 104, 102, 202, 103, 204 ], pick: 1 },
].map((c) => ({ ...c, solutions: c.solutions.sort((b, a) => a - b) }));

console.log(CONSTRAINTS.map((c) => c.solutions));

// brute force solution; we can try to pick a mine and see if it
// satisfies the constraints.

const mines = [];
let count_ = 0;

// constraints are sorted by the number of solutions; we can pick a mine
// and see if it satisfies the remaining constraints.
function solveMines(constraints) {
    const mineSet = new Set();

    function backtrack(index) {
        count_++;
        if (index === constraints.length) {
            return validateAll(constraints, mineSet);
        }

        const { solutions, pick } = constraints[index];
        const combos = getCombinations(solutions, pick);

        for (const combo of combos) {
            const newlyAdded = [];

            // Mark new mines
            for (const cell of combo) {
                if (!mineSet.has(cell)) {
                    mineSet.add(cell);
                    newlyAdded.push(cell);
                }
            }

            if (backtrack(index + 1)) {
                return true;
            }

            // Backtrack: remove newly added
            for (const cell of newlyAdded) {
                mineSet.delete(cell);
            }
        }

        return false;
    }

    if (backtrack(0)) {
        return Array.from(mineSet);
    } else {
        return null;
    }
}

function 7(constraints, mineSet) {
    for (const { solutions, pick } of constraints) {
        let count = 0;
        for (const cell of solutions) {
            if (mineSet.has(cell)) count++;
        }
        if (count !== pick) return false;
    }
    return true;
}

let count = 0;

function getCombinations(arr, k) {
    const result = [];

    function dfs(start, path) {
        count++;
        if (path.length === k) {
            result.push([...path]);
            return;
        }

        for (let i = start; i < arr.length; i++) {
            path.push(arr[i]);
            dfs(i + 1, path);
            path.pop();
        }
    }

    dfs(0, []);
    return result;
}

console.time("solveMines");
const result = solveMines(CONSTRAINTS);
console.timeEnd("solveMines");
console.log("Mines:", result);
console.log("Count:", count);
console.log("Count_:", count_);
