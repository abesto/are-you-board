package net.abesto.board.model;

public class FieldNotEmptyException extends ModelException {
	private static final long serialVersionUID = 6497132820674535439L;
 	
	private Field field;
    private Piece piece;

    public FieldNotEmptyException(Field field, Piece piece) {
    	super();
        this.field = field;
        this.piece = piece;
    }

    public Field getField() {
        return field;
    }

    public Piece getPiece() {
        return piece;
    }

    @Override
    public String toString() {
        return "FieldNotEmptyException{" +
                "field=" + field +
                ", piece=" + piece +
                '}';
    }
}
