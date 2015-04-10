package net.abesto.board.model;

import static org.junit.Assert.*;

import org.junit.Test;

public class PositionTest {

	@Test
	public void testEquals() {
		for (int row1 = 0; row1 < 4; row1++) {
			for (int column1 = 0; column1 < 4; column1++) {
				for (int row2 = 0; row2 < 4; row2++) {
					for (int column2 = 0; column2 < 4; column2++) {
						assertEquals(row1 == row2 && column1 == column2,
								new Position(row1, column1).equals(new Position(row2, column2)));
					}
				}
			}
		}
	}

}
