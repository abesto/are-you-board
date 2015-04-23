package net.abesto.board.controller;

import java.io.IOException;

import org.springframework.context.annotation.Bean;

import net.abesto.board.model.LudoBoard;
import net.abesto.board.model.RectangleMatrixCssClassSimpleFieldProvider;
import net.abesto.board.model.FieldProvider;
import net.abesto.board.model.GameConfiguration;

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
