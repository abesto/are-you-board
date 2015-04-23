package net.abesto.board.model;

public class RectangleMatrixField extends Field<Point> {
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
