package net.abesto.board.model;

import java.util.Optional;

public final class Field {
    private Position position;
    private Optional<Piece> piece;
    private FieldStyle style;

    public Field(Position position, FieldStyle style) {
    	this.position = position;
        this.piece = Optional.empty();
        this.style = style;
    }
    
    public Field(Position position) {
    	this(position, NoFieldStyle.getInstance());
    }
    
    public Field(int row, int column) {
    	this(new Position(row, column));
    }

    public int getRow() {
        return position.getRow();
    }

    public int getColumn() {
        return position.getColumn();
    }
    
    public Position getPosition() {
		return position;
	}

    public Piece getPiece() {
    	if (!piece.isPresent()) {
    		throw new FieldEmptyException(this);
    	}
        return piece.get();
    }

    public void setPiece(Piece piece) {
        if (this.piece.isPresent()) {
            throw new FieldNotEmptyException(this, this.piece.get());
        }
        this.piece = Optional.of(piece);
    }

    public boolean isEmpty() {
        return !piece.isPresent();
    }

    public void removePiece() {
    	piece = Optional.empty();
    }
    
    public FieldStyle getStyle() {
		return style;
	}
    
    public void setStyle(FieldStyle style) {
		this.style = style;
	}
}
