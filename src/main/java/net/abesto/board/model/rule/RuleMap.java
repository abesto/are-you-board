package net.abesto.board.model.rule;

import net.abesto.board.model.action.Action;

import java.util.Arrays;
import java.util.HashMap;
import java.util.List;

public class RuleMap extends HashMap<Class<? extends Action>, List<Rule>> {
    public void setRulesForAction(Class<? extends Action> action, Rule... rules) {
        put(action, Arrays.asList(rules));
    }
}
