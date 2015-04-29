package net.abesto.board.model.rule;

import net.abesto.board.model.Game;
import net.abesto.board.model.action.Action;

import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;

public class RuleMap<G extends Game<?, ?>> {
    protected Map<Class<? extends Action>, List<Rule<G, ? extends Action>>> rules;

    public RuleMap() {
        rules = new HashMap<>();
    }

    @SuppressWarnings("unchecked")
    public <A extends Action> void setRulesForAction(Class<A> action, List<Rule<G, A>> rules) {
        this.rules.put(action, (List) rules);
    }

    public <A extends Action> void appendRuleForAction(Class<A> action, Rule<G, A> rule) {
        if (rules.get(action) == null) {
            rules.put(action, new LinkedList<>());
        }
        rules.get(action).add(rule);
    }

    @SuppressWarnings("unchecked")
    public <A extends Action> List<Rule<G, ? super A>> get(A action) {
        return (List) rules.get(action.getClass());
    }
}
