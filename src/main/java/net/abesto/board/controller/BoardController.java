package net.abesto.board.controller;

import javax.inject.Inject;

import net.abesto.board.model.LudoBoard;
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
	public String empty(Model model) {
		model.addAttribute("board", getBoard(EmptyBoardConfiguration.class));
		return "board";
	}
	
	@RequestMapping("/ludo")
	public String ludo(Model model) {
		model.addAttribute("board", getBoard(LudoGameConfiguration.class));
		return "board";
	}

	public LudoBoard getBoard(Class<?> configuration) {
		return beanFactory.getBean(GameContextManager.class)
				.getContext(configuration)
				.getBean(LudoBoard.class);
	}
}
