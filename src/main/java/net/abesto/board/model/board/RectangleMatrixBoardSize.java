package net.abesto.board.model.board;

public class RectangleMatrixBoardSize {
    protected int width, height;

    public RectangleMatrixBoardSize(int width, int height) {
        this.width = width;
        this.height = height;
    }

    public int getWidth() {
        return width;
    }

    public int getHeight() {
        return height;
    }
}
