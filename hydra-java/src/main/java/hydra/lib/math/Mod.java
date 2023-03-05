package hydra.lib.math;

import hydra.core.Name;
import hydra.util.PrimitiveFunction;

public class Mod<A> extends PrimitiveFunction<A> {
    public Name name() {
        return new Name("hydra/lib/math.mod");
    }

    public static Integer apply(Integer dividend, Integer divisor) {
        return java.lang.Math.floorMod(dividend, divisor);
    }
}