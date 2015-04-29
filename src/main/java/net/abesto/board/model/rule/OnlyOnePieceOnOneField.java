package net.abesto.board.model.rule;

import net.abesto.board.model.Game;
import net.abesto.board.model.action.Action;
import net.abesto.board.model.action.HasTarget;

public class OnlyOnePieceOnOneField<G extends Game<?, ?>, A extends Action & HasTarget> extends Rule<G, A> {
    @Override
    public RuleCheckResult check(G game, A action) {
        if (!action.getTarget().isEmpty()) {
            return invalid();
        }
        return valid();
    }
}
