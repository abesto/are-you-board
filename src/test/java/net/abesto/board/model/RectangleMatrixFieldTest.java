package net.abesto.board.model;

import net.abesto.board.model.board.Field;
import net.abesto.board.model.board.FieldEmptyException;
import net.abesto.board.model.board.FieldNotEmptyException;
import net.abesto.board.model.board.RectangleMatrixField;
import org.junit.Test;

import static org.junit.Assert.*;

public class RectangleMatrixFieldTest {
    private static Field givenAnEmptyField() {
        return new RectangleMatrixField(0, 0);
    }

    private static Piece givenAPiece() {
        return new Piece(null);
    }

    private static Field givenAFieldWithAPiece() {
        Field field = givenAnEmptyField();
        Piece piece = givenAPiece();
        field.setPiece(piece);
        return field;
    }

    @Test
    public void testNewFieldIsEmpty() {
        assertTrue(new RectangleMatrixField(0, 0).isEmpty());
    }

    @Test
    public void testSetGetPiece() {
        Field field = givenAnEmptyField();
        Piece piece = givenAPiece();
        field.setPiece(piece);
        assertSame(piece, field.getPiece());
    }

    @Test(expected = FieldNotEmptyException.class)
    public void testSetPieceThrowsIfFieldNotEmpty() {
        Field field = givenAFieldWithAPiece();
        field.setPiece(givenAPiece());
    }

    @Test(expected = FieldEmptyException.class)
    public void testGetPieceThrowsIfFieldIsEmpty() {
        Field field = givenAnEmptyField();
        field.getPiece();
    }

    @Test
    public void testGetRowAndColumn() {
        RectangleMatrixField field = new RectangleMatrixField(5, 10);
        assertEquals(10, field.getColumn());
        assertEquals(5, field.getRow());
    }

    @Test
    public void testRemovePiece() {
        Field field = givenAFieldWithAPiece();
        field.removePiece();
        assertTrue(field.isEmpty());
    }
}
