package hydra.lib.lists;

import hydra.Flows;
import hydra.compute.Flow;
import hydra.core.Name;
import hydra.core.Term;
import hydra.core.Type;
import hydra.dsl.Expect;
import hydra.graph.Graph;
import hydra.tools.PrimitiveFunction;

import java.util.List;
import java.util.function.Function;

import static hydra.Flows.map;
import static hydra.dsl.Types.*;

public class Last<A> extends PrimitiveFunction<A> {
    public Name name() {
        return new Name("hydra/lib/lists.last");
    }

    @Override
    public Type<A> type() {
        return lambda("x", function(list("x"), "x"));
    }

    @Override
    protected Function<List<Term<A>>, Flow<Graph<A>, Term<A>>> implementation() {
        return args -> map(Expect.list(Flows::pure, args.get(0)), Last::apply);
    }

    public static <X> X apply(List<X> list) {
        return list.get(list.size() - 1);
    }
}
