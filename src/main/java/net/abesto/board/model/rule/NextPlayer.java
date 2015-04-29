package net.abesto.board.model.rule;

import net.abesto.board.model.Game;
import net.abesto.board.model.action.Action;

public class NextPlayer<G extends Game<?, ?>, A extends Action> extends Rule<G, A> {
    @Override
    public void apply(G game, A action) {
        game.nextPlayer();
    }
}
