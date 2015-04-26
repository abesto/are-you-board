package net.abesto.board.model.rule;

import net.abesto.board.model.Game;
import net.abesto.board.model.action.Action;
import net.abesto.board.model.action.HasTarget;

public class OnlyOnePieceOnOneField extends Rule {
    @Override
    public RuleCheckResult check(Game<?> game, Action action) {
        if (action instanceof HasTarget) {

            if (!((HasTarget) action).getTargetField(game.getBoard()).isEmpty()) {
                return invalid();
            }
        }
        return valid();
    }
}
