package net.abesto.board.controller;

import java.io.IOException;

import org.springframework.context.annotation.Bean;

import net.abesto.board.model.Board;
import net.abesto.board.model.CssClassFieldProvider;
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
		return new CssClassFieldProvider(boardDefinition());
	}

	@Bean
	public Board getBoard() throws IOException {
		return new Board(getFieldProvider());
	}

}
