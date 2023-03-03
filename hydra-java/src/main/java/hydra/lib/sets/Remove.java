package hydra.lib.sets;

import hydra.core.Name;
import hydra.util.PrimitiveFunction;

import java.util.HashSet;
import java.util.Set;

public class Remove<A> extends PrimitiveFunction<A> {
    public Name name() {
        return new Name("hydra/lib/sets.remove");
    }

    public static <B> Set<B> apply(B elem, Set<B> arg) {
        Set<B> newSet = new HashSet(arg);
        newSet.remove(elem);
        return newSet;
    }
}