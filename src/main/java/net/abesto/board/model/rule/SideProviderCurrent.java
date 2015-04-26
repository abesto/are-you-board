package net.abesto.board.model.rule;

import net.abesto.board.model.Game;
import net.abesto.board.model.side.Side;

public class SideProviderCurrent implements SideProvider {
    @Override
    public Side get(Game game) {
        return game.getCurrentSide();
    }
}
