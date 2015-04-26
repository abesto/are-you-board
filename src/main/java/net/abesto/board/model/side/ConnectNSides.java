package net.abesto.board.model.side;

public class ConnectNSides implements Sides<ConnectNSide> {
    protected ConnectNSide current;

    public ConnectNSides() {
        current = ConnectNSide.X;
    }

    @Override
    public ConnectNSide getCurrent() {
        return current;
    }

    @Override
    public boolean isCurrent(ConnectNSide side) {
        return side == current;
    }

    @Override
    public ConnectNSide peekNext() {
        if (current == ConnectNSide.O) {
            return ConnectNSide.X;
        }
        return ConnectNSide.O;
    }

    @Override
    public ConnectNSide next() {
        current = peekNext();
        return getCurrent();
    }
}
