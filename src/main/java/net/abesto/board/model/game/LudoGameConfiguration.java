package net.abesto.board.model.game;

import net.abesto.board.model.board.*;
import net.abesto.board.model.side.NumberedSide;
import org.springframework.context.annotation.Bean;

import java.io.IOException;

@GameConfiguration
public class LudoGameConfiguration {
    @Bean
    public String boardDefinition() {
        return "net/abesto/board/ludo.board";
    }

    @Bean
    public RectangleMatrixFieldProvider<NumberedSide> getFieldProvider() throws IOException {
        return new RectangleMatrixCssClassSimpleFieldProvider<>(boardDefinition());
    }

    @Bean
    public RectangleMatrixBoardSize getBoardSize() {
        return new RectangleMatrixBoardSize(11, 11);
    }

    @Bean
    public RectangleMatrixBoard<NumberedSide> getBoard() throws IOException {
        return new RectangleMatrixBoard<>(getFieldProvider(), getBoardSize());
    }

}
