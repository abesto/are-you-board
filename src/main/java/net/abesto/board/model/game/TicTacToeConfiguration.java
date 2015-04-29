package net.abesto.board.model.game;

import net.abesto.board.model.Game;
import net.abesto.board.model.action.RectangleMatrixClick;
import net.abesto.board.model.board.*;
import net.abesto.board.model.rule.*;
import net.abesto.board.model.side.ConnectNSide;
import net.abesto.board.model.side.ConnectNSides;
import net.abesto.board.model.side.Sides;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Scope;

import java.io.IOException;
import java.util.Arrays;

@GameConfiguration
public class TicTacToeConfiguration {
    @Bean
    public RectangleMatrixFieldProvider<ConnectNSide> getFieldProvider() {
        return new RectangleMatrixSimpleFieldProvider<>();
    }

    @Bean
    public RectangleMatrixBoardSize getBoardSize() {
        return new RectangleMatrixBoardSize(3, 3);
    }

    @Bean
    @Scope("prototype")
    public RectangleMatrixBoard<ConnectNSide> getBoard() throws IOException {
        return new RectangleMatrixBoard<>(getFieldProvider(), getBoardSize());
    }

    @Bean
    public RuleMap<Game<ConnectNSide, RectangleMatrixBoard<ConnectNSide>>> getRuleMap() {
        RuleMap<Game<ConnectNSide, RectangleMatrixBoard<ConnectNSide>>> map = new RuleMap<>();
        map.appendRuleForAction(RectangleMatrixClick.class, new OnlyCurrentPlayerMayMove<>());
        map.appendRuleForAction(RectangleMatrixClick.class, new OnlyOnePieceOnOneField<>());
        map.appendRuleForAction(RectangleMatrixClick.class, new PlaceNewPieceAtTarget<>(new SideProviderCurrent<>()));
        map.appendRuleForAction(RectangleMatrixClick.class, new NextPlayer<>());
        map.appendRuleForAction(RectangleMatrixClick.class, new ConnectNVictoryCondition<>(3));

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