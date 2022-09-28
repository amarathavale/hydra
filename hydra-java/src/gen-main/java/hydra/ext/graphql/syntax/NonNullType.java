package hydra.ext.graphql.syntax;

public abstract class NonNullType {
  public static final hydra.core.Name NAME = new hydra.core.Name("hydra/ext/graphql/syntax.NonNullType");
  
  private NonNullType () {
  
  }
  
  public abstract <R> R accept(Visitor<R> visitor) ;
  
  public interface Visitor<R> {
    R visit(Named instance) ;
    
    R visit(List instance) ;
  }
  
  public interface PartialVisitor<R> extends Visitor<R> {
    default R otherwise(NonNullType instance) {
      throw new IllegalStateException("Non-exhaustive patterns when matching: " + (instance));
    }
    
    default R visit(Named instance) {
      return otherwise((instance));
    }
    
    default R visit(List instance) {
      return otherwise((instance));
    }
  }
  
  public static final class Named extends hydra.ext.graphql.syntax.NonNullType {
    public final hydra.ext.graphql.syntax.NonNullType_Named value;
    
    public Named (hydra.ext.graphql.syntax.NonNullType_Named value) {
      this.value = value;
    }
    
    @Override
    public boolean equals(Object other) {
      if (!(other instanceof Named)) {
        return false;
      }
      Named o = (Named) (other);
      return value.equals(o.value);
    }
    
    @Override
    public int hashCode() {
      return 2 * value.hashCode();
    }
    
    @Override
    public <R> R accept(Visitor<R> visitor) {
      return visitor.visit(this);
    }
  }
  
  public static final class List extends hydra.ext.graphql.syntax.NonNullType {
    public final hydra.ext.graphql.syntax.NonNullType_List value;
    
    public List (hydra.ext.graphql.syntax.NonNullType_List value) {
      this.value = value;
    }
    
    @Override
    public boolean equals(Object other) {
      if (!(other instanceof List)) {
        return false;
      }
      List o = (List) (other);
      return value.equals(o.value);
    }
    
    @Override
    public int hashCode() {
      return 2 * value.hashCode();
    }
    
    @Override
    public <R> R accept(Visitor<R> visitor) {
      return visitor.visit(this);
    }
  }
}