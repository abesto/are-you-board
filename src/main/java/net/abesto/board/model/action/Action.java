package net.abesto.board.model.action;

import net.abesto.board.model.User;

public abstract class Action {
    protected User player;

    public Action(User player) {
        this.player = player;
    }

    public User getPlayer() {
        return player;
    }
}
