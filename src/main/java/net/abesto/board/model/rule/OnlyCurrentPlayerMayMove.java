package net.abesto.board.model.rule;

import net.abesto.board.model.Game;
import net.abesto.board.model.action.Action;

public class OnlyCurrentPlayerMayMove extends Rule {
    @Override
    public RuleCheckResult check(Game game, Action action) {
        if (game.getCurrentPlayer() != action.getPlayer()) {
            return invalid();
        }
        return valid();
    }
}
