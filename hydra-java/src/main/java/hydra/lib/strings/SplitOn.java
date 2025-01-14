package hydra.lib.strings;

import hydra.compute.Flow;
import hydra.core.Name;
import hydra.core.Term;
import hydra.core.Type;
import hydra.dsl.Expect;
import hydra.dsl.Terms;
import hydra.graph.Graph;
import hydra.tools.PrimitiveFunction;

import static hydra.Flows.*;
import static hydra.dsl.Types.*;

import java.util.function.BiFunction;
import java.util.function.Function;
import java.util.List;
import java.util.ArrayList;

public class SplitOn<A> extends PrimitiveFunction<A> {
    public Name name() {
        return new Name("hydra/lib/strings.splitOn");
    }

    @Override
    public Type<A> type() {
        return function(string(), string(), list(string()));
    }

    @Override
    protected Function<List<Term<A>>, Flow<Graph<A>, Term<A>>> implementation() {
        return args -> map2(Expect.string(args.get(0)), Expect.string(args.get(1)),
            (BiFunction<String, String, Term<A>>) (s, s2) -> Terms.listOfStrings(apply(s, s2)));
    }

    public static Function<String, List<String>> apply(String delim) {
        return (string) -> apply(delim, string);
    }

    // Note: the delimiter is not interpreted as a regular expression; it is simply a literal string. See Haskell's Data.List.Split.
    public static List<String> apply(String delim, String string) {
        List<String> parts = new ArrayList<>();

        if (delim.length() == 0) {
            parts.add("");
            for (int i = 0; i < string.length(); i++) {
                parts.add(string.substring(i, i+1));
            }
        } else {
            byte[] delimBytes = delim.getBytes();
            byte[] stringBytes = string.getBytes();

            int k = 0;
            for (int i = 0; i <= stringBytes.length - delimBytes.length; i++) {
                boolean match = true;

                for (int j = 0; j < delimBytes.length; j++) {
                    if (stringBytes[i + j] != delimBytes[j]) {
                        match = false;
                        break;
                    }
                }

                if (match) {
                    parts.add(string.substring(k, i));
                    i += delimBytes.length;
                    k = i;
                    i--;
                }
            }

            parts.add(string.substring(k));
        }

        return parts;
    }
}
