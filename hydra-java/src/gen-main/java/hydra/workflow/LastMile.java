package hydra.workflow;

/**
 * The last mile of a transformation, which encodes and serializes terms to a file
 */
public class LastMile<A> {
  public static final hydra.core.Name NAME = new hydra.core.Name("hydra/workflow.LastMile");
  
  /**
   * An encoder for terms to a list of output objects
   */
  public final java.util.function.Function<hydra.core.Type<hydra.compute.Kv>, hydra.compute.Flow<hydra.graph.Graph<hydra.compute.Kv>, java.util.function.Function<hydra.core.Term<hydra.compute.Kv>, java.util.function.Function<hydra.graph.Graph<hydra.compute.Kv>, hydra.compute.Flow<hydra.graph.Graph<hydra.compute.Kv>, java.util.List<A>>>>>> encoder;
  
  /**
   * A function which serializes a list of output objects to a string representation
   */
  public final java.util.function.Function<java.util.List<A>, String> serializer;
  
  /**
   * A file extension for the generated file(s)
   */
  public final String fileExtension;
  
  public LastMile (java.util.function.Function<hydra.core.Type<hydra.compute.Kv>, hydra.compute.Flow<hydra.graph.Graph<hydra.compute.Kv>, java.util.function.Function<hydra.core.Term<hydra.compute.Kv>, java.util.function.Function<hydra.graph.Graph<hydra.compute.Kv>, hydra.compute.Flow<hydra.graph.Graph<hydra.compute.Kv>, java.util.List<A>>>>>> encoder, java.util.function.Function<java.util.List<A>, String> serializer, String fileExtension) {
    this.encoder = encoder;
    this.serializer = serializer;
    this.fileExtension = fileExtension;
  }
  
  @Override
  public boolean equals(Object other) {
    if (!(other instanceof LastMile)) {
      return false;
    }
    LastMile o = (LastMile) (other);
    return encoder.equals(o.encoder) && serializer.equals(o.serializer) && fileExtension.equals(o.fileExtension);
  }
  
  @Override
  public int hashCode() {
    return 2 * encoder.hashCode() + 3 * serializer.hashCode() + 5 * fileExtension.hashCode();
  }
  
  public LastMile withEncoder(java.util.function.Function<hydra.core.Type<hydra.compute.Kv>, hydra.compute.Flow<hydra.graph.Graph<hydra.compute.Kv>, java.util.function.Function<hydra.core.Term<hydra.compute.Kv>, java.util.function.Function<hydra.graph.Graph<hydra.compute.Kv>, hydra.compute.Flow<hydra.graph.Graph<hydra.compute.Kv>, java.util.List<A>>>>>> encoder) {
    return new LastMile(encoder, serializer, fileExtension);
  }
  
  public LastMile withSerializer(java.util.function.Function<java.util.List<A>, String> serializer) {
    return new LastMile(encoder, serializer, fileExtension);
  }
  
  public LastMile withFileExtension(String fileExtension) {
    return new LastMile(encoder, serializer, fileExtension);
  }
}