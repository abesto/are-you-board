package net.abesto.board.model.action;

import net.abesto.board.model.board.Board;
import net.abesto.board.model.board.BoardIndex;
import net.abesto.board.model.board.Field;
import net.abesto.board.model.side.Side;

public interface HasTarget<F extends Field> {
    F getTarget();
}
