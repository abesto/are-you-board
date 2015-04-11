package net.abesto.board.model;

import java.util.function.Consumer;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.context.annotation.Bean;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.AbstractJUnit4SpringContextTests;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;

import static org.junit.Assert.*;

class BoardTestConfiguration {
	@Bean
	public FieldProvider getFieldProvider() {
		return new SimpleFieldProvider();
	}
	
	@Bean
	public Board getBoard() {
		return new Board(getFieldProvider());
	}
}

@RunWith(SpringJUnit4ClassRunner.class)
@ContextConfiguration(classes = { BoardTestConfiguration.class })
public class BoardTest extends AbstractJUnit4SpringContextTests {
    private static void forEachPosition(Board board, Consumer<Position> consumer) {
    	for (int row = 0; row < board.getHeight(); row++) {
    		for (int column = 0; column < board.getWidth(); column++) {
    			consumer.accept(new Position(row, column));
    		}
    	}   	
    }

    private Board givenAnEmptyBoard() {
    	return (Board) applicationContext.getBean(Board.class);
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
    	Board board = givenAnEmptyBoard();
    	forEachPosition(board, (Position position) -> {
    		assertEquals(position, board.getField(position).getPosition());
    	});
    }

	@Test(expected = IndexOutOfBoundsException.class)
    public void testGetFieldThrowsArrayIndexOutOfBoundsExceptionForWidth() {
    	Board board = givenAnEmptyBoard();
    	board.getField(0, board.getWidth());
    }
    
    @Test(expected = IndexOutOfBoundsException.class)
    public void testGetFieldThrowsArrayIndexOutOfBoundsExceptionForHeight() {
    	Board board = givenAnEmptyBoard();
    	board.getField(board.getHeight(), 0);
    }
    
    @Test
    public void testGetField() {
    	Board board = givenAnEmptyBoard();
    	int row = 1;
    	int column = 5;
    	Position position = new Position(row, column);
    	assertSame(board.getField(position), board.getField(row, column));
    }
    
    @Test
    public void testGetFields() {
    	int row = 0;
    	int column = 0;
    	Board board = givenAnEmptyBoard();
    	for (Iterable<Field> rowFields : board.getFieldsIterable()) {
    		for (Field field : rowFields) {
    			assertEquals(row, field.getRow());
    			assertEquals(column, field.getColumn());
    			column += 1;
    		}
    		row += 1;
    		column = 0;
    	}
    }
}