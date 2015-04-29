package net.abesto.board.model;

import net.abesto.board.model.action.Action;
import net.abesto.board.model.board.Board;
import net.abesto.board.model.rule.RuleCheckResult;
import net.abesto.board.model.rule.RuleMap;
import net.abesto.board.model.rule.RuleRunner;
import net.abesto.board.model.side.Side;
import net.abesto.board.model.side.Sides;

import java.util.HashMap;
import java.util.Map;

public class Game<S extends Side, B extends Board> {
    protected B board;
    protected RuleRunner<Game<S, B>> ruleRunner;
    protected Sides<S> sides;
    protected Map<S, User> playerMap;
    protected boolean over;
    protected S winner;

    public Game(
            B board,
            RuleMap<Game<S, B>> ruleMap,
            Sides<S> sides) {
        this.board = board;
        over = false;
        ruleRunner = new RuleRunner<>(ruleMap);
        this.sides = sides;
        playerMap = new HashMap<>();
    }

    public Map<S, User> getPlayerMap() {
        return playerMap;
    }

    public S getWinnerSide() {
        return winner;
    }

    public User getWinnerPlayer() {
        return playerMap.get(getWinnerSide());
    }

    public void setWinner(S winner) {
        this.winner = winner;
    }

    public boolean isOver() {
        return over;
    }

    public void setOver(boolean over) {
        this.over = over;
    }

    public void join(S side, User player) {
        playerMap.put(side, player);
    }

    public User getCurrentPlayer() {
        return playerMap.get(getCurrentSide());
    }

    public B getBoard() {
        return board;
    }

    public S getCurrentSide() {
        return sides.getCurrent();
    }

    public void nextPlayer() {
        sides.next();
    }

    public RuleCheckResult doAction(Action action) {
        RuleCheckResult result = ruleRunner.check(this, action);
        if (!result.isValid()) {
            return result;
        }
        ruleRunner.run(this, action);
        return RuleCheckResult.valid();
    }
}
