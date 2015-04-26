package net.abesto.board.model.board;

import net.abesto.board.model.ModelException;

public class FieldEmptyException extends ModelException {
    private static final long serialVersionUID = 875720967252030232L;
    private Field field;

    public FieldEmptyException(Field field) {
        super();
        this.field = field;
    }

    public Field getField() {
        return field;
    }
}
