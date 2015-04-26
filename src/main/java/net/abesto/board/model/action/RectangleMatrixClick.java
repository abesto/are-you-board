package net.abesto.board.model.action;

import net.abesto.board.model.User;
import net.abesto.board.model.board.Point;

public class RectangleMatrixClick extends Action implements HasTarget {
    protected Point point;

    public RectangleMatrixClick(User player, Point point) {
        super(player);
        this.point = point;
    }

    public Point getPoint() {
        return point;
    }

    @Override
    public Point getTarget() {
        return point;
    }
}
