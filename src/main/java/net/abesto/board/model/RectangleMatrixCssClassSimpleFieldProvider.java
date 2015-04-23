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

public class RectangleMatrixCssClassSimpleFieldProvider extends RectangleMatrixSimpleFieldProvider {
	private List<String> fields;
	
	private static final char BLANK = '.';
	
	@Inject
	public RectangleMatrixCssClassSimpleFieldProvider(String boardDefOnClasspath) throws IOException {
		InputStream input = new ClassPathResource(boardDefOnClasspath).getInputStream();
		Iterator<String> lineIterator = new BufferedReader(new InputStreamReader(input)).lines().iterator();		
		initializeFields(lineIterator); 
	}

	private void initializeFields(Iterator<String> lineIterator) {
		fields = new ArrayList<>();
		lineIterator.forEachRemaining(fields::add);
	}

	@Override
	public RectangleMatrixField get(Point point) {
		char def = fields.get(point.getRow()).charAt(point.getColumn());
		FieldStyle style;
		if (def == BLANK) {
			style = NoFieldStyle.getInstance();
		} else {
			style = new FieldStyleCssClassName(Character.toString(def));
		}
		return new RectangleMatrixField(point, style);
	}
}
