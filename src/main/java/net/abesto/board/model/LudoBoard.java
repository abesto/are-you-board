package net.abesto.board.model;

public class LudoBoard extends RectangleMatrixBoard {
    private static final int WIDTH = 11;
    private static final int HEIGHT = 11;

    public LudoBoard(FieldProvider<Point, RectangleMatrixField> fieldProvider) {
        super(fieldProvider);
    }

    public int getWidth() {
        return WIDTH;
    }

    public int getHeight() {
        return HEIGHT;
    }
}
