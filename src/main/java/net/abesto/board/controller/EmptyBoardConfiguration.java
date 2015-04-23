package net.abesto.board.controller;

import net.abesto.board.model.LudoBoard;
import net.abesto.board.model.FieldProvider;
import net.abesto.board.model.GameConfiguration;
import net.abesto.board.model.RectangleMatrixSimpleFieldProvider;

import org.springframework.context.annotation.Bean;

@GameConfiguration
public class EmptyBoardConfiguration {
	@Bean
	public FieldProvider getFieldProvider() {
		return new RectangleMatrixSimpleFieldProvider();
	}

	@Bean
	public LudoBoard getBoard() {
		return new LudoBoard(getFieldProvider());
	}
}