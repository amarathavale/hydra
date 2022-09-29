package hydra.compute;

public class FlowWrapper<S, A> {
  public static final hydra.core.Name NAME = new hydra.core.Name("hydra/compute.FlowWrapper");
  
  public final java.util.Optional<A> value;
  
  public final S state;
  
  public final hydra.compute.Trace trace;
  
  public FlowWrapper (java.util.Optional<A> value, S state, hydra.compute.Trace trace) {
    this.value = value;
    this.state = state;
    this.trace = trace;
  }
  
  @Override
  public boolean equals(Object other) {
    if (!(other instanceof FlowWrapper)) {
      return false;
    }
    FlowWrapper o = (FlowWrapper) (other);
    return value.equals(o.value) && state.equals(o.state) && trace.equals(o.trace);
  }
  
  @Override
  public int hashCode() {
    return 2 * value.hashCode() + 3 * state.hashCode() + 5 * trace.hashCode();
  }
  
  public FlowWrapper withValue(java.util.Optional<A> value) {
    return new FlowWrapper(value, state, trace);
  }
  
  public FlowWrapper withState(S state) {
    return new FlowWrapper(value, state, trace);
  }
  
  public FlowWrapper withTrace(hydra.compute.Trace trace) {
    return new FlowWrapper(value, state, trace);
  }
}