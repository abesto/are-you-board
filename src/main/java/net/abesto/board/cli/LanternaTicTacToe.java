package net.abesto.board.cli;

import com.googlecode.lanterna.TerminalFacade;
import com.googlecode.lanterna.input.Key;
import com.googlecode.lanterna.screen.Screen;
import com.googlecode.lanterna.screen.ScreenWriter;
import net.abesto.board.model.Game;
import net.abesto.board.model.User;
import net.abesto.board.model.action.Action;
import net.abesto.board.model.action.RectangleMatrixClick;
import net.abesto.board.model.board.*;
import net.abesto.board.model.game.TicTacToeConfiguration;
import net.abesto.board.model.rule.RuleMap;
import net.abesto.board.model.side.ConnectNSide;
import net.abesto.board.model.side.Side;
import net.abesto.board.model.side.Sides;
import org.springframework.beans.factory.BeanFactory;
import org.springframework.context.annotation.AnnotationConfigApplicationContext;

import java.util.Map;


public class LanternaTicTacToe<
        B extends RectangleMatrixBoard<ConnectNSide>,
        G extends Game<ConnectNSide, B>> {

    @SuppressWarnings("unchecked")
    private G buildGame() {
        BeanFactory beanFactory = new AnnotationConfigApplicationContext(TicTacToeConfiguration.class);
        return (G) beanFactory.getBean(Game.class);
    }

    private void render(Screen screen, G game) {
        ScreenWriter writer = new ScreenWriter(screen);
        screen.clear();

        renderBoard(game, writer);
        renderSides(game, writer);
        renderCurrentSide(game, writer);
        renderIsOver(game, writer);
        renderWinner(game, writer);

        screen.refresh();
    }

    private void renderWinner(G game, ScreenWriter writer) {
        if (game.getWinnerSide() != null) {
            writer.drawString(0, 6, "Winner: " + game.getWinnerPlayer().getName() + " (" + game.getWinnerSide() + ")");
        }
    }

    private void renderIsOver(G game, ScreenWriter writer) {
        writer.drawString(0, 5, "Is over: " + game.isOver());
    }

    private void renderCurrentSide(G game, ScreenWriter writer) {
        writer.drawString(10, 2, "Current player: " + game.getCurrentPlayer().getName() + " (" + game.getCurrentSide() + ")");
    }

    private void renderSides(G game, ScreenWriter writer) {
        int i = 0;
        for (Map.Entry<? extends Side, User> entry : game.getPlayerMap().entrySet()) {
            writer.drawString(10, i++, entry.getKey().toString() + ": " + entry.getValue().getName());
        }
    }

    private void renderBoard(G game, ScreenWriter writer) {
        for (Field field : game.getBoard().getFieldsIterable()) {
            Point position = (Point) field.getIndex();
            String c = getFieldChar(positionToIndex(position), field);
            writer.drawString(position.getColumn(), position.getRow(), c);
        }
    }

    private int positionToIndex(Point position) {
        return position.getRow() * 3 + position.getColumn();
    }

    private String getFieldChar(int i, Field field) {
        String c;
        if (field.isEmpty()) {
            c = Integer.toString(i);
        } else {
            c = field.getPiece().getSide().toString();
        }
        if (c.length() != 1) {
            throw new RuntimeException("Field char is not 1 char long, I'm confused: '" + c + "'");
        }
        return c;
    }

    private void step(Screen screen, G game) throws InterruptedException {
        Key input = getKey(screen);

        char c = input.getCharacter();

        if (c == 'q') {
            game.setOver(true);
            return;
        }

        if (c < '0' && c > '9') {
            return;
        }

        int n = input.getCharacter() - '0';
        Action action = new RectangleMatrixClick<>(
                game.getCurrentPlayer(),
                game.getBoard().getField(indexToPosition(n)));
        game.doAction(action);
    }

    private Key getKey(Screen screen) throws InterruptedException {
        Key input = screen.readInput();
        while (input == null) {
            Thread.sleep(1);
            input = screen.readInput();
        }
        return input;
    }

    private Point indexToPosition(int n) {
        return new Point(n / 3, n % 3);
    }

    private void run() throws InterruptedException {
        Screen screen = TerminalFacade.createScreen();
        try {
            screen.startScreen();
            G game = buildGame();
            game.join(ConnectNSide.X, new User("Alice"));
            game.join(ConnectNSide.O, new User("Bob"));

            while (!game.isOver()) {
                render(screen, game);
                step(screen, game);
            }
            render(screen, game);

            // Ugly heuristic for "did you NOT exit with q?"
            if (game.getWinnerSide() != null) {
                getKey(screen);
            }
        } finally {
            screen.stopScreen();
        }
    }

    public static void main(String[] args) throws InterruptedException {
        LanternaTicTacToe instance = new LanternaTicTacToe();
        instance.run();
    }
}
