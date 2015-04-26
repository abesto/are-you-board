package net.abesto.board.model.board;

import net.abesto.board.model.side.Side;

public class RectangleMatrixField<S extends Side> extends Field<Point, S> {
    public RectangleMatrixField(int row, int column) {
        this(new Point(row, column));
    }

    public RectangleMatrixField(Point index) {
        super(index);
    }

    public RectangleMatrixField(Point point, FieldStyle style) {
        super(point, style);
    }

    public int getRow() {
        return index.getRow();
    }

    public int getColumn() {
        return index.getColumn();
    }
}
