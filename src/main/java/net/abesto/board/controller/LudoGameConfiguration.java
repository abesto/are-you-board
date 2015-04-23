package net.abesto.board.controller;

import net.abesto.board.model.FieldProvider;
import net.abesto.board.model.GameConfiguration;
import net.abesto.board.model.LudoBoard;
import net.abesto.board.model.RectangleMatrixCssClassSimpleFieldProvider;
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
    public LudoBoard getBoard() throws IOException {
        return new LudoBoard(getFieldProvider());
    }

}
