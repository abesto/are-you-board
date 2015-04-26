package net.abesto.board.model;

import net.abesto.board.model.board.*;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.context.annotation.Bean;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.AbstractJUnit4SpringContextTests;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;

import javax.inject.Inject;
import java.io.IOException;

import static org.hamcrest.Matchers.instanceOf;
import static org.junit.Assert.*;

class ColorMapFieldProviderTestConfiguration {
    @Bean
    public FieldProvider getTestFieldProvider() throws IOException {
        return new RectangleMatrixCssClassSimpleFieldProvider(getBoardDefOnClasspath());
    }

    @Bean
    public String getBoardDefOnClasspath() {
        return "net/abesto/board/model/test.board";
    }
}

@RunWith(SpringJUnit4ClassRunner.class)
@ContextConfiguration(classes = {ColorMapFieldProviderTestConfiguration.class})
public class ColorMapFieldProviderTest extends AbstractJUnit4SpringContextTests {
    @Inject
    private RectangleMatrixCssClassSimpleFieldProvider provider;

    @Test
    public void test() throws Exception {
        String w = null;
        String r = "r";
        String g = "g";
        String[][] expected = {
                {w, r, g, w},
                {r, w, w, g},
                {w, g, r, w}
        };
        for (int row = 0; row < 3; row++) {
            for (int column = 0; column < 4; column++) {
                FieldStyle style = provider.get(row, column).getStyle();
                String expectedClassname = expected[row][column];
                String msg = String.format("row=%d column=%d", row, column);
                if (expectedClassname == null) {
                    assertSame(msg, NoFieldStyle.getInstance(), style);
                } else {
                    assertThat(style, instanceOf(FieldStyleCssClassName.class));
                    FieldStyleCssClassName styleCasted = (FieldStyleCssClassName) style;
                    assertEquals(
                            String.format("row=%d column=%d", row, column),
                            expected[row][column], styleCasted.getCssClassName());
                }
            }
        }
    }

}
