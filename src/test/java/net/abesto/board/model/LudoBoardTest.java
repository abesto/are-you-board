package net.abesto.board.model;

import net.abesto.board.model.games.LudoGameConfiguration;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.AbstractJUnit4SpringContextTests;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;

import java.util.function.Consumer;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertSame;

@RunWith(SpringJUnit4ClassRunner.class)
@ContextConfiguration(classes = {LudoGameConfiguration.class})
public class LudoBoardTest extends AbstractJUnit4SpringContextTests {
    private static void forEachPosition(RectangleMatrixBoard board, Consumer<Point> consumer) {
        for (int row = 0; row < board.getHeight(); row++) {
            for (int column = 0; column < board.getWidth(); column++) {
                consumer.accept(new Point(row, column));
            }
        }
    }

    private RectangleMatrixBoard givenAnEmptyBoard() {
        return applicationContext.getBean(RectangleMatrixBoard.class);
    }

    @Test
    public void testGetWidth() {
        assertEquals(11, givenAnEmptyBoard().getWidth());
    }

    @Test
    public void testGetHeight() {
        assertEquals(11, givenAnEmptyBoard().getHeight());
    }

    @Test
    public void testFieldsGeneratedWithCorrectPosition() {
        RectangleMatrixBoard board = givenAnEmptyBoard();
        forEachPosition(board, (Point point) -> {
            assertEquals(point, board.getField(point).getIndex());
        });
    }

    @Test(expected = IndexOutOfBoundsException.class)
    public void testGetFieldThrowsArrayIndexOutOfBoundsExceptionForWidth() {
        RectangleMatrixBoard board = givenAnEmptyBoard();
        board.getField(0, board.getWidth());
    }

    @Test(expected = IndexOutOfBoundsException.class)
    public void testGetFieldThrowsArrayIndexOutOfBoundsExceptionForHeight() {
        RectangleMatrixBoard board = givenAnEmptyBoard();
        board.getField(board.getHeight(), 0);
    }

    @Test
    public void testGetField() {
        RectangleMatrixBoard board = givenAnEmptyBoard();
        int row = 1;
        int column = 5;
        Point point = new Point(row, column);
        assertSame(board.getField(point), board.getField(row, column));
    }

    @Test
    public void testGetFields() {
        int row = 0;
        int column = 0;
        RectangleMatrixBoard board = givenAnEmptyBoard();
        for (Iterable<RectangleMatrixField> rowFields : board.getFieldsTable()) {
            for (RectangleMatrixField field : rowFields) {
                assertEquals(row, field.getRow());
                assertEquals(column, field.getColumn());
                column += 1;
            }
            row += 1;
            column = 0;
        }
    }
}