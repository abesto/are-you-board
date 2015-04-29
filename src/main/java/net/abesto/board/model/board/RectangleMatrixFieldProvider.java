package net.abesto.board.model.board;

import net.abesto.board.model.side.Side;

public abstract class RectangleMatrixFieldProvider<S extends Side> extends FieldProvider<Point, RectangleMatrixField<S>> {
    @Override
    public abstract RectangleMatrixField<S> get(Point point);

    public RectangleMatrixField<S> get(int row, int column) {
        return get(new Point(row, column));
    }
}
