package net.abesto.board.model;

import org.junit.Test;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertSame;

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
