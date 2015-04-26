package net.abesto.board.model.board;

public abstract class FieldProvider<I extends BoardIndex, F extends Field<I, ?>> {
    abstract public F get(I index);
}
