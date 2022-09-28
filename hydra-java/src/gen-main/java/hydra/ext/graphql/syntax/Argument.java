package hydra.ext.graphql.syntax;

public class Argument {
  public static final hydra.core.Name NAME = new hydra.core.Name("hydra/ext/graphql/syntax.Argument");
  
  public final hydra.ext.graphql.syntax.Name name;
  
  public final hydra.ext.graphql.syntax.Value value;
  
  public Argument (hydra.ext.graphql.syntax.Name name, hydra.ext.graphql.syntax.Value value) {
    this.name = name;
    this.value = value;
  }
  
  @Override
  public boolean equals(Object other) {
    if (!(other instanceof Argument)) {
      return false;
    }
    Argument o = (Argument) (other);
    return name.equals(o.name) && value.equals(o.value);
  }
  
  @Override
  public int hashCode() {
    return 2 * name.hashCode() + 3 * value.hashCode();
  }
  
  public Argument withName(hydra.ext.graphql.syntax.Name name) {
    return new Argument(name, value);
  }
  
  public Argument withValue(hydra.ext.graphql.syntax.Value value) {
    return new Argument(name, value);
  }
}