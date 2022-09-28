package hydra.ext.graphql.syntax;

public class InterfaceTypeExtension_Sequence3 {
  public static final hydra.core.Name NAME = new hydra.core.Name("hydra/ext/graphql/syntax.InterfaceTypeExtension.Sequence3");
  
  public final hydra.ext.graphql.syntax.Name name;
  
  public final hydra.ext.graphql.syntax.ImplementsInterfaces implementsInterfaces;
  
  public InterfaceTypeExtension_Sequence3 (hydra.ext.graphql.syntax.Name name, hydra.ext.graphql.syntax.ImplementsInterfaces implementsInterfaces) {
    this.name = name;
    this.implementsInterfaces = implementsInterfaces;
  }
  
  @Override
  public boolean equals(Object other) {
    if (!(other instanceof InterfaceTypeExtension_Sequence3)) {
      return false;
    }
    InterfaceTypeExtension_Sequence3 o = (InterfaceTypeExtension_Sequence3) (other);
    return name.equals(o.name) && implementsInterfaces.equals(o.implementsInterfaces);
  }
  
  @Override
  public int hashCode() {
    return 2 * name.hashCode() + 3 * implementsInterfaces.hashCode();
  }
  
  public InterfaceTypeExtension_Sequence3 withName(hydra.ext.graphql.syntax.Name name) {
    return new InterfaceTypeExtension_Sequence3(name, implementsInterfaces);
  }
  
  public InterfaceTypeExtension_Sequence3 withImplementsInterfaces(hydra.ext.graphql.syntax.ImplementsInterfaces implementsInterfaces) {
    return new InterfaceTypeExtension_Sequence3(name, implementsInterfaces);
  }
}