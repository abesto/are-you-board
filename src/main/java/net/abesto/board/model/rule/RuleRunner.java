package net.abesto.board.model.rule;

import net.abesto.board.model.Game;
import net.abesto.board.model.action.Action;

import java.util.List;

public class RuleRunner {
    protected RuleMap ruleMap;

    public RuleRunner(RuleMap ruleMap) {
        this.ruleMap = ruleMap;
    }

    protected List<Rule> rulesForAction(Action action) {
        return ruleMap.get(action.getClass());
    }

    public RuleCheckResult check(Game game, Action action) {
        List<Rule> rules = rulesForAction(action);
        if (rules == null) {
            return RuleCheckResult.valid();
        }
        for (Rule rule : rules) {
            RuleCheckResult result = rule.check(game, action);
            if (!result.isValid()) {
                return result;
            }
        }
        return RuleCheckResult.valid();
    }

    public void run(Game game, Action action) {
        List<Rule> rules = rulesForAction(action);
        if (rules != null) {
            for (Rule rule : rules) {
                rule.apply(game, action);
            }
        }
    }
}
