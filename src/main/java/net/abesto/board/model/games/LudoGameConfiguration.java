package net.abesto.board.model.games;

import net.abesto.board.model.*;
import org.springframework.context.annotation.Bean;

import java.io.IOException;

@GameConfiguration
public class LudoGameConfiguration {
    @Bean
    public String boardDefinition() {
        return "net/abesto/board/ludo.board";
    }

    @Bean
    public FieldProvider getFieldProvider() throws IOException {
        return new RectangleMatrixCssClassSimpleFieldProvider(boardDefinition());
    }

    @Bean
    public RectangleMatrixBoardSize getBoardSize() {
        return new RectangleMatrixBoardSize(11, 11);
    }

    @Bean
    public RectangleMatrixBoard getBoard() throws IOException {
        return new RectangleMatrixBoard(getFieldProvider(), getBoardSize());
    }

}
