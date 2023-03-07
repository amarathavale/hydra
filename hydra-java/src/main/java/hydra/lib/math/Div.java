package hydra.lib.math;

import hydra.core.Name;
import hydra.util.PrimitiveFunction;

import java.util.function.Function;

public class Div<A> extends PrimitiveFunction<A> {
    public Name name() {
        return new Name("hydra/lib/math.div");
    }

    public static Function<Integer, Integer> apply(Integer dividend) {
        return (divisor) -> dividend / divisor;
    }

    public static Integer apply(Integer dividend, Integer divisor) {
        return Div.apply(dividend).apply(divisor);
    }
}
