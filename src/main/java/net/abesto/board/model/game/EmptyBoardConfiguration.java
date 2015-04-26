package net.abesto.board.model.game;

import net.abesto.board.model.board.FieldProvider;
import net.abesto.board.model.board.RectangleMatrixBoard;
import net.abesto.board.model.board.RectangleMatrixBoardSize;
import net.abesto.board.model.board.RectangleMatrixSimpleFieldProvider;
import org.springframework.context.annotation.Bean;

import java.io.IOException;

@GameConfiguration
public class EmptyBoardConfiguration {
    @Bean
    public FieldProvider getFieldProvider() {
        return new RectangleMatrixSimpleFieldProvider();
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