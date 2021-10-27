package hydra.ext.tinkerpop.v3;

public class Edge {
  public final Value id;
  
  public final Vertex out;
  
  public final Vertex in;
  
  public final java.util.List<Property> properties;
  
  /**
   * Constructs an immutable Edge object
   */
  public Edge(Value id, Vertex out, Vertex in, java.util.List<Property> properties) {
    this.id = id;
    this.out = out;
    this.in = in;
    this.properties = properties;
  }
  
  @Override
  public boolean equals(Object other) {
    if (!(other instanceof Edge)) {
        return false;
    }
    Edge o = (Edge) other;
    return id.equals(o.id)
        && out.equals(o.out)
        && in.equals(o.in)
        && properties.equals(o.properties);
  }
  
  @Override
  public int hashCode() {
    return 2 * id.hashCode()
        + 3 * out.hashCode()
        + 5 * in.hashCode()
        + 7 * properties.hashCode();
  }
  
  /**
   * Construct a new immutable Edge object in which id is overridden
   */
  public Edge withId(Value id) {
    return new Edge(id, out, in, properties);
  }
  
  /**
   * Construct a new immutable Edge object in which out is overridden
   */
  public Edge withOut(Vertex out) {
    return new Edge(id, out, in, properties);
  }
  
  /**
   * Construct a new immutable Edge object in which in is overridden
   */
  public Edge withIn(Vertex in) {
    return new Edge(id, out, in, properties);
  }
  
  /**
   * Construct a new immutable Edge object in which properties is overridden
   */
  public Edge withProperties(java.util.List<Property> properties) {
    return new Edge(id, out, in, properties);
  }
}
