function LudoRow(index) {
    this.index = index;
    this.fields = [];
    for (var column = 0; column < 11; column++) {
        this.fields.push(new LudoField(this.index, column));
    }
}

function LudoField(row, column) {
    this.row = row;
    this.column = column;
    return this;
}

LudoBoard = function LudoBoard() {
    this.rows = [];
    for (var row = 0; row < 11; row++) {
        this.rows.push(new LudoRow(row));
    }
    return this;
}
