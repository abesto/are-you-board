package net.abesto.board.controller;

import net.abesto.board.model.board.RectangleMatrixBoard;
import net.abesto.board.model.game.EmptyBoardConfiguration;
import net.abesto.board.model.game.GameContextManager;
import net.abesto.board.model.game.LudoGameConfiguration;
import org.springframework.beans.factory.BeanFactory;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;

import javax.inject.Inject;

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

    public RectangleMatrixBoard getBoard(Class<?> configuration) {
        return beanFactory.getBean(GameContextManager.class)
                .getContext(configuration)
                .getBean(RectangleMatrixBoard.class);
    }
}
