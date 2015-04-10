package net.abesto.board.model;

abstract class FieldProvider {
	abstract public Field apply(Position position);
	
	public Field apply(int row, int column) {
		return apply(new Position(row, column));
	}
}
