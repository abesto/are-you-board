package net.abesto.board.model;

public class NoFieldStyle extends FieldStyle {
	private NoFieldStyle() {}
	
	private static NoFieldStyle instance = new NoFieldStyle();
	
	public static NoFieldStyle getInstance() { 
		return instance; 
	}
}
