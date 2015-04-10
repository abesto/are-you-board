package net.abesto.board.model;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

import javax.inject.Inject;

import org.springframework.core.io.ClassPathResource;

public class CssClassFieldProvider extends SimpleFieldProvider {
	private List<String> fields;
	
	private static final char BLANK = '.';
	
	@Inject
	public CssClassFieldProvider(String boardDefOnClasspath) throws IOException {
		InputStream input = new ClassPathResource(boardDefOnClasspath).getInputStream();
		Iterator<String> lineIterator = new BufferedReader(new InputStreamReader(input)).lines().iterator();		
		initializeFields(lineIterator); 
	}

	private void initializeFields(Iterator<String> lineIterator) {
		fields = new ArrayList<String>();
		lineIterator.forEachRemaining((line) -> {
			fields.add(line);
		});
	}

	@Override
	public Field apply(Position position) {
		char def = fields.get(position.getRow()).charAt(position.getColumn());
		FieldStyle style;
		if (def == BLANK) {
			style = NoFieldStyle.getInstance();
		} else {
			style = new FieldStyleCssClassName(Character.toString(def));
		}
		return new Field(position, style);
	}
}
