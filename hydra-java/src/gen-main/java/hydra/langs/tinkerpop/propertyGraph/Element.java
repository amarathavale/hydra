package hydra.langs.tinkerpop.propertyGraph;

/**
 * Either a vertex or an edge
 */
public abstract class Element<V, E, P> {
  public static final hydra.core.Name NAME = new hydra.core.Name("hydra/langs/tinkerpop/propertyGraph.Element");
  
  private Element () {
  
  }
  
  public abstract <R> R accept(Visitor<R> visitor) ;
  
  public interface Visitor<R> {
    R visit(Vertex instance) ;
    
    R visit(Edge instance) ;
  }
  
  public interface PartialVisitor<R> extends Visitor<R> {
    default R otherwise(Element instance) {
      throw new IllegalStateException("Non-exhaustive patterns when matching: " + (instance));
    }
    
    default R visit(Vertex instance) {
      return otherwise((instance));
    }
    
    default R visit(Edge instance) {
      return otherwise((instance));
    }
  }
  
  public static final class Vertex<V, E, P> extends hydra.langs.tinkerpop.propertyGraph.Element<V, E, P> {
    public final hydra.langs.tinkerpop.propertyGraph.Vertex<V, P> value;
    
    public Vertex (hydra.langs.tinkerpop.propertyGraph.Vertex<V, P> value) {
      this.value = value;
    }
    
    @Override
    public boolean equals(Object other) {
      if (!(other instanceof Vertex)) {
        return false;
      }
      Vertex o = (Vertex) (other);
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
  
  public static final class Edge<V, E, P> extends hydra.langs.tinkerpop.propertyGraph.Element<V, E, P> {
    public final hydra.langs.tinkerpop.propertyGraph.Edge<V, E, P> value;
    
    public Edge (hydra.langs.tinkerpop.propertyGraph.Edge<V, E, P> value) {
      this.value = value;
    }
    
    @Override
    public boolean equals(Object other) {
      if (!(other instanceof Edge)) {
        return false;
      }
      Edge o = (Edge) (other);
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