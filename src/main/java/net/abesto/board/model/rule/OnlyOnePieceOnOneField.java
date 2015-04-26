package net.abesto.board.model.rule;

import net.abesto.board.model.Game;
import net.abesto.board.model.action.Action;
import net.abesto.board.model.action.HasTarget;
import net.abesto.board.model.board.Board;
import net.abesto.board.model.board.BoardIndex;
import net.abesto.board.model.board.Field;
import net.abesto.board.model.side.Side;

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
