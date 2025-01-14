package hydra.langs.graphql.syntax;

public abstract class TypeDefinition {
  public static final hydra.core.Name NAME = new hydra.core.Name("hydra/langs/graphql/syntax.TypeDefinition");
  
  private TypeDefinition () {
  
  }
  
  public abstract <R> R accept(Visitor<R> visitor) ;
  
  public interface Visitor<R> {
    R visit(Scalar instance) ;
    
    R visit(Object_ instance) ;
    
    R visit(Interface instance) ;
    
    R visit(Union instance) ;
    
    R visit(Enum_ instance) ;
    
    R visit(InputObject instance) ;
  }
  
  public interface PartialVisitor<R> extends Visitor<R> {
    default R otherwise(TypeDefinition instance) {
      throw new IllegalStateException("Non-exhaustive patterns when matching: " + (instance));
    }
    
    default R visit(Scalar instance) {
      return otherwise((instance));
    }
    
    default R visit(Object_ instance) {
      return otherwise((instance));
    }
    
    default R visit(Interface instance) {
      return otherwise((instance));
    }
    
    default R visit(Union instance) {
      return otherwise((instance));
    }
    
    default R visit(Enum_ instance) {
      return otherwise((instance));
    }
    
    default R visit(InputObject instance) {
      return otherwise((instance));
    }
  }
  
  public static final class Scalar extends hydra.langs.graphql.syntax.TypeDefinition {
    public final hydra.langs.graphql.syntax.ScalarTypeDefinition value;
    
    public Scalar (hydra.langs.graphql.syntax.ScalarTypeDefinition value) {
      this.value = value;
    }
    
    @Override
    public boolean equals(Object other) {
      if (!(other instanceof Scalar)) {
        return false;
      }
      Scalar o = (Scalar) (other);
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
  
  public static final class Object_ extends hydra.langs.graphql.syntax.TypeDefinition {
    public final hydra.langs.graphql.syntax.ObjectTypeDefinition value;
    
    public Object_ (hydra.langs.graphql.syntax.ObjectTypeDefinition value) {
      this.value = value;
    }
    
    @Override
    public boolean equals(Object other) {
      if (!(other instanceof Object_)) {
        return false;
      }
      Object_ o = (Object_) (other);
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
  
  public static final class Interface extends hydra.langs.graphql.syntax.TypeDefinition {
    public final hydra.langs.graphql.syntax.InterfaceTypeDefinition value;
    
    public Interface (hydra.langs.graphql.syntax.InterfaceTypeDefinition value) {
      this.value = value;
    }
    
    @Override
    public boolean equals(Object other) {
      if (!(other instanceof Interface)) {
        return false;
      }
      Interface o = (Interface) (other);
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
  
  public static final class Union extends hydra.langs.graphql.syntax.TypeDefinition {
    public final hydra.langs.graphql.syntax.UnionTypeDefinition value;
    
    public Union (hydra.langs.graphql.syntax.UnionTypeDefinition value) {
      this.value = value;
    }
    
    @Override
    public boolean equals(Object other) {
      if (!(other instanceof Union)) {
        return false;
      }
      Union o = (Union) (other);
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
  
  public static final class Enum_ extends hydra.langs.graphql.syntax.TypeDefinition {
    public final hydra.langs.graphql.syntax.EnumTypeDefinition value;
    
    public Enum_ (hydra.langs.graphql.syntax.EnumTypeDefinition value) {
      this.value = value;
    }
    
    @Override
    public boolean equals(Object other) {
      if (!(other instanceof Enum_)) {
        return false;
      }
      Enum_ o = (Enum_) (other);
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
  
  public static final class InputObject extends hydra.langs.graphql.syntax.TypeDefinition {
    public final hydra.langs.graphql.syntax.InputObjectTypeDefinition value;
    
    public InputObject (hydra.langs.graphql.syntax.InputObjectTypeDefinition value) {
      this.value = value;
    }
    
    @Override
    public boolean equals(Object other) {
      if (!(other instanceof InputObject)) {
        return false;
      }
      InputObject o = (InputObject) (other);
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