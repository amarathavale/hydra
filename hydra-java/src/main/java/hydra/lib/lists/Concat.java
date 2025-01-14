package hydra.lib.lists;

import hydra.Flows;
import hydra.compute.Flow;
import hydra.core.Name;
import hydra.core.Term;
import hydra.core.Type;
import hydra.dsl.Expect;
import hydra.dsl.Terms;
import hydra.graph.Graph;
import hydra.tools.PrimitiveFunction;

import java.util.Collection;
import java.util.List;
import java.util.function.Function;
import java.util.stream.Collectors;
import static hydra.dsl.Types.*;

public class Concat<A> extends PrimitiveFunction<A> {
    public static final Name NAME = new Name("hydra/lib/lists.concat");

    public Name name() {
        return NAME;
    }

    @Override
    public Type<A> type() {
        return lambda("x", function(list(list("x")), list("x")));
    }

    @Override
    protected Function<List<Term<A>>, Flow<Graph<A>, Term<A>>> implementation() {
        return args -> Flows.map(Expect.list(t -> Expect.list(Flows::pure, t), args.get(0)), l -> Terms.list(apply(l)));
    }

    public static <X> List<X> apply(List<List<X>> sublists) {
        return sublists.stream().flatMap(Collection::stream).collect(Collectors.toList());
    }
}
