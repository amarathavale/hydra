package hydra.lib.math;

import hydra.compute.Flow;
import hydra.core.Name;
import hydra.core.Term;
import hydra.core.Type;
import hydra.dsl.Expect;
import hydra.dsl.Terms;
import hydra.graph.Graph;
import hydra.tools.PrimitiveFunction;

import java.util.List;
import java.util.function.Function;

import static hydra.Flows.*;
import static hydra.dsl.Types.*;

public class Mod<A> extends PrimitiveFunction<A> {
    public Name name() {
        return new Name("hydra/lib/math.mod");
    }

    @Override
    public Type<A> type() {
        return function(int32(), int32(), int32());
    }

    @Override
    protected Function<List<Term<A>>, Flow<Graph<A>, Term<A>>> implementation() {
        return args -> map2(Expect.int32(args.get(0)), Expect.int32(args.get(1)),
            (arg0, arg1) -> Terms.int32(apply(arg0, arg1)));
    }

    public static Function<Integer, Integer> apply(Integer dividend) {
        return (divisor) -> apply(dividend, divisor);
    }

    public static Integer apply(Integer dividend, Integer divisor) {
        return java.lang.Math.floorMod(dividend, divisor);
    }
}
