package net.abesto.board.model.game;

import net.abesto.board.model.Game;
import net.abesto.board.model.action.RectangleMatrixClick;
import net.abesto.board.model.board.RectangleMatrixBoard;
import net.abesto.board.model.board.RectangleMatrixBoardSize;
import net.abesto.board.model.board.RectangleMatrixSimpleFieldProvider;
import net.abesto.board.model.rule.*;
import net.abesto.board.model.side.ConnectNSide;
import net.abesto.board.model.side.ConnectNSides;
import net.abesto.board.model.side.Sides;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Scope;

import java.io.IOException;

@GameConfiguration
public class TicTacToeConfiguration {
    @Bean
    public RectangleMatrixSimpleFieldProvider getFieldProvider() {
        return new RectangleMatrixSimpleFieldProvider();
    }

    @Bean
    public RectangleMatrixBoardSize getBoardSize() {
        return new RectangleMatrixBoardSize(3, 3);
    }

    @Bean
    @Scope("prototype")
    public RectangleMatrixBoard getBoard() throws IOException {
        return new RectangleMatrixBoard(getFieldProvider(), getBoardSize());
    }

    @Bean
    public RuleMap getRuleMap() {
        RuleMap map = new RuleMap();
        map.setRulesForAction(RectangleMatrixClick.class,
                new OnlyCurrentPlayerMayMove(),
                new OnlyOnePieceOnOneField(),
                new PlaceNewPieceAtTarget(new SideProviderCurrent()),
                new NextPlayer(),
                new ConnectNVictoryCondition(3)
        );
        return map;
    }

    @Bean
    public Sides<ConnectNSide> getSides() {
        return new ConnectNSides();
    }

    @Bean
    @Scope("prototype")
    public Game getGame() throws IOException {
        return new Game<>(
                getBoard(),
                getRuleMap(),
                getSides()
        );
    }
}