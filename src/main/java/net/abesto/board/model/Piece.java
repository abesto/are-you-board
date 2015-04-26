package net.abesto.board.model;

import net.abesto.board.model.side.Side;

public class Piece<S extends Side> {
    S side;

    public Piece(S side) {
        this.side = side;
    }

    public S getSide() {
        return side;
    }
}
