package hydra.ext.graphql.syntax;

public class FragmentDefinition {
  public static final hydra.core.Name NAME = new hydra.core.Name("hydra/ext/graphql/syntax.FragmentDefinition");
  
  public final hydra.ext.graphql.syntax.FragmentName fragmentName;
  
  public final hydra.ext.graphql.syntax.TypeCondition typeCondition;
  
  public final java.util.Optional<hydra.ext.graphql.syntax.Directives> directives;
  
  public final hydra.ext.graphql.syntax.SelectionSet selectionSet;
  
  public FragmentDefinition (hydra.ext.graphql.syntax.FragmentName fragmentName, hydra.ext.graphql.syntax.TypeCondition typeCondition, java.util.Optional<hydra.ext.graphql.syntax.Directives> directives, hydra.ext.graphql.syntax.SelectionSet selectionSet) {
    this.fragmentName = fragmentName;
    this.typeCondition = typeCondition;
    this.directives = directives;
    this.selectionSet = selectionSet;
  }
  
  @Override
  public boolean equals(Object other) {
    if (!(other instanceof FragmentDefinition)) {
      return false;
    }
    FragmentDefinition o = (FragmentDefinition) (other);
    return fragmentName.equals(o.fragmentName) && typeCondition.equals(o.typeCondition) && directives.equals(o.directives) && selectionSet.equals(o.selectionSet);
  }
  
  @Override
  public int hashCode() {
    return 2 * fragmentName.hashCode() + 3 * typeCondition.hashCode() + 5 * directives.hashCode() + 7 * selectionSet.hashCode();
  }
  
  public FragmentDefinition withFragmentName(hydra.ext.graphql.syntax.FragmentName fragmentName) {
    return new FragmentDefinition(fragmentName, typeCondition, directives, selectionSet);
  }
  
  public FragmentDefinition withTypeCondition(hydra.ext.graphql.syntax.TypeCondition typeCondition) {
    return new FragmentDefinition(fragmentName, typeCondition, directives, selectionSet);
  }
  
  public FragmentDefinition withDirectives(java.util.Optional<hydra.ext.graphql.syntax.Directives> directives) {
    return new FragmentDefinition(fragmentName, typeCondition, directives, selectionSet);
  }
  
  public FragmentDefinition withSelectionSet(hydra.ext.graphql.syntax.SelectionSet selectionSet) {
    return new FragmentDefinition(fragmentName, typeCondition, directives, selectionSet);
  }
}