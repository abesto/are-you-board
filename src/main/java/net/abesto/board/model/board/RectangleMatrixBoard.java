package net.abesto.board.model.board;

import net.abesto.board.model.side.Side;

import java.util.LinkedList;
import java.util.List;
import java.util.stream.IntStream;

public class RectangleMatrixBoard<S extends Side> extends Board<Point, S, RectangleMatrixField<S>> {
    protected RectangleMatrixBoardSize size;

    public RectangleMatrixBoard(
            FieldProvider<Point, RectangleMatrixField<S>> fieldProvider,
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

    public RectangleMatrixField<S> getField(int row, int column) {
        return getField(new Point(row, column));
    }

    public Iterable<Iterable<RectangleMatrixField<S>>> getFieldsTable() {
        return IntStream.range(0, getHeight()).mapToObj((int row) ->
                        (Iterable<RectangleMatrixField<S>>) IntStream.range(0, getWidth()).mapToObj((int column) ->
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
