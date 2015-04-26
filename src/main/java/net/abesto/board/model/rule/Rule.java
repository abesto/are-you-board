package net.abesto.board.model.rule;

import net.abesto.board.model.Game;
import net.abesto.board.model.action.Action;

public abstract class Rule {
    public RuleCheckResult check(Game<?> game, Action action) {
        return RuleCheckResult.valid();
    }

    public void apply(Game<?> game, Action action) {
    }

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
