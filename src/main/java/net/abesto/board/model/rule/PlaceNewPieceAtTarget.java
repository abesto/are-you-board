package net.abesto.board.model.rule;

import net.abesto.board.model.Game;
import net.abesto.board.model.Piece;
import net.abesto.board.model.action.Action;
import net.abesto.board.model.action.HasTarget;
import net.abesto.board.model.board.Board;
import net.abesto.board.model.board.BoardIndex;
import net.abesto.board.model.board.Field;
import net.abesto.board.model.side.Side;

public class PlaceNewPieceAtTarget<
        S extends Side,
        G extends Game<S, ?>,
        A extends Action & HasTarget<? extends Field<?, S>>>
        extends Rule<G, A> {
    protected SideProvider<S> sideProvider;

    public PlaceNewPieceAtTarget(SideProvider<S> sideProvider) {
        this.sideProvider = sideProvider;
    }

    @Override
    public void apply(G game, A action) {
            Field<?, S> f = action.getTarget();
            f.setPiece(new Piece<>(sideProvider.get(game)));
        }
}
