package net.abesto.board.model;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.context.annotation.Bean;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.AbstractJUnit4SpringContextTests;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;

import java.util.function.Consumer;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertSame;

class BoardTestConfiguration {
    @Bean
    public RectangleMatrixSimpleFieldProvider getFieldProvider() {
        return new RectangleMatrixSimpleFieldProvider();
    }

    @Bean
    public LudoBoard getBoard() {
        return new LudoBoard(getFieldProvider());
    }
}

@RunWith(SpringJUnit4ClassRunner.class)
@ContextConfiguration(classes = {BoardTestConfiguration.class})
public class LudoBoardTest extends AbstractJUnit4SpringContextTests {
    private static void forEachPosition(LudoBoard board, Consumer<Point> consumer) {
        for (int row = 0; row < board.getHeight(); row++) {
            for (int column = 0; column < board.getWidth(); column++) {
                consumer.accept(new Point(row, column));
            }
        }
    }

    private LudoBoard givenAnEmptyBoard() {
        return (LudoBoard) applicationContext.getBean(LudoBoard.class);
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
        LudoBoard board = givenAnEmptyBoard();
        forEachPosition(board, (Point point) -> {
            assertEquals(point, board.getField(point).getIndex());
        });
    }

    @Test(expected = IndexOutOfBoundsException.class)
    public void testGetFieldThrowsArrayIndexOutOfBoundsExceptionForWidth() {
        LudoBoard board = givenAnEmptyBoard();
        board.getField(0, board.getWidth());
    }

    @Test(expected = IndexOutOfBoundsException.class)
    public void testGetFieldThrowsArrayIndexOutOfBoundsExceptionForHeight() {
        LudoBoard board = givenAnEmptyBoard();
        board.getField(board.getHeight(), 0);
    }

    @Test
    public void testGetField() {
        LudoBoard board = givenAnEmptyBoard();
        int row = 1;
        int column = 5;
        Point point = new Point(row, column);
        assertSame(board.getField(point), board.getField(row, column));
    }

    @Test
    public void testGetFields() {
        int row = 0;
        int column = 0;
        LudoBoard board = givenAnEmptyBoard();
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