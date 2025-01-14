package hydra.lib.sets;

import hydra.Flows;
import hydra.compute.Flow;
import hydra.core.Name;
import hydra.core.Term;
import hydra.core.Type;
import hydra.dsl.Terms;
import hydra.graph.Graph;
import hydra.tools.PrimitiveFunction;

import java.util.Collections;
import java.util.List;
import java.util.Set;
import java.util.function.Function;

import static hydra.dsl.Types.*;

public class Empty<A> extends PrimitiveFunction<A> {
    public Name name() {
        return new Name("hydra/lib/sets.empty");
    }

    @Override
    public Type<A> type() {
        return lambda("x", set("x"));
    }

    @Override
    protected Function<List<Term<A>>, Flow<Graph<A>, Term<A>>> implementation() {
        return ignored -> Flows.pure(Terms.set(apply()));
    }

    public static <X> Set<X> apply() {
        return Collections.emptySet();
    }
}
