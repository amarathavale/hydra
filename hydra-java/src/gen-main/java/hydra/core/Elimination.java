package hydra.core;

/**
 * A corresponding elimination for an introduction term
 */
public abstract class Elimination<A> {
  public static final hydra.core.Name NAME = new hydra.core.Name("hydra/core.Elimination");
  
  private Elimination () {
  
  }
  
  public abstract <R> R accept(Visitor<R> visitor) ;
  
  public interface Visitor<R> {
    R visit(Element instance) ;
    
    R visit(List instance) ;
    
    R visit(Optional instance) ;
    
    R visit(Record instance) ;
    
    R visit(Union instance) ;
    
    R visit(Wrap instance) ;
  }
  
  public interface PartialVisitor<R> extends Visitor<R> {
    default R otherwise(Elimination instance) {
      throw new IllegalStateException("Non-exhaustive patterns when matching: " + (instance));
    }
    
    default R visit(Element instance) {
      return otherwise((instance));
    }
    
    default R visit(List instance) {
      return otherwise((instance));
    }
    
    default R visit(Optional instance) {
      return otherwise((instance));
    }
    
    default R visit(Record instance) {
      return otherwise((instance));
    }
    
    default R visit(Union instance) {
      return otherwise((instance));
    }
    
    default R visit(Wrap instance) {
      return otherwise((instance));
    }
  }
  
  /**
   * Eliminates an element by mapping it to its data term. This is Hydra's delta function.
   */
  public static final class Element<A> extends hydra.core.Elimination<A> {
    public Element () {
    
    }
    
    @Override
    public boolean equals(Object other) {
      if (!(other instanceof Element)) {
        return false;
      }
      Element o = (Element) (other);
      return true;
    }
    
    @Override
    public int hashCode() {
      return 0;
    }
    
    @Override
    public <R> R accept(Visitor<R> visitor) {
      return visitor.visit(this);
    }
  }
  
  /**
   * Eliminates a list using a fold function; this function has the signature b -&gt; [a] -&gt; b
   */
  public static final class List<A> extends hydra.core.Elimination<A> {
    /**
     * Eliminates a list using a fold function; this function has the signature b -&gt; [a] -&gt; b
     */
    public final hydra.core.Term<A> value;
    
    public List (hydra.core.Term<A> value) {
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
  
  /**
   * Eliminates an optional term by matching over the two possible cases
   */
  public static final class Optional<A> extends hydra.core.Elimination<A> {
    /**
     * Eliminates an optional term by matching over the two possible cases
     */
    public final hydra.core.OptionalCases<A> value;
    
    public Optional (hydra.core.OptionalCases<A> value) {
      this.value = value;
    }
    
    @Override
    public boolean equals(Object other) {
      if (!(other instanceof Optional)) {
        return false;
      }
      Optional o = (Optional) (other);
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
  
  /**
   * Eliminates a record by projecting a given field
   */
  public static final class Record<A> extends hydra.core.Elimination<A> {
    /**
     * Eliminates a record by projecting a given field
     */
    public final hydra.core.Projection value;
    
    public Record (hydra.core.Projection value) {
      this.value = value;
    }
    
    @Override
    public boolean equals(Object other) {
      if (!(other instanceof Record)) {
        return false;
      }
      Record o = (Record) (other);
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
  
  /**
   * Eliminates a union term by matching over the fields of the union. This is a case statement.
   */
  public static final class Union<A> extends hydra.core.Elimination<A> {
    /**
     * Eliminates a union term by matching over the fields of the union. This is a case statement.
     */
    public final hydra.core.CaseStatement<A> value;
    
    public Union (hydra.core.CaseStatement<A> value) {
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
  
  /**
   * Unwrap a wrapped term
   */
  public static final class Wrap<A> extends hydra.core.Elimination<A> {
    /**
     * Unwrap a wrapped term
     */
    public final hydra.core.Name value;
    
    public Wrap (hydra.core.Name value) {
      this.value = value;
    }
    
    @Override
    public boolean equals(Object other) {
      if (!(other instanceof Wrap)) {
        return false;
      }
      Wrap o = (Wrap) (other);
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