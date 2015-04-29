package net.abesto.board.model.rule;

import net.abesto.board.model.Game;
import net.abesto.board.model.action.Action;
import net.abesto.board.model.action.HasTarget;
import net.abesto.board.model.board.Board;
import net.abesto.board.model.board.Point;
import net.abesto.board.model.board.RectangleMatrixBoard;
import net.abesto.board.model.board.RectangleMatrixField;
import net.abesto.board.model.side.ConnectNSide;
import net.abesto.board.model.side.Side;

public class ConnectNVictoryCondition<
        G extends Game<ConnectNSide, ? extends RectangleMatrixBoard<ConnectNSide>>,
        A extends Action & HasTarget<? extends RectangleMatrixField<ConnectNSide>>
    > extends Rule<G, A> {
    public static Axis[] axes = {
            new Axis(new Point(0, 1), new Point(0, -1)),
            new Axis(new Point(1, 0), new Point(-1, 0)),
            new Axis(new Point(-1, -1), new Point(1, 1)),
            new Axis(new Point(1, -1), new Point(-1, 1))
    };
    protected int n;


    public ConnectNVictoryCondition(int n) {
        this.n = n;
    }

    @Override
    public void apply(G game, A action) {
        RectangleMatrixField<ConnectNSide> field = action.getTarget();
        for (Axis axis : axes) {
            if (countByAxis(game.getBoard(), field, axis) >= n) {
                game.setWinner(field.getPiece().getSide());
                game.setOver(true);
            }
        }
    }

    public int countByAxis(RectangleMatrixBoard board, RectangleMatrixField field, Axis axis) {
        return 1 + countConnected(board, field, axis.getVectorA()) + countConnected(board, field, axis.getVectorB());
    }

    public int countConnected(RectangleMatrixBoard<?> board, RectangleMatrixField<?> f, Point vector) {
        Side s = f.getPiece().getSide();
        Point p = f.getIndex().offset(vector);
        int count = 0;
        while (board.hasField(p) && !board.getField(p).isEmpty() && board.getField(p).getPiece().getSide() == s) {
            count += 1;
            p = p.offset(vector);
        }
        return count;
    }

    public static class Axis {
        Point vectorA;
        Point vectorB;

        public Axis(Point vectorA, Point vectorB) {

            this.vectorA = vectorA;
            this.vectorB = vectorB;
        }

        public Point getVectorA() {
            return vectorA;
        }

        public Point getVectorB() {
            return vectorB;
        }
    }
}
