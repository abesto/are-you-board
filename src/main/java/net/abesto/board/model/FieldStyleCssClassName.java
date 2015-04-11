package net.abesto.board.model;

public class FieldStyleCssClassName extends FieldStyle {
	private String className;
	
	public FieldStyleCssClassName(String className) {
		this.className = className;
	}
	
	public String getCssClassName() {
		return className;
	}
}
