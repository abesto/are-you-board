package net.abesto.board.model.board;

public final class Point implements BoardIndex {
    private int row, column;

    public Point(int row, int column) {
        super();
        this.row = row;
        this.column = column;
    }

    public int getColumn() {
        return column;
    }

    public int getRow() {
        return row;
    }

    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        result = prime * result + column;
        result = prime * result + row;
        return result;
    }

    @Override
    public boolean equals(Object obj) {
        if (this == obj)
            return true;
        if (obj == null)
            return false;
        if (getClass() != obj.getClass())
            return false;
        Point other = (Point) obj;
        return column == other.column && row == other.row;
    }

    public Point offset(Point vector) {
        return new Point(row + vector.row, column + vector.column);
    }
}
