package net.abesto.board.model.rule;

import net.abesto.board.model.Game;
import net.abesto.board.model.action.Action;

public class NextPlayer extends Rule {
    @Override
    public void apply(Game<?> game, Action action) {
        game.nextPlayer();
    }
}
