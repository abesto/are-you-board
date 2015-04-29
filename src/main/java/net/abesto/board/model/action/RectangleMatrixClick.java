package net.abesto.board.model.action;

import net.abesto.board.model.User;
import net.abesto.board.model.board.Point;
import net.abesto.board.model.board.RectangleMatrixField;
import net.abesto.board.model.side.Side;

public class RectangleMatrixClick<S extends Side> extends Action implements HasTarget<RectangleMatrixField<S>> {
    protected RectangleMatrixField<S> field;

    public RectangleMatrixClick(User player, RectangleMatrixField<S> field) {
        super(player);
        this.field = field;
    }

    @Override
    public RectangleMatrixField<S> getTarget() {
        return field;
    }
}
