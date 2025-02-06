// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

/** Modal window loader */
export function Loader() {
    return (
        <div className="w-full h-full flex flex-col text-sm items-center justify-center bg-black bg-opacity-50 fixed top-0 left-0 z-50">
            <div className="loader text-md"></div>
            <div className="text-md mt-4">Loading...</div>
        </div>
    );
}
