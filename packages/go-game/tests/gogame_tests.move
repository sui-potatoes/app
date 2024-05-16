// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

#[test_only]
module gogame::gogame_tests {
    use gogame::go;

    #[test, expected_failure(abort_code = go::ESuicideMove)]
    fun test_board_suicide_fail() {
        let mut board = go::from_vector(vector[
            vector[ 0, 2 ],
            vector[ 2, 0 ],
        ]);

        board.place(0, 0);
    }

    #[test, expected_failure(abort_code = go::EInvalidMove)]
    fun test_invalid_move_fail() {
        let mut board = go::from_vector(vector[
            vector[ 1 ]
        ]);

        board.place(0, 0); // aborts!
    }

    #[test, expected_failure(abort_code = go::EKoRule)]
    /// Scenario: symmetrical figure, p1 strikes, p2 attemps to strike back
    fun test_ko_rule_fail() {
        let mut board = go::from_vector(vector[
            vector[ 2, 0, 0, 0 ],
            vector[ 0, 2, 0, 0 ],
            vector[ 2, 1, 0, 0 ],
            vector[ 1, 0, 0, 0 ],
        ]);

        board.place(1, 0); // black move
        board.assert_score(vector[0, 1, 0]); // empty / black / white
        board.assert_state(vector[
            vector[ 2, 0, 0, 0 ],
            vector[ 1, 2, 0, 0 ],
            vector[ 0, 1, 0, 0 ],
            vector[ 1, 0, 0, 0 ],
        ]);

        board.place(2, 0); // white: Ko Rule!
    }

    #[test]
    /// Place a stone somewhere else to not repeat, then strike!
    fun test_avoid_ko_rule() {
        let mut board = go::from_vector(vector[
            vector[ 2, 0, 0, 0 ],
            vector[ 0, 2, 0, 0 ],
            vector[ 2, 1, 0, 0 ],
            vector[ 1, 0, 0, 0 ],
        ]);

        board.place(1, 0); // black
        board.assert_score(vector[0, 1, 0]);
        board.assert_state(vector[
            vector[ 2, 0, 0, 0 ],
            vector[ 1, 2, 0, 0 ],
            vector[ 0, 1, 0, 0 ],
            vector[ 1, 0, 0, 0 ],
        ]);

        board.place(2, 2); // white - side move
        board.assert_score(vector[0, 1, 0]);
        board.assert_state(vector[
            vector[ 2, 0, 0, 0 ],
            vector[ 1, 2, 0, 0 ],
            vector[ 0, 1, 2, 0 ],
            vector[ 1, 0, 0, 0 ],
        ]);

        board.place(1, 2); // black - increase tension!
        board.assert_score(vector[0, 1, 0]);
        board.assert_state(vector[
            vector[ 2, 0, 0, 0 ],
            vector[ 1, 2, 1, 0 ],
            vector[ 0, 1, 2, 0 ],
            vector[ 1, 0, 0, 0 ],
        ]);

        board.place(2, 0); // white - no Ko Rule!
        board.assert_score(vector[0, 1, 1]);
    }

    #[test]
    fun test_board_sacrifice_move() {
        let mut board = go::from_vector(vector[
            vector[ 0, 2, 1, 0 ],
            vector[ 2, 2, 1, 0 ],
            vector[ 1, 1, 1, 0 ],
            vector[ 0, 0, 0, 0 ],
        ]);

        board.place(0, 0);
        board.assert_score(vector[0, 3, 0]);
        board.assert_state(vector[
            vector[ 1, 0, 1, 0 ],
            vector[ 0, 0, 1, 0 ],
            vector[ 1, 1, 1, 0 ],
            vector[ 0, 0, 0, 0 ],
        ]);

        let mut board = go::from_vector(vector[
            vector[ 0, 2 ],
            vector[ 2, 1 ],
        ]);

        board.place(0, 0);
        board.assert_score(vector[0, 2, 0]);
        board.assert_state(vector[
            vector[ 1, 0 ],
            vector[ 0, 1 ],
        ]);
    }

    #[test]
    fun test_board() {
        let mut board = go::new(19);
        board.place(0, 0);
        board.place(10, 17);
        board.place(8, 6);
        board.place(3, 16);

        std::debug::print(&board.print_svg());

        let board = go::from_vector(vector[
            vector[0, 0, 0, 2, 0, 0, 0, 0, 0],
            vector[1, 1, 0, 2, 2, 0, 2, 0, 0],
            vector[0, 1, 0, 0, 2, 0, 0, 0, 0],
            vector[0, 1, 1, 0, 2, 2, 0, 0, 0],
            vector[0, 0, 1, 0, 0, 2, 0, 0, 0],
            vector[0, 0, 1, 0, 0, 2, 2, 0, 0],
            vector[0, 0, 1, 1, 1, 1, 2, 0, 0],
            vector[0, 0, 1, 2, 2, 2, 2, 0, 0],
            vector[0, 0, 0, 0, 0, 0, 0, 0, 0]
        ]);

        let board = go::from_vector(vector[
            vector[ 2, 0, 0, 0, 0, 0, 0, 0, 2 ],
        ]);

        // std::debug::print(
        //     &gogame::render::urlencode(
        //         &board.print_svg()
        //     )
        // );
    }

    #[test]
    // This test uses the legendary Ashok vs Damir match - the first match ever
    // finished in this application.
    fun test_score_calculation() {
        let board = go::from_vector(vector[
            vector[0, 0, 0, 0, 0, 0, 0, 0, 0],
            vector[0, 0, 2, 0, 0, 0, 0, 1, 0],
            vector[0, 1, 2, 1, 1, 1, 1, 0, 0],
            vector[0, 1, 1, 2, 2, 2, 2, 1, 0],
            vector[0, 1, 2, 2, 0, 2, 0, 1, 0],
            vector[0, 0, 1, 2, 2, 2, 2, 0, 0],
            vector[0, 1, 1, 1, 1, 2, 0, 2, 2],
            vector[0, 1, 0, 1, 2, 0, 2, 0, 0],
            vector[1, 0, 1, 2, 2, 2, 0, 0, 0],
        ]);

        // std::debug::print(&board.print_svg());

    }
}
