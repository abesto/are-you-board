package net.abesto.board.model;

import static org.junit.Assert.*;

import org.junit.Test;

public class RectangleMatrixSimpleFieldProviderTest {
	@Test
	public void test() {
		RectangleMatrixSimpleFieldProvider provider = new RectangleMatrixSimpleFieldProvider();
		Point point = new Point(3, 4);
		Field fieldByPosition = provider.get(point);
		Field fieldByInts = provider.get(point.getRow(), point.getColumn());
		assertSame(point, fieldByPosition.getIndex());
		assertEquals(point, fieldByInts.getIndex());
	}

}
