package net.abesto.board.model.board;

import net.abesto.board.model.side.Side;

public class RectangleMatrixSimpleFieldProvider<S extends Side> extends RectangleMatrixFieldProvider<S> {
    @Override
    public RectangleMatrixField<S> get(Point point) {
        return new RectangleMatrixField<>(point);
    }
}
