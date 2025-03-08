// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import { NavLink } from "react-router-dom";

export function Footer({ to, text }: { to?: string; text?: string }) {
    return (
        <div className="footer w-full flex justify-between relative bottom-0 left-0 p-10 flex text-lg">
            <NavLink to={to || ".."} className="menu-control back-button">
                {text || "Back"}
            </NavLink>
        </div>
    );
}
