package net.abesto.board.model;

public class SimpleFieldProvider extends FieldProvider {
	@Override
	public Field apply(Position position) {
		return new Field(position);
	}
}
