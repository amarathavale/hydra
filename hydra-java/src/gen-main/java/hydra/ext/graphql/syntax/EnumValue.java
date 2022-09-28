package hydra.ext.graphql.syntax;

public class EnumValue {
  public static final hydra.core.Name NAME = new hydra.core.Name("hydra/ext/graphql/syntax.EnumValue");
  
  public final hydra.ext.graphql.syntax.Name name;
  
  public EnumValue (hydra.ext.graphql.syntax.Name name) {
    this.name = name;
  }
  
  @Override
  public boolean equals(Object other) {
    if (!(other instanceof EnumValue)) {
      return false;
    }
    EnumValue o = (EnumValue) (other);
    return name.equals(o.name);
  }
  
  @Override
  public int hashCode() {
    return 2 * name.hashCode();
  }
}