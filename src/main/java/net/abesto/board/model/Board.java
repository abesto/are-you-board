package net.abesto.board.model;

import java.util.HashMap;
import java.util.Map;

/**
 * @param <I> Type used to index the fields of this board
 * @param <F> Type of field used in this board
 */
public abstract class Board<I, F extends Field<I>> {
    protected Map<I, F> fields;

    public Board(FieldProvider<I, F> fieldProvider) {
        super();
        fields = new HashMap<>();
        for (I index : getIndexIterable()) {
            fields.put(index, fieldProvider.get(index));
        }
    }

    public F getField(I index) {
        if (!fields.containsKey(index)) {
            throw new IndexOutOfBoundsException();
        }
        return fields.get(index);
    }

    public Iterable<F> getFieldsIterable() {
        return fields.values();
    }

    protected abstract Iterable<I> getIndexIterable();
}
