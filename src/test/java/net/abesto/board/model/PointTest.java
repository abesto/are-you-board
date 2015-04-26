package net.abesto.board.model;

import net.abesto.board.model.board.Point;
import org.junit.Test;

import static org.junit.Assert.assertEquals;

public class PointTest {

    @Test
    public void testEquals() {
        for (int row1 = 0; row1 < 4; row1++) {
            for (int column1 = 0; column1 < 4; column1++) {
                for (int row2 = 0; row2 < 4; row2++) {
                    for (int column2 = 0; column2 < 4; column2++) {
                        assertEquals(row1 == row2 && column1 == column2,
                                new Point(row1, column1).equals(new Point(row2, column2)));
                    }
                }
            }
        }
    }

}
