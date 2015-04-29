package net.abesto.board.model.rule;

import net.abesto.board.model.Game;
import net.abesto.board.model.action.Action;

public class OnlyCurrentPlayerMayMove<G extends Game<?, ?>, A extends Action> extends Rule<G, A> {
    @Override
    public RuleCheckResult check(G game, A action) {
        if (game.getCurrentPlayer() != action.getPlayer()) {
            return invalid();
        }
        return valid();
    }
}
