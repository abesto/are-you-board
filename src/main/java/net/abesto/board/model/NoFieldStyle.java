package net.abesto.board.model;

public class NoFieldStyle implements FieldStyle {
	private NoFieldStyle() {}
	
	private static NoFieldStyle instance = new NoFieldStyle();
	
	public static NoFieldStyle getInstance() { 
		return instance; 
	}
}
