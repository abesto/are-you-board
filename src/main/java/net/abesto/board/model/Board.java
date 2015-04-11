package net.abesto.board.model;

import java.util.ArrayList;
import java.util.List;

public class Board {
    private static final int WIDTH = 11;
    private static final int HEIGHT = 11;

    private List<List<Field>> fields;
    
    public Board(FieldProvider fieldProvider) {
		super();
		fields = new ArrayList<List<Field>>(getHeight());
		for (int row = 0; row < HEIGHT; row++) {
			List<Field> rowFields = new ArrayList<Field>(getWidth());
			for (int column = 0; column < WIDTH; column++) {
				rowFields.add(column, fieldProvider.apply(row, column));
			}
			fields.add(row,  rowFields);
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
    	return fields.get(row).get(column);
    }

    public Iterable<? extends Iterable<Field>> getFieldsIterable() {
    	return fields;
    }
}
