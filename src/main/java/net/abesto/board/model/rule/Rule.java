package net.abesto.board.model.rule;

import net.abesto.board.model.Game;
import net.abesto.board.model.action.Action;
import net.abesto.board.model.board.Board;
import net.abesto.board.model.side.Side;

public abstract class Rule<G extends Game<?, ?>, A extends Action> {
    public RuleCheckResult check(G game, A action) {
        return RuleCheckResult.valid();
    }

    public void apply(G game, A action) {}

    protected RuleCheckResult invalid(String message) {
        return RuleCheckResult.invalid(message);
    }

    protected RuleCheckResult invalid() {
        return invalid(getClass().getName());
    }

    protected RuleCheckResult valid() {
        return RuleCheckResult.valid();
    }
}
