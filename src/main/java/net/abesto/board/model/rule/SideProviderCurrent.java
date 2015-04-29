package net.abesto.board.model.rule;

import net.abesto.board.model.Game;
import net.abesto.board.model.side.Side;

public class SideProviderCurrent<S extends Side> implements SideProvider<S> {
    @Override
    public S get(Game<S, ?> game) {
        return game.getCurrentSide();
    }
}
