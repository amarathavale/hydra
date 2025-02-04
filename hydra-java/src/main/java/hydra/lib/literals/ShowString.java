package hydra.lib.literals;

import hydra.Flows;
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
import org.apache.commons.text.StringEscapeUtils;
import static hydra.dsl.Types.*;

public class ShowString<A> extends PrimitiveFunction<A> {
    public Name name() {
        return new Name("hydra/lib/literals.showString");
    }

    @Override
    public Type<A> type() {
        return function(string(), string());
    }

    @Override
    protected Function<List<Term<A>>, Flow<Graph<A>, Term<A>>> implementation() {
        return args -> Flows.map(Expect.string(args.get(0)), (Function<String, Term<A>>) s -> Terms.string(apply(s)));
    }

    public static String apply(String value) {
        return "\"" + StringEscapeUtils.escapeJava(value) + "\"";
    }
}
