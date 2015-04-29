package net.abesto.board.model.rule;

import net.abesto.board.model.Game;
import net.abesto.board.model.action.Action;

import java.util.List;

public class RuleRunner<G extends Game<?, ?>> {
    protected RuleMap<G> ruleMap;

    public RuleRunner(RuleMap<G> ruleMap) {
        this.ruleMap = ruleMap;
    }

    public <A extends Action> RuleCheckResult check(G game, A action) {
        List<Rule<G, ? super A>> rules = getRules(action);
        if (rules == null) {
            return RuleCheckResult.valid();
        }
        for (Rule<G, ? super A> rule : rules) {
            RuleCheckResult result = rule.check(game, action);
            if (!result.isValid()) {
                return result;
            }
        }
        return RuleCheckResult.valid();
    }

    private <A extends Action> List<Rule<G, ? super A>> getRules(A action) {
        return ruleMap.get(action);
    }

    public <A extends Action> void run(G game, A action) {
        List<Rule<G, ? super A>> rules = getRules(action);
        if (rules != null) {
            for (Rule<G, ? super A> rule : rules) {
                rule.apply(game, action);
            }
        }
    }
}
