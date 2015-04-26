package net.abesto.board.model.rule;

import net.abesto.board.model.Game;
import net.abesto.board.model.side.Side;

public interface SideProvider {
    public Side get(Game game);
}
