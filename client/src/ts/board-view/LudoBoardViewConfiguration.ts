import board = require("../shared/board");
import IBoardViewConfiguration = require("./IBoardViewConfiguration");

const LudoBoardViewConfiguration: IBoardViewConfiguration = {
    boardClassName: "ludo-board",
    pieceClassName: "ludo-piece",
    fieldTypeToCssClass: {},
    pieceColorToCssClass: {}
};
LudoBoardViewConfiguration.fieldTypeToCssClass[board.LudoFieldType.WHITE] = 'white';
LudoBoardViewConfiguration.fieldTypeToCssClass[board.LudoFieldType.GREEN] = 'green';
LudoBoardViewConfiguration.fieldTypeToCssClass[board.LudoFieldType.YELLOW] = 'yellow';
LudoBoardViewConfiguration.fieldTypeToCssClass[board.LudoFieldType.BLUE] = 'blue';
LudoBoardViewConfiguration.fieldTypeToCssClass[board.LudoFieldType.RED] = 'red';
LudoBoardViewConfiguration.fieldTypeToCssClass[board.LudoFieldType.BLACK] = 'black';
LudoBoardViewConfiguration.fieldTypeToCssClass[board.LudoFieldType.BLANK] = 'blank';
LudoBoardViewConfiguration.pieceColorToCssClass[board.PieceColor.BLUE] = 'blue';
LudoBoardViewConfiguration.pieceColorToCssClass[board.PieceColor.RED] = 'red';
LudoBoardViewConfiguration.pieceColorToCssClass[board.PieceColor.GREEN] = 'green';
LudoBoardViewConfiguration.pieceColorToCssClass[board.PieceColor.YELLOW] = 'yellow';

export = LudoBoardViewConfiguration
