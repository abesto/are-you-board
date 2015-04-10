package net.abesto.board.model;

import javax.inject.Inject;

public class Board {
    private static final int WIDTH = 11;
    private static final int HEIGHT = 11;

    private Field[][] fields;
    
    @Inject
    public Board(FieldProvider fieldProvider) {
		super();
		fields = new Field[HEIGHT][WIDTH];
		for (int row = 0; row < HEIGHT; row++) {
			for (int column = 0; column < WIDTH; column++) {
				fields[row][column] = fieldProvider.apply(row, column);
			}
		}
	}

	public int getWidth() {
        return WIDTH;
    }

    public int getHeight() {
        return HEIGHT;
    }
    
    public Field getField(Position position) {
    	return getField(position.getRow(), position.getColumn());
    }
    
    public Field getField(int row, int column) {
    	return fields[row][column];
    }
}
