package net.abesto.board.model;

public abstract class FieldProvider<I, F extends Field<I>> {
    abstract public F get(I index);
}
