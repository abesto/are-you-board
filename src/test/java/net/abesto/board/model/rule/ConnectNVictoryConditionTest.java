package net.abesto.board.model.rule;

import net.abesto.board.model.Game;
import net.abesto.board.model.Piece;
import net.abesto.board.model.action.RectangleMatrixClick;
import net.abesto.board.model.board.Point;
import net.abesto.board.model.board.RectangleMatrixBoard;
import net.abesto.board.model.board.RectangleMatrixBoardSize;
import net.abesto.board.model.board.RectangleMatrixField;
import net.abesto.board.model.game.TicTacToeConfiguration;
import net.abesto.board.model.side.ConnectNSide;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.context.annotation.Bean;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.AbstractJUnit4SpringContextTests;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;

import static org.junit.Assert.*;

class ConnectNVictoryConditionTestConfiguration extends TicTacToeConfiguration {
    @Bean
    public RectangleMatrixBoardSize getBoardSize() {
        return new RectangleMatrixBoardSize(30, 30);
    }
}

@RunWith(SpringJUnit4ClassRunner.class)
@ContextConfiguration(classes = {ConnectNVictoryConditionTestConfiguration.class})
@SuppressWarnings("unchecked")
public class ConnectNVictoryConditionTest extends AbstractJUnit4SpringContextTests {
    private RectangleMatrixBoard<ConnectNSide> givenAnEmptyBoard() {
        return applicationContext.getBean(RectangleMatrixBoard.class);
    }

    private ConnectNVictoryCondition givenAConnectNVictoryCondition(int n) {
        return new ConnectNVictoryCondition(n);
    }

    private Game givenAGame() {
        return applicationContext.getBean(Game.class);
    }

    private Piece<ConnectNSide> pieceX() {
        return new Piece<>(ConnectNSide.X);
    }

    private Piece<ConnectNSide> pieceO() {
        return new Piece<>(ConnectNSide.O);
    }

    @Test
    public void testCountConnected() throws Exception {
        RectangleMatrixBoard<ConnectNSide> board = givenAnEmptyBoard();
        ConnectNVictoryCondition action = givenAConnectNVictoryCondition(3);

        // Poor, lonely piece
        board.getField(1, 5).setPiece(pieceX());
        assertEquals(0, action.countConnected(board, board.getField(1, 5), new Point(0, 1)));

        // Connect one to it
        board.getField(1, 6).setPiece(pieceX());
        assertEquals(1, action.countConnected(board, board.getField(1, 5), new Point(0, 1)));

        // Connect another
        board.getField(1, 7).setPiece(pieceX());
        assertEquals(2, action.countConnected(board, board.getField(1, 5), new Point(0, 1)));

        // Connect a different piece
        board.getField(1, 8).setPiece(pieceO());
        assertEquals(2, action.countConnected(board, board.getField(1, 5), new Point(0, 1)));

        // Connect one, up
        board.getField(1, 4).setPiece(pieceX());
        assertEquals(1, action.countConnected(board, board.getField(1, 5), new Point(0, -1)));

        // And count by axis
        assertEquals(4, action.countByAxis(board, board.getField(1, 5), new ConnectNVictoryCondition.Axis(new Point(0, 1), new Point(0, -1))));
    }

    @Test
    public void testCountByAxis() throws Exception {
        ConnectNVictoryCondition action = givenAConnectNVictoryCondition(3);

        Point center = new Point(10, 10);
        for (ConnectNVictoryCondition.Axis axis : ConnectNVictoryCondition.axes) {
            RectangleMatrixBoard<ConnectNSide> board = givenAnEmptyBoard();
            RectangleMatrixField centerField = board.getField(center);

            board.getField(center).setPiece(pieceO());
            assertEquals(1, action.countByAxis(board, centerField, axis));

            board.getField(center.offset(axis.getVectorA())).setPiece(pieceO());
            assertEquals(2, action.countByAxis(board, centerField, axis));

            board.getField(center.offset(axis.getVectorB())).setPiece(pieceO());
            assertEquals(3, action.countByAxis(board, centerField, axis));
        }
    }

    @Test
    public void testApply() throws Exception {
        ConnectNVictoryCondition action = givenAConnectNVictoryCondition(3);

        Point center = new Point(10, 10);
        for (ConnectNVictoryCondition.Axis axis : ConnectNVictoryCondition.axes) {
            Game game = givenAGame();
            RectangleMatrixBoard<ConnectNSide> board = (RectangleMatrixBoard) game.getBoard();
            RectangleMatrixField centerField = board.getField(center);

            board.getField(center).setPiece(pieceO());
            action.apply(game, new RectangleMatrixClick(null, centerField));
            assertFalse(game.isOver());

            board.getField(center.offset(axis.getVectorA())).setPiece(pieceO());
            action.apply(game, new RectangleMatrixClick(null, centerField));
            assertFalse(game.isOver());

            board.getField(center.offset(axis.getVectorB())).setPiece(pieceO());
            action.apply(game, new RectangleMatrixClick(null, centerField));
            assertTrue(game.isOver());
        }
    }
}