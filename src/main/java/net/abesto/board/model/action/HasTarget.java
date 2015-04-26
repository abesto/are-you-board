package net.abesto.board.model.action;

import net.abesto.board.model.board.Board;
import net.abesto.board.model.board.BoardIndex;
import net.abesto.board.model.board.Field;
import net.abesto.board.model.side.Side;

public interface HasTarget<I extends BoardIndex> {
    public I getTarget();

    default public Field<I, ?> getTargetField(Board board) {
        Board<BoardIndex, Side, Field<BoardIndex, Side>> _board = (Board<BoardIndex, Side, Field<BoardIndex, Side>>) board;
        return (Field<I, ?>) _board.getField(getTarget());
    }
}
