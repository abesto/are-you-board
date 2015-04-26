package net.abesto.board.model.board;

public class NoFieldStyle extends FieldStyle {
    private static NoFieldStyle instance = new NoFieldStyle();

    private NoFieldStyle() {
    }

    public static NoFieldStyle getInstance() {
        return instance;
    }
}
