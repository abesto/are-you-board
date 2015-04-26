package net.abesto.board.model.rule;

import net.abesto.board.model.Game;
import net.abesto.board.model.action.Action;
import net.abesto.board.model.action.HasTarget;
import net.abesto.board.model.board.Field;
import net.abesto.board.model.board.Point;
import net.abesto.board.model.board.RectangleMatrixBoard;
import net.abesto.board.model.board.RectangleMatrixField;
import net.abesto.board.model.side.ConnectNSide;
import net.abesto.board.model.side.Side;

public class ConnectNVictoryCondition extends Rule {
    protected int n;
    public static Axis[] axes = {
            new Axis(new Point(0, 1), new Point(0, -1)),
            new Axis(new Point(1, 0), new Point(-1, 0)),
            new Axis(new Point(-1, -1), new Point(1, 1)),
            new Axis(new Point(1, -1), new Point(-1, 1))
    };


    public static class Axis {
        public Point getVectorA() {
            return vectorA;
        }

        public Point getVectorB() {
            return vectorB;
        }

        public Axis(Point vectorA, Point vectorB) {

            this.vectorA = vectorA;
            this.vectorB = vectorB;
        }

        Point vectorA;
        Point vectorB;
    }

    public ConnectNVictoryCondition(int n) {
        this.n = n;
    }

    @Override
    public void apply(Game game, Action action) {
        RectangleMatrixBoard<ConnectNSide> board = (RectangleMatrixBoard) game.getBoard();
        Point target = ((HasTarget<Point>) action).getTarget();
        RectangleMatrixField<ConnectNSide> field = board.getField(target);
        for (Axis axis : axes) {
            if (countByAxis(board, field, axis) >= n) {
                game.setWinner(field.getPiece().getSide());
                game.setOver(true);
            }
        }
    }

    public int countByAxis(RectangleMatrixBoard board, RectangleMatrixField field, Axis axis) {
        return 1 + countConnected(board, field, axis.getVectorA()) + countConnected(board, field, axis.getVectorB());
    }

    public int countConnected(RectangleMatrixBoard board, RectangleMatrixField<?> f, Point vector) {
        Side s = f.getPiece().getSide();
        Point p = f.getIndex().offset(vector);
        int count = 0;
        while (board.hasField(p) && !board.getField(p).isEmpty() && board.getField(p).getPiece().getSide() == s) {
            count += 1;
            p = p.offset(vector);
        }
        return count;
    }
}
