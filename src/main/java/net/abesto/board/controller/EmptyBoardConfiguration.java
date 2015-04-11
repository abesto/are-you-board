package net.abesto.board.controller;

import javax.inject.Singleton;

import net.abesto.board.model.Board;
import net.abesto.board.model.FieldProvider;
import net.abesto.board.model.GameConfiguration;
import net.abesto.board.model.SimpleFieldProvider;

import org.springframework.context.annotation.Bean;
import org.springframework.stereotype.Component;

@GameConfiguration
public class EmptyBoardConfiguration {
	@Bean
	public FieldProvider getFieldProvider() {
		return new SimpleFieldProvider();
	}

	@Bean
	public Board getBoard() {
		return new Board(getFieldProvider());
	}
}