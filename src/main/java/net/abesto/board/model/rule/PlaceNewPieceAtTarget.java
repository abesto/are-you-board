package net.abesto.board.model.rule;

import net.abesto.board.model.Game;
import net.abesto.board.model.Piece;
import net.abesto.board.model.action.Action;
import net.abesto.board.model.action.HasTarget;
import net.abesto.board.model.board.Field;

public class PlaceNewPieceAtTarget extends Rule {
    protected SideProvider sideProvider;

    public PlaceNewPieceAtTarget(SideProvider sideProvider) {
        this.sideProvider = sideProvider;
    }

    @Override
    public void apply(Game<?> game, Action action) {
        if (action instanceof HasTarget) {
            Field f = ((HasTarget) action).getTargetField(game.getBoard());
            f.setPiece(new Piece(sideProvider.get(game)));
        }
    }
}
