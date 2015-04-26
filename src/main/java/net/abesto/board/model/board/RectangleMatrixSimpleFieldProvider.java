package net.abesto.board.model.board;

public class RectangleMatrixSimpleFieldProvider extends FieldProvider<Point, RectangleMatrixField<?>> {
    @Override
    public RectangleMatrixField get(Point point) {
        return new RectangleMatrixField(point);
    }

    public Field get(int row, int column) {
        return get(new Point(row, column));
    }
}
