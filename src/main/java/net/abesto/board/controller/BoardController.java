package net.abesto.board.controller;

import javax.inject.Inject;

import net.abesto.board.model.Board;
import net.abesto.board.model.GameContextManager;

import org.springframework.beans.factory.BeanFactory;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@RequestMapping("/test/board")
public class BoardController {
	@Inject
	private BeanFactory beanFactory;
	
	@RequestMapping("/empty")
	public String empty(final Model model) {
		model.addAttribute("board", getEmptyBoard());
		return "board";
	}

	public Board getEmptyBoard() {
		return beanFactory.getBean(GameContextManager.class)
				.getContext(EmptyBoardConfiguration.class)
				.getBean(Board.class);
	}
}
