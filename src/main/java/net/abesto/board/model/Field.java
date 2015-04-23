package net.abesto.board.model;

import java.util.Optional;

public class Field<I> {
    protected I index;
    protected Optional<Piece> piece;
    protected FieldStyle style;

    public Field(I index, FieldStyle style) {
    	this.index = index;
        this.piece = Optional.empty();
        this.style = style;
    }
    
    public Field(I index) {
    	this(index, NoFieldStyle.getInstance());
    }
    
    public I getIndex() {
		return index;
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
