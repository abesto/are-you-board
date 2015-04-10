package net.abesto.board.model;

import static org.junit.Assert.*;

import org.junit.Test;

public class SimpleFieldProviderTest {
	@Test
	public void test() {
		FieldProvider provider = new SimpleFieldProvider();
		Position position = new Position(3, 4);
		Field fieldByPosition = provider.apply(position);
		Field fieldByInts = provider.apply(position.getRow(), position.getColumn());
		assertSame(position, fieldByPosition.getPosition());
		assertEquals(position, fieldByInts.getPosition());
	}

}
