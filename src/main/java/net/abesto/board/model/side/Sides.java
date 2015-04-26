package net.abesto.board.model.side;

public interface Sides<S extends Side> {
    public S getCurrent();

    public boolean isCurrent(S side);

    public S peekNext();

    public S next();
}
