package net.abesto.board.model;

import java.util.LinkedList;
import java.util.List;
import java.util.stream.IntStream;

public class RectangleMatrixBoard extends Board<Point, RectangleMatrixField> {
    protected RectangleMatrixBoardSize size;

    public RectangleMatrixBoard(
            FieldProvider<Point, RectangleMatrixField> fieldProvider,
            RectangleMatrixBoardSize size
    ) {
        super(fieldProvider);
        this.size = size;
    }

    public RectangleMatrixBoardSize getSize() {
        return size;
    }

    @Override
    protected Iterable<Point> getIndexIterable() {
        List<Point> indexes = new LinkedList<>();
        IntStream.range(0, getHeight()).forEach((int row) -> {
            IntStream.range(0, getWidth()).forEach((int column) -> {
                indexes.add(new Point(row, column));
            });
        });
        return indexes;
    }

    public RectangleMatrixField getField(int row, int column) {
        return getField(new Point(row, column));
    }

    public Iterable<? extends Iterable<RectangleMatrixField>> getFieldsTable() {
        return IntStream.range(0, getHeight()).mapToObj((int row) ->
                        (Iterable<RectangleMatrixField>) IntStream.range(0, getWidth()).mapToObj((int column) ->
                                        getField(row, column)
                        )::iterator
        )::iterator;
    }

    public int getWidth() {
        return size.getWidth();
    }

    public int getHeight() {
        return size.getHeight();
    }
}
